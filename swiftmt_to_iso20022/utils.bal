// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/data.xmldata;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;
import ballerina/regex;

# Transform MT104 message to corresponding ISO20022 XML format.
#
# + message - MT104 SWIFT message to transform
# + return - XML message or error
isolated function getMT104TransformFunction(swiftmt:MT104Message message) returns xml|error {
    if message.block4.MT23E?.InstrnCd?.content is () {
        return handleMT104Transaction(message);
    }
    return handleMT104MessageInstruction(message);
}

# Handle MT104 transaction processing.
#
# + message - MT104 message to process
# + return - XML message or error
isolated function handleMT104Transaction(swiftmt:MT104Message message) returns xml|error {
    foreach swiftmt:MT104Transaction transaxion in message.block4.Transaction {
        if transaxion.MT23E is swiftmt:MT23E {
            string instructionCode = check transaxion.MT23E?.InstrnCd?.content.ensureType(string);
            
            if instructionCode.equalsIgnoreCaseAscii("RTND") {
                return error("Return direct debit transfer message is not supported.");
            }
            
            if isValidInstructionCode(instructionCode) {
                return xmldata:toXml(check transformMT104ToPacs003(message));
            }
            
            if isValidInstructionCode(instructionCode, true) {
                return xmldata:toXml(check transformMT104ToPain008(message));
            }
        }
    }
    return error("Instruction code is required to identify ISO 20022 message type.");
}

# Handle MT104 message instruction processing.
#
# + message - MT104 message to process
# + return - XML message or error
isolated function handleMT104MessageInstruction(swiftmt:MT104Message message) returns xml|error {
    string instructionCode = check message.block4.MT23E?.InstrnCd?.content.ensureType(string);
    
    if isValidInstructionCode(instructionCode) {
        return xmldata:toXml(check transformMT104ToPacs003(message));
    }
    
    if isValidInstructionCode(instructionCode, true) {
        return xmldata:toXml(check transformMT104ToPain008(message));
    }
    
    return error("Return direct debit transfer message is not supported.");
}

# Transform MT107 message to corresponding ISO20022 XML format.
# 
# + message - The MT107 SWIFT message to be transformed
# + return - Returns the transformed XML message or an error if transformation fails
isolated function getMT107TransformFunction(swiftmt:MT107Message message) returns xml|error {
    // Handle message level instruction code
    if message.block4.MT23E?.InstrnCd?.content is string {
        string msgInstructionCode = check message.block4.MT23E?.InstrnCd?.content.ensureType(string);
        return check handleMessageLevelInstruction(message, msgInstructionCode);
    }

    // Handle transaction level instruction codes
    foreach swiftmt:MT107Transaction transaxion in message.block4.Transaction {
        if transaxion.MT23E is swiftmt:MT23E {
            string? txnInstructionCode = check transaxion.MT23E?.InstrnCd?.content.ensureType(string);
            if txnInstructionCode is string {
                if txnInstructionCode.equalsIgnoreCaseAscii(RTND_CODE) {
                    return error(UNSUPPORTED_MSG);
                }
                if isValidInstructionCode(txnInstructionCode) {
                    return xmldata:toXml(check transformMT107ToPacs003(message));
                }
            }
        }
    }
    
    // Default transformation if no specific instruction code found
    return xmldata:toXml(check transformMT107ToPacs003(message));
}

# Handle message level instruction processing
#
# + message - The MT107 message to process
# + instructionCode - The instruction code to process
# + return - XML message or error
isolated function handleMessageLevelInstruction(
    swiftmt:MT107Message message, 
    string instructionCode
) returns xml|error {
    if isValidInstructionCode(instructionCode) {
        return xmldata:toXml(check transformMT107ToPacs003(message));
    }
    return error(UNSUPPORTED_MSG);
}

# Transform MTn96 message to corresponding ISO20022 XML format.
# 
# + message - MTn96 SWIFT message to transform
# + return - XML message or error if transformation fails
isolated function getMTn96TransformFunction(swiftmt:MTn96Message message) returns xml|error {
    if message.block4.MT76?.Nrtv.content.length() < 5{
        return error("Invalid MTn96 message: Missing answer code.");
    }

    string answerCode = message.block4.MT76.Nrtv.content.substring(1, 5);
    return check transformBasedOnAnswerCode(message, answerCode);
}

# Transform message based on answer code
#
# + message - MTn96 message to transform
# + answerCode - Answer code from the message
# + return - Transformed XML or error
isolated function transformBasedOnAnswerCode(swiftmt:MTn96Message message, string answerCode) returns xml|error {
    if isAnswerCodeValid(answerCode) {
        return xmldata:toXml(check transformMTn96ToCamt031(message));
    }
    return xmldata:toXml(check transformMTn96ToCamt028(message));
}

# Validate answer code
#
# + code - Answer code to validate
# + return - True if valid, false otherwise
isolated function isAnswerCodeValid(string code) returns boolean {
    return code.equalsIgnoreCaseAscii(CANCEL_CODE) || 
           code.equalsIgnoreCaseAscii(PENDING_CANCEL_CODE) ||
           code.equalsIgnoreCaseAscii(REJECT_CODE);
}

# Validates if the given instruction code is valid based on context
#
# + code - Instruction code to validate
# + checkForRequest - Whether to check for request-specific codes
# + return - True if valid, false otherwise
isolated function isValidInstructionCode(string code, boolean checkForRequest = false) returns boolean {
    string[] validCodes = [AUTH_CODE, NAUT_CODE, OTHR_CODE];
    
    if checkForRequest {
        validCodes.push(RFDD_CODE);
    }
    
    return validCodes.some(validCode => code.equalsIgnoreCaseAscii(validCode));
}

# Converts SWIFT amount/rate to decimal value
#
# + value - The SWIFT amount or rate to convert
# + return - Decimal value or error if conversion fails
isolated function convertToDecimal(swiftmt:Amnt?|swiftmt:Rt? value) returns decimal|error? {
    
    if value is () {
        return ();
    }

    do {
        string numericString = value.content;
        int? lastCommaIndex = numericString.lastIndexOf(",");

        if lastCommaIndex is int && lastCommaIndex == numericString.length() - 1 {
            return check decimal:fromString(numericString.substring(0, lastCommaIndex));
        }
        return check decimal:fromString(regex:replace(numericString, "\\,", "."));
    } on fail {
        return error(DECIMAL_ERROR);
    }
}

# Converts the given `Amnt` or `Rt` content to a `decimal` value, handling the conversion from a string representation
# that may include commas as decimal separators.
#
# + value - The optional `Amnt` or `Rt` content containing the string value to be converted to a decimal.
# + return - Returns the converted decimal value.
isolated function convertToDecimalMandatory(swiftmt:Amnt?|swiftmt:Rt? value) returns decimal|error {
    if value is () {
        return 0;
    }

    do {
        string numericString = value.content;
        int? lastCommaIndex = numericString.lastIndexOf(",");

        if lastCommaIndex is int && lastCommaIndex == numericString.length() - 1 {
            return check decimal:fromString(numericString.substring(0, lastCommaIndex));
        }
        return check decimal:fromString(regex:replace(numericString, "\\,", "."));
    } on fail {
        return error(DECIMAL_ERROR);
    }
}

# Extracts and returns the remittance information from the provided `MT70` message.
# Depending on the remmitance information code, it returns the remmitance information or an empty string.
#
# + remmitanceInfo - The optional `MT70` object containing remittance information.
# + return - Returns remmitance information as a string or an empty string if no remmitance information was found.
isolated function getRemmitanceInformation(string? remmitanceInfo) returns string {
    if remmitanceInfo is () {
        return "";
    }
    return remmitanceInfo;
}

# Extracts and returns the content of the provided field if it is of type string.
# If the content is not a string, it returns an empty string.
#
# + content - The optional field that may be of type string.
# + return - Returns the string content if the content is a string; otherwise, returns an empty string.
isolated function getMandatoryFields(string? content) returns string {
    if content is () {
        return "";
    }
    return content;
}

isolated function getCurrency(string? currency1, string? currency2) returns string{
    if currency1 is string {
        return currency1;
    }
    if currency2 is string {
        return currency2;
    }
    return "";
}

# Extracts and returns address lines from the provided `AdrsLine` arrays.
# It first checks if the first address array (`address1`) is available and uses it;
# if not, it checks the second address array (`address2`). If neither is available,
# it returns `null`. The function aggregates all address lines into a string array.
#
# + address1 - An optional array of `AdrsLine` that may contain address lines.
# + address2 - An optional array of `AdrsLine` that may also contain address lines (default is `null`).
# + address3 - An optional string of address.
# + return - Returns an array of strings representing the address lines if any address lines are found;
# otherwise, returns `null`.
isolated function getAddressLine(swiftmt:AdrsLine[]? address1, swiftmt:AdrsLine[]? address2 = (), 
    string? address3 = ()) returns string[]? {
        swiftmt:AdrsLine[] finalAddress = [];
        if address1 is swiftmt:AdrsLine[] {
            finalAddress = address1;
        } else if address2 is swiftmt:AdrsLine[] {
            finalAddress = address2;
        } else if address3 is string {
            return [address3];
        } else {
            return ();
        }
        return from swiftmt:AdrsLine adrsLine in finalAddress
            select adrsLine.content;
}

# Retrieves the details charges code based on the provided `Cd` code.
# It looks up the code in an array and returns the corresponding details charge description.
# If the code is not found, it returns an error.
#
# + code - An optional `Cd` object that contains the code to be looked up.
# + return - Returns the details charge description associated with the provided code;
# Otherwise an error.
isolated function getDetailsChargesCd(swiftmt:Cd? code) returns string|error {
    string[][] chargesCodeArray = DETAILS_CHRGS;
    if code is () {
        return error("Details of charges code is madatory.");
    }
    foreach string[] line in chargesCodeArray {
        if line[0].equalsIgnoreCaseAscii(code.content) {
            return line[1];
        }
    }
    return error("Details of charges code is invalid.");
}

# Extracts and returns regulatory reporting details from the provided `MT77B` object.
# The function parses the `Nrtv` content of the `MT77B` object to determine the regulatory reporting details
# based on specific content patterns. It returns an array of `RgltryRptg` objects with the extracted details.
#
# + rgltyRptg - An optional `MT77B` object that contains the regulatory reporting information.
# + return - Returns an array of `RgltryRptg` objects with the extracted regulatory reporting details.
# The details are based on the content of the `Nrtv` field within the `MT77B` object.
isolated function getRegulatoryReporting(string? rgltyRptg) returns camtIsoRecord:RegulatoryReporting3[]? {
    if rgltyRptg is () {
        return ();
    }
    if rgltyRptg.substring(1, 9).equalsIgnoreCaseAscii("BENEFRES") ||
        rgltyRptg.substring(1, 9).equalsIgnoreCaseAscii("ORDERRES") {
        string additionalInfo = "";
        if rgltyRptg.length() > 14 {
            foreach int i in 14 ... rgltyRptg.length() - 1 {
                if rgltyRptg.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
                    continue;
                }
                if rgltyRptg.substring(i, i + 1).equalsIgnoreCaseAscii("\n") {
                    additionalInfo += " ";
                    continue;
                }
                additionalInfo += rgltyRptg.substring(i, i + 1);
            }
        }
        return [
            {
                Dtls: [
                    {
                        Cd: rgltyRptg.substring(1, 9),
                        Ctry: rgltyRptg.substring(10, 12),
                        Inf: [additionalInfo]
                    }
                ]
            }
        ];
    }
    return [
        {
            Dtls: [
                {
                    Inf: [rgltyRptg.substring(0)]
                }
            ]
        }
    ];
}

# Extracts and returns different parts of a party identifier based on its format.
# The function handles different formats of the party identifier and returns a tuple with specific substrings
# or `null` values depending on the conditions.
#
# + prtyIdnOrAcc - An optional `PrtyIdn` object containing the party identifier information.
# + return - Returns a tuple of strings and/or null values based on the party identifier content and the `fields` 
# parameter.
isolated function getPartyIdentifierOrAccount(swiftmt:PrtyIdn? prtyIdnOrAcc) 
    returns [string?, string?, string?, string?, string?] {
        if prtyIdnOrAcc is () {
            return [];
        }
        string content = prtyIdnOrAcc.content;
        if content.length() > 4 {
            if content.substring(0, 1).equalsIgnoreCaseAscii("/") {
                return [(), ...validateAccountNumber(prtyIdn = prtyIdnOrAcc), (), ()];
            }
            string? partyIdentifier = ();
            string? schemaCode = (); 
            string? issuer = ();
            foreach string code in SCHEMA_CODE {
                if !code.equalsIgnoreCaseAscii(content.substring(0,4)) {
                    continue;
                }
                schemaCode = code;
                int count = 0;
                foreach int i in 0 ... content.length() - 1 {
                    if content.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
                        count += 1;
                    }
                    if count == 2 {
                        partyIdentifier = content.substring(i + 1);
                    }
                    if count == 3 {
                        partyIdentifier = content.substring(i + 1);
                        issuer = content.substring(8, i);
                        break;
                    }
                }
                break;
            }
            return [partyIdentifier, (), (), schemaCode, issuer];
        }
        return [];
}

# Extracts and returns different parts of a party identifier or account information based on its content.
# The function checks three optional `PrtyIdn` objects (`prtyIdn1`, `prtyIdn2`, and `prtyIdn3`) and determines if they 
# contain
# valid identifiers or account numbers. It returns a tuple of strings where the first element represents the party 
# identifier, and the subsequent elements correspond to the account number validation results.
#
# + prtyIdn1 - An optional `PrtyIdn` object that may contain a party identifier or account number.
# + prtyIdn2 - A second optional `PrtyIdn` object that may contain a party identifier or account number.
# + prtyIdn3 - A third optional `PrtyIdn` object that may contain a party identifier or account number.
# + prtyIdn4 - A fourth optional `PrtyIdn` object that may contain a party identifier or account number.
# + return - Returns a tuple of strings and/or null values based on the party identifier content.
isolated function getPartyIdentifierOrAccount2(swiftmt:PrtyIdn? prtyIdn1, swiftmt:PrtyIdn? prtyIdn2 = (), 
    swiftmt:PrtyIdn? prtyIdn3 = (), swiftmt:PrtyIdn? prtyIdn4 = ()) returns [string?, string?, string?] {
        if prtyIdn1 is swiftmt:PrtyIdn && isValidPartyIdentifier(prtyIdn1.content) {
            return [prtyIdn1.content.substring(1), (), ()];
        }
        if prtyIdn2 is swiftmt:PrtyIdn && isValidPartyIdentifier(prtyIdn2.content) {
            return [prtyIdn2.content.substring(1), (), ()];
        }
        if prtyIdn3 is swiftmt:PrtyIdn && isValidPartyIdentifier(prtyIdn3.content) {
            return [prtyIdn3.content.substring(1), (), ()];
        }
        if prtyIdn1 is swiftmt:PrtyIdn && isValidAccountNumber(prtyIdn1.content) {
            return [(), ...validateAccountNumber(prtyIdn = prtyIdn1)];
        }
        if prtyIdn2 is swiftmt:PrtyIdn && isValidAccountNumber(prtyIdn2.content) {
            return [(), ...validateAccountNumber(prtyIdn = prtyIdn2)];
        }
        if prtyIdn3 is swiftmt:PrtyIdn && isValidAccountNumber(prtyIdn3.content) {
            return [(), ...validateAccountNumber(prtyIdn = prtyIdn3)];
        }
        return [];
}

isolated function isValidPartyIdentifier(string content) returns boolean {
    string[] excluded_prefixes = ["/CH", "/FW", "/RT"];
    int? index  = excluded_prefixes.indexOf(content.substring(0, 3));
    return content.length() > 1 && content.startsWith("/") && index is ();
}

isolated function isValidAccountNumber(string content) returns boolean {
    return content.length() > 0 && (!content.startsWith("/") || content.startsWith("/CH"));
}

# Concatenates the contents of `Nm` elements from one of two possible arrays into a single string.
# The function handles cases where either one or both of the arrays might be provided.
#
# + name1 - An optional array of `Nm` elements that may contain the first set of name components.
# + name2 - An optional array of `Nm` elements that may contain the second set of name components.
# + return - Returns a single concatenated string of all name components, separated by spaces, or `null` if no valid 
# input is provided.
isolated function getName(swiftmt:Nm[]? name1, swiftmt:Nm[]? name2 = ()) returns string? {
    string finalName = "";
    swiftmt:Nm[] nameArray;
    if name1 is swiftmt:Nm[] {
        nameArray = name1;
    } else if name2 is swiftmt:Nm[] {
        nameArray = name2;
    } else {
        return ();
    }
    foreach int index in 0 ... nameArray.length() - 1 {
        if index == nameArray.length() - 1 {
            finalName += nameArray[index].content;
            break;
        }
        finalName = finalName + nameArray[index].content + " ";
    }
    return finalName;
}

# Extracts the country and town information from the provided `CntyNTw` array.
# The country is extracted from the first two characters of the first element, 
# and the town is extracted from the remaining part of the string if present.
#
# + cntyNTw - An optional array of `CntyNTw` elements that contains country and town information.
# + return - Returns a tuple with two elements: the country (first two characters) and the town 
# (remainder of the string), or `[null, null]` if the input is invalid.
isolated function getCountryAndTown(swiftmt:CntyNTw[]? cntyNTw) returns [string?, string?] {
    if cntyNTw is () {
        return [];
    }
    [string?, string?] cntyNTwArray = [];
    cntyNTwArray[0] = cntyNTw[0].content.substring(0, 2);
    if cntyNTw[0].content.length() > 3 {
        cntyNTwArray[1] = cntyNTw[0].content.substring(3);
        return cntyNTwArray;
    }
    cntyNTwArray[1] = ();
    return cntyNTwArray;
}

# Validates and processes account numbers from various sources
#
# + acc1 - Primary account number
# + prtyIdn - Party identifier
# + acc2 - Secondary account number
# + acc3 - Tertiary account number
# + return - Tuple containing [IBAN-validated account, non-IBAN account]
isolated function validateAccountNumber(
    swiftmt:Acc? acc1 = (), 
    swiftmt:PrtyIdn? prtyIdn = (), 
    swiftmt:Acc? acc2 = (), 
    swiftmt:Acc? acc3 = ()
) returns [string?, string?] {
    // Get first valid account number
    string|error finalAccount = getFirstValidAccount(acc1, acc2, acc3, prtyIdn);
    if finalAccount is error {
        return [];
    }

    // Validate IBAN format
    if !finalAccount.matches(re `${IBAN_PATTERN}`) {
        return [(), finalAccount];
    }

    // Process IBAN validation
    return validateIBAN(finalAccount);
}

# Gets the first valid account from multiple sources
#
# + acc1 - Primary account
# + acc2 - Secondary account
# + acc3 - Tertiary account
# + prtyIdn - Party identifier
# + return - First valid account or error
isolated function getFirstValidAccount(
    swiftmt:Acc? acc1, 
    swiftmt:Acc? acc2, 
    swiftmt:Acc? acc3, 
    swiftmt:PrtyIdn? prtyIdn
) returns string|error {
    if acc1 is swiftmt:Acc {
        return acc1.content;
    } 
    if acc2 is swiftmt:Acc {
        return acc2.content;
    }
    if acc3 is swiftmt:Acc {
        return acc3.content;
    }
    if prtyIdn is swiftmt:PrtyIdn && prtyIdn.content.length() > 1 {
        return prtyIdn.content.startsWith("/") ? 
            prtyIdn.content.substring(1) : prtyIdn.content;
    }
    return error("No valid account found");
}

# Validates IBAN number
#
# + account - Account number to validate
# + return - Tuple containing [validated IBAN, empty string] or [empty, original account]
isolated function validateIBAN(string account) returns [string?, string?] {
    foreach string country in COUNTRY_CODES {
        if !account.substring(0, COUNTRY_CODE_LENGTH).equalsIgnoreCaseAscii(country) {
            continue;
        }
        
        string|error result = processIBANValidation(account);
        if result is string {
            return [account, ""];
        }
    }
    return ["", account];
}

# Processes IBAN validation calculation
#
# + account - Account number to process
# + return - Validated account number or error
isolated function processIBANValidation(string account) returns string|error {
    string rearrangedAccount = account.substring(IBAN_CHECK_DIGITS_LENGTH) + 
                              account.substring(0, IBAN_CHECK_DIGITS_LENGTH);
    string numericAccount = "";
    
    foreach int index in 0 ... rearrangedAccount.length() - 1 {
        string character = rearrangedAccount.substring(index, index + 1);
        if character.matches(re `^[A-Z]+$`) {
            numericAccount += check LETTER_LIST[character].ensureType(string);
            continue;
        }
        numericAccount += character;
    }
    
    decimal accountNumber = check decimal:fromString(numericAccount);
    if (accountNumber % MOD_97).ensureType(int) == 1 {
        return account;
    }
    return error("Invalid IBAN checksum");
}

# Retrieves the party identifier from up to three possible inputs.
# Returns the identifier if one is provided and has a length greater than 1. 
# If none of the provided identifiers are valid, returns an empty string.
#
# + identifier1 - Optional party identifier inputs.
# + identifier2 - Optional party identifier inputs.
# + identifier3 - Optional party identifier inputs.
# + identifier4 - Optional party identifier inputs.
# + return - Returns the party identifier as a string or an empty string if none are valid.
isolated function getPartyIdentifier(swiftmt:PrtyIdn? identifier1, swiftmt:PrtyIdn? identifier2 = (),
    swiftmt:PrtyIdn? identifier3 = (), swiftmt:PrtyIdn? identifier4 = ()) returns string? {
        if identifier1 is swiftmt:PrtyIdn && (identifier1.content).length() > 1 {
            return identifier1?.content;
        }
        if identifier2 is swiftmt:PrtyIdn && (identifier2.content).length() > 1 {
            return identifier2?.content;
        }
        if identifier3 is swiftmt:PrtyIdn && (identifier3.content).length() > 1 {
            return identifier3?.content;
        }
        if identifier4 is swiftmt:PrtyIdn && (identifier4.content).length() > 1 {
            return identifier4?.content;
        }
        return ();
}

# Retrieves the instructed amount from either `MT33B` or `MT32B` message types.
# If `MT33B` message is provided, it tries to get the amount from it; otherwise, it uses the amount from `MT32B`.
# If the amount conversion results in null, it returns 0.0.
#
# + transAmnt - The `MT32B` message containing the transaction amount.
# + instrdAmnt - The optional `MT33B` message containing the instructed amount.
# + stlmntAmnt - The optional `MT32A` message containing the settlement amount.
# + return - Returns the instructed amount as a decimal or 0 if the amount cannot be converted.
isolated function getInstructedAmount(swiftmt:MT32B? transAmnt = (), swiftmt:MT33B? instrdAmnt = (),
    swiftmt:MT32A? stlmntAmnt = ()) returns decimal|error {
        if instrdAmnt is swiftmt:MT33B {
            return convertToDecimalMandatory(instrdAmnt.Amnt);
        }
        if transAmnt is swiftmt:MT32B {
            return convertToDecimalMandatory(transAmnt.Amnt);
        }
        if stlmntAmnt is swiftmt:MT32A {
            return convertToDecimalMandatory(stlmntAmnt.Amnt);
        }
        return 0;
}

# Retrieves the instructed amount from either `MT33B` or `MT32B` message types.
# If `MT33B` message is provided, it tries to get the amount from it; otherwise, it uses the amount from `MT32B`.
# If the amount conversion results in null, it returns 0.0.
#
# + sumAmnt - The `MT19` message containing the sum of amounta.
# + stlmntAmnt - The optional `MT32A` message containing the settlement amount.
# + return - Returns the total interbank settlement amount as a decimal or 0 if the amount cannot be converted.
isolated function getTotalInterBankSettlementAmount(swiftmt:MT19? sumAmnt = (), 
    swiftmt:MT32A?|swiftmt:MT32B? stlmntAmnt = ()) returns decimal|error {
        if sumAmnt is swiftmt:MT19 {
            return convertToDecimalMandatory(sumAmnt.Amnt);
        }
        if stlmntAmnt is swiftmt:MT32A|swiftmt:MT32B {
            return convertToDecimalMandatory(stlmntAmnt.Amnt);
        }
        return 0;
}

# Determines the schema code based on account numbers and party identifiers.
# It returns "BBAN" if any of the provided accounts or party identifiers are valid, otherwise returns null.
#
# + account1 - An optional `Acc` instance representing the first account.
# + account2 - An optional `Acc` instance representing the second account.
# + account3 - An optional `Acc` instance representing the third account.
# + prtyIdn1 - An optional `PrtyIdn` instance representing the party identifier.
# + prtyIdn2 - An optional `PrtyIdn` instance representing the party identifier.
# + prtyIdn3 - An optional `PrtyIdn` instance representing the party identifier.
# + prtyIdn4 - An optional `PrtyIdn` instance representing the party identifier.
# + return - Returns "BBAN" if any valid account number or party identifier is found, otherwise returns null.
isolated function getSchemaCode(swiftmt:Acc? account1 = (), swiftmt:Acc? account2 = (), swiftmt:Acc? account3 = (),
    swiftmt:PrtyIdn? prtyIdn1 = (), swiftmt:PrtyIdn? prtyIdn2 = (), swiftmt:PrtyIdn? prtyIdn3 = (), 
    swiftmt:PrtyIdn? prtyIdn4 = ()) returns string? {
        if account1?.content != "NOTPROVIDED" || account2?.content != "NOTPROVIDED" || account3?.content != "NOTPROVIDED" 
            || prtyIdn1?.content != "NOTPROVIDED" || prtyIdn2?.content != "NOTPROVIDED" 
            || prtyIdn3?.content != "NOTPROVIDED" || prtyIdn4?.content != "NOTPROVIDED" {
                if !(validateAccountNumber(account1)[1] is ()) || !(validateAccountNumber(account2)[1] is ())
                || !(validateAccountNumber(account3)[1] is ()) || !(getPartyIdentifierOrAccount2(prtyIdn1)[2] is ())
                || !(getPartyIdentifierOrAccount2(prtyIdn2)[2] is ()) || 
                !(getPartyIdentifierOrAccount2(prtyIdn3)[2] is ()) {
                    return "BBAN";
                }
        }
        return ();
}

# Determines the schema code based on account numbers and party identifiers for Debtor and Creditor.
# It returns "BBAN" if any of the provided accounts or party identifiers are valid, otherwise returns null.
#
# + account1 - An optional `Acc` instance representing the first account.
# + account2 - An optional `Acc` instance representing the second account.
# + account3 - An optional `Acc` instance representing the third account.
# + prtyIdn1 - An optional `PrtyIdn` instance representing the party identifier.
# + prtyIdn2 - An optional `PrtyIdn` instance representing the party identifier.
# + prtyIdn3 - An optional `PrtyIdn` instance representing the party identifier.
# + prtyIdn4 - An optional `PrtyIdn` instance representing the party identifier.
# + return - Returns "BBAN" if any valid account number or party identifier is found, otherwise returns null.
isolated function getSchemaCodeForDbtr(swiftmt:Acc? account1 = (), swiftmt:Acc? account2 = (), 
    swiftmt:Acc? account3 = (),swiftmt:PrtyIdn? prtyIdn1 = (), swiftmt:PrtyIdn? prtyIdn2 = (), 
    swiftmt:PrtyIdn? prtyIdn3 = (), swiftmt:PrtyIdn? prtyIdn4 = ()) returns string? {
        if account1?.content != "NOTPROVIDED" || account2?.content != "NOTPROVIDED" || account3?.content != "NOTPROVIDED" 
            || prtyIdn1?.content != "NOTPROVIDED" || prtyIdn2?.content != "NOTPROVIDED" 
            || prtyIdn3?.content != "NOTPROVIDED" || prtyIdn4?.content != "NOTPROVIDED" {
            if !(validateAccountNumber(account1)[1] is ()) || !(validateAccountNumber(account2)[1] is ())
                || !(validateAccountNumber(account3)[1] is ()) || !(getPartyIdentifierOrAccount(prtyIdn1)[2] is ())
                || !(getPartyIdentifierOrAccount(prtyIdn2)[2] is ()) || !(getPartyIdentifierOrAccount(prtyIdn3)[2] is ()) {
                return "BBAN";
            }
        }
        return ();
}

# Returns the account ID or party identifier based on the provided inputs.
# It prioritizes returning the `account` if it is not null; otherwise, it returns the `prtyIdn` if it is not null.
#
# + account - A string that may represent an account ID.
# + prtyIdn - A string that may represent a party identifier.
# + return - Returns the `account` if it is not null; otherwise, returns `prtyIdn` if it is not null.
isolated function getAccountId(string? account, string? prtyIdn) returns string? {
    if account !is () {
        return account;
    }
    if prtyIdn !is () {
        return prtyIdn;
    }
    return ();
}

# Returns an array of `camtIsoRecord:Charges16` objects that contains charges information based on the provided `MT71F` 
# and `MT71G` SWIFT message records.
#
# + sndsChrgs - An optional `swiftmt:MT71F` object that contains information about sender's charges.
# + rcvsChrgs - An optional `swiftmt:MT71G` object that contains information about receiver's charges.
# + return - An array of `camtIsoRecord:Charges16` containing two entries:
# - The first entry includes the sender's charges amount and currency, with a charge type of "CRED".
# - The second entry includes the receiver's charges amount and currency, with a charge type of "DEBT".
#
# The function uses helper methods `convertToDecimalMandatory` to convert the amount and 
# `getMandatoryFields` to fetch the currency.
isolated function getChargesInformation(swiftmt:MT71F[]? sndsChrgs, swiftmt:MT71G? rcvsChrgs) 
    returns camtIsoRecord:Charges16[]?|error {
        camtIsoRecord:Charges16[] chrgsInf = [];
        if sndsChrgs is swiftmt:MT71F[] {
            foreach swiftmt:MT71F charges in sndsChrgs {
                chrgsInf.push({
                    Amt: {
                        content: check convertToDecimalMandatory(charges?.Amnt),
                        Ccy: getMandatoryFields(charges?.Ccy.content)
                    },
                    Agt: {
                        FinInstnId: {
                            Nm:"NOTPROVIDED",
                            PstlAdr: {AdrLine: ["NOTPROVIDED"]}}
                    }});
            }
        }
        if rcvsChrgs is swiftmt:MT71G {
            chrgsInf.push({
                Amt: {
                    content: check convertToDecimalMandatory(rcvsChrgs?.Amnt),
                    Ccy: getMandatoryFields(rcvsChrgs?.Ccy.content)
                },
                Agt: {
                    FinInstnId: {
                        Nm:"NOTPROVIDED",
                        PstlAdr: {AdrLine: ["NOTPROVIDED"]}}
                }});
        }
        if chrgsInf.length() == 0 {
            return ();
        }
        return chrgsInf;
}

# Extracts and returns the time indication based on the provided `MT13C` message.
#
# + tmInd - An optional `swiftmt:MT13C` record containing the time indication information.
# + return - Returns a tuple with the time in "HH:MM:SS" format based on the content of `tmInd`.
# - If no code matches, it returns a tuple of `null` values.
isolated function getTimeIndication(swiftmt:MT13C? tmInd) returns [string?, string?, string?] {
    if tmInd is swiftmt:MT13C {
        match (tmInd.Cd.content) {
            "CLSTIME" => {
                return [tmInd.Tm.content.substring(0, 2) + ":" + tmInd.Tm.content.substring(2) + ":00" +
                    tmInd.Sgn.content + tmInd.TmOfst.content.substring(0,2) + ":" + 
                    tmInd.TmOfst.content.substring(2), (), ()];
            }
            "RNCTIME" => {
                // Dummy date is added to translate the time to ISO standard date and time;
                return [(), "0001-01-01T" + tmInd.Tm.content.substring(0, 2) + ":" + tmInd.Tm.content.substring(2) +
                    ":00" + tmInd.Sgn.content + tmInd.TmOfst.content.substring(0,2) + ":" + 
                    tmInd.TmOfst.content.substring(2), ()];
            }
            "SNDTIME" => {
                // Dummy date is added to translate the time to ISO standard date and time;
                return [(), (), "0001-01-01T" + tmInd.Tm.content.substring(0, 2) + ":" + tmInd.Tm.content.substring(2) +
                ":00" + tmInd.Sgn.content + tmInd.TmOfst.content.substring(0,2) + ":" + 
                tmInd.TmOfst.content.substring(2)];
            }
        }
    }
    return [];
}

# Extracts and returns specific sender-to-receiver information from the provided MT72 record.
#
# + sndRcvInfo - An optional `swiftmt:MT72` that contains the sender-to-receiver information.
# + return - Returns a tuple with extracted information based on the content of `sndRcvInfo`. 
# - If no conditions match, it returns a tuple of `null` values.
isolated function getMT1XXSenderToReceiverInformation(swiftmt:MT72? sndRcvInfo) returns 
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[],
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?,
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
    pacsIsoRecord:CategoryPurpose1Choice?]|error {
        if sndRcvInfo is swiftmt:MT72 {
            string[] code = [];
            string?[] additionalInfo = [];
            [boolean, boolean] [isAddtnlInfoPresent, isPreviousValidCode] = [false, true];
            string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
            foreach int i in 0 ... infoArray.length() - 1 {
                foreach string item in MT_1XX_SNDR_CODE {
                    if i == 0 && item.equalsIgnoreCaseAscii(infoArray[i]) {
                        code.push(item);
                        isAddtnlInfoPresent = false;
                        break;
                    }
                    if item.equalsIgnoreCaseAscii(infoArray[i]) && i != 0 {
                        code.push(item);
                        if isPreviousValidCode {
                            additionalInfo.push(());
                        }
                        isPreviousValidCode = true;
                        isAddtnlInfoPresent = false;
                        break;
                    }
                    isAddtnlInfoPresent = true;
                }
                if isAddtnlInfoPresent {
                    if i == 0 {
                        return error("Sender to receiver information code is not supported.");
                    }
                    isPreviousValidCode = false;
                    additionalInfo.push(infoArray[i]);
                }
            }
            if code.length() != additionalInfo.length() {
                additionalInfo.push(());
            }
            return getMT1XXSenderToReceiverInformationForAgts(code, additionalInfo);
        }
        return [];
}

# Extracts and returns specific sender-to-receiver information from the provided MT1XX record.
#
# + code - An array of strings representing specific codes from the sender-to-receiver information (e.g., "INT", "ACC", "INS").
# + additionalInfo - An optional array of strings containing additional details corresponding to each code.
# Defaults to an empty array if not provided.
# + return - Returns a tuple with extracted information based on the content in code and addtionalinfo array.
# If no conditions match, it returns a tuple with empty arrays and `null` values for optional fields.
isolated function getMT1XXSenderToReceiverInformationForAgts(string[] code, string?[] additionalInfo = []) returns 
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
    pacsIsoRecord:CategoryPurpose1Choice?] {
        pacsIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
        pacsIsoRecord:InstructionForNextAgent1[] instrFrNxtAgt = [];
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt2 = ();
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? prvsInstgAgt1 = ();
        [string?, pacsIsoRecord:LocalInstrument2Choice?, pacsIsoRecord:CategoryPurpose1Choice?] 
            [serviceLevel, lclInstrm, purpose] = [(), (), ()];
        foreach int i in 0 ... code.length() - 1 {
            match (code[i]) {
                "INT" => {
                    instrFrNxtAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
                }
                "ACC" => {
                    instrFrCdtrAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
                }
                "INS"|"INTA" => {
                    if  additionalInfo[i].toString().substring(0, 6).matches(re `^[A-Z]+$`) 
                        && additionalInfo[i].toString().substring(6,7).matches(re `^[A-Z2-9]+$`) && 
                        additionalInfo[i].toString().substring(7, 8).matches(re `^[A-NP-Z0-9]+$`) {
                            if code[i].toString().equalsIgnoreCaseAscii("INS") {
                                prvsInstgAgt1 = {FinInstnId: {BICFI: additionalInfo[i]}};
                            } else {
                                intrmyAgt2 = {FinInstnId: {BICFI: additionalInfo[i]}};
                            }
                    } else {
                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            prvsInstgAgt1 = {FinInstnId: {Nm: additionalInfo[i]}};
                        } else {
                            intrmyAgt2 = {FinInstnId: {Nm: additionalInfo[i]}};
                        }
                    }
                }
                "SVCLVL" => {
                    serviceLevel = code[i];
                }
                "LOCINS" => {
                    lclInstrm = {Cd: code[i]};
                }
                "CATPURP" => {
                    purpose = {Cd: code[i]};
                }
            }
        }
        return [instrFrCdtrAgt, instrFrNxtAgt, prvsInstgAgt1, intrmyAgt2, serviceLevel, lclInstrm, purpose];
}

# Extracts and returns instructions and related information for agents based on the provided MT23E and MT72 records.
#
# + instnCd - An optional array of `swiftmt:MT23E` records containing instruction codes and details.
# + sndRcvInfo - An optional `swiftmt:MT72` record containing sender-to-receiver information.
# + return - Returns a tuple extracted information based on the content in `instnCd` and `sndRcvInfo`.
# If an error occurs during processing, it returns the corresponding error.
isolated function getInformationForAgents(swiftmt:MT23E[]? instnCd, swiftmt:MT72? sndRcvInfo) returns 
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], string?, 
    pacsIsoRecord:CategoryPurpose1Choice?]|error {
        [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], string?, 
            pacsIsoRecord:CategoryPurpose1Choice?] [instrFrCdtrAgt, instrFrNxtAgt, finalServiceLevel, finalPurpose] = [];
        [string?, string?] [serviceLevel1, serviceLevel2] = [getMT103InstructionCode(instnCd)[2], 
            (check getMT1XXSenderToReceiverInformation(sndRcvInfo))[4]];
        [pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:CategoryPurpose1Choice?] [purpose1, purpose2] = 
            [getMT103InstructionCode(instnCd)[3], (check getMT1XXSenderToReceiverInformation(sndRcvInfo))[6]];
        
        foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in getMT103InstructionCode(instnCd)[0] {
            instrFrCdtrAgt.push(instruction);
        }
        foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in (
            check getMT1XXSenderToReceiverInformation(sndRcvInfo))[0] {
                instrFrCdtrAgt.push(instruction);
        }
        foreach pacsIsoRecord:InstructionForNextAgent1 instruction in getMT103InstructionCode(instnCd)[1] {
            instrFrNxtAgt.push(instruction);
        }
        foreach pacsIsoRecord:InstructionForNextAgent1 instruction in (
            check getMT1XXSenderToReceiverInformation(sndRcvInfo))[1] {
                instrFrNxtAgt.push(instruction);
        }

        if serviceLevel1 is string {
            finalServiceLevel = serviceLevel1;
        } else {
            finalServiceLevel = serviceLevel2;
        }

        if purpose1 is pacsIsoRecord:CategoryPurpose1Choice {
            finalPurpose = purpose1;
        } else {
            finalPurpose = purpose2;
        }

        return [instrFrCdtrAgt, instrFrNxtAgt, finalServiceLevel, finalPurpose];
}

# Extracts the Sender to Receiver Information (MT72) from the given SWIFT MT2XX message.
#
# + sndRcvInfo - The SWIFT MT2XX `swiftmt:MT72` structure containing sender-to-receiver information.
# + sndCdNum - The number which defines the code array which is used to verify the code given in the message.
# + return - A tuple with specific values extracted based on the message content, or nulls 
# if no match.
isolated function getMT2XXSenderToReceiverInfo(swiftmt:MT72? sndRcvInfo, int sndCdNum = 1) returns 
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
    pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:RemittanceInformation2?, pacsIsoRecord:Purpose2Choice?]|error {
        if sndRcvInfo is swiftmt:MT72 {
            [string[], string?[], boolean, boolean, string[]] [code, additionalInfo, isAddtnlInfoPresent, 
                isPreviousValidCode, codeArray] = [[], [], false, true, []];
            if sndCdNum == 1 {
                codeArray = MT_2XX_SNDR_CODE1;
            }
            if sndCdNum == 2 {
                codeArray = MT_2XX_SNDR_CODE2;
            }
            if sndCdNum == 3 {
                codeArray = MT_2XX_SNDR_CODE3;
            }
            string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
            foreach int i in 0 ... infoArray.length() - 1 {
                foreach string item in codeArray {
                    if i == 0 && item.equalsIgnoreCaseAscii(infoArray[i]) {
                        code.push(item);
                        isAddtnlInfoPresent = false;
                        break;
                    }
                    if item.equalsIgnoreCaseAscii(infoArray[i]) && i != 0 {
                        code.push(item);
                        if isPreviousValidCode {
                            additionalInfo.push(());
                        }
                        isPreviousValidCode = true;
                        isAddtnlInfoPresent = false;
                        break;
                    }
                    isAddtnlInfoPresent = true;
                }
                if isAddtnlInfoPresent {
                    if i == 0 {
                        return error("Sender to receiver information code is not supported.");
                    }
                    additionalInfo.push(infoArray[i]);
                    isPreviousValidCode = false;
                }
            }
            if code.length() != additionalInfo.length() {
                additionalInfo.push(());
            }
            return check getMT2XXSenderToReceiverInfoForAgts(code, additionalInfo);
        }
        return [];
}

# Extracts and returns instructions and related information for agents from the provided MT2XX sender-to-receiver details.
#
# + code - An array of strings representing the codes for sender-to-receiver information.
# + additionalInfo - An optional array of strings containing additional information corresponding to the codes.
# + return - Returns a tuple with extracted information based on the content in code and addtionalinfo array.
# If an error occurs during processing, it returns the corresponding error.
isolated function getMT2XXSenderToReceiverInfoForAgts(string[] code, string?[] additionalInfo = []) returns 
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
    pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:RemittanceInformation2?, pacsIsoRecord:Purpose2Choice?]|error {
        pacsIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
        pacsIsoRecord:InstructionForNextAgent1[] instrFrNxtAgt = [];
        [pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?]
            [intrmyAgt2, prvsInstgAgt1] = [(), ()];
        [string?, pacsIsoRecord:LocalInstrument2Choice?, pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:RemittanceInformation2?, 
            pacsIsoRecord:Purpose2Choice?] [serviceLevel, lclInstrm, catPurpose, remmitanceInfo, purpose] = [(), (), (), (), ()];
        foreach int i in 0 ... code.length() - 1 {
            match (code[i]) {
                "INT"|"PHON"|"TELE"|"TELEIBK"|"PHONIBK" => {
                    instrFrNxtAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
                }
                "ACC"|"UDLC"|"PHONBEN"|"TELEBEN" => {
                    instrFrCdtrAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
                }
                "INS"|"INTA" => {
                    if additionalInfo[i].toString().length() == 8 && additionalInfo[i].toString().substring(0, 6).matches(re `^[A-Z]+$`) 
                    && additionalInfo[i].toString().substring(6,7).matches(re `^[A-Z2-9]+$`) && 
                    additionalInfo[i].toString().substring(7).matches(re `^[A-NP-Z0-9]+$`) {
                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            prvsInstgAgt1 = {FinInstnId: {BICFI: additionalInfo[i]}};
                        } else {
                            intrmyAgt2 = {FinInstnId: {BICFI: additionalInfo[i]}};
                        }
                    } else {
                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            prvsInstgAgt1 = {FinInstnId: {Nm: additionalInfo[i]}};
                        } else {
                            intrmyAgt2 = {FinInstnId: {Nm: additionalInfo[i]}};
                        }
                    }
                }
                "BNF"|"TSU" => {
                    remmitanceInfo = {
                        Ustrd: [check additionalInfo[i].ensureType(pacsIsoRecord:Max140Text)]
                    };
                }
                "PURP" => {
                    purpose = {
                        Cd: code[i]
                    };
                }
                "SVCLVL" => {
                    serviceLevel = code[i];
                }
                "LOCINS" => {
                    lclInstrm = {Cd: code[i]};
                }
                "CATPURP" => {
                    catPurpose = {Cd: code[i]};
                }
            }
        }
        return [instrFrCdtrAgt, instrFrNxtAgt, prvsInstgAgt1, intrmyAgt2, serviceLevel, lclInstrm, catPurpose,
            remmitanceInfo, purpose];
}

# Determines the settlement method based on the input MT53A, MT53B, or MT53D record.
#
# + mt53A - An optional `swiftmt:MT53A` record. If provided, and MT53A or MT53D is valid, returns "COVE".
# + mt53B - An optional `swiftmt:MT53B` record. If provided, returns "INGA" for a party identification type "C" and 
# "INDA" for type "D".
# + mt53D - An optional `swiftmt:MT53D` record. If provided, and MT53A or MT53D is valid, returns "COVE".
# + return - Returns "INGA", "INDA", or "COVE" based on the provided inputs. If no conditions match, returns "INDA" 
# by default.
isolated function getSettlementMethod(swiftmt:MT53A? mt53A = (), swiftmt:MT53B? mt53B = (), swiftmt:MT53D? mt53D = ())
    returns camtIsoRecord:SettlementMethod1Code {
        if mt53B is swiftmt:MT53B {
            match (mt53B.PrtyIdnTyp?.content) {
                "C" => {
                    return camtIsoRecord:INGA;
                }
                "D" => {
                    return camtIsoRecord:INDA;
                }
            }
        }
        if mt53A is swiftmt:MT53A || mt53D is swiftmt:MT53D {
            return camtIsoRecord:COVE;
        }
        return camtIsoRecord:INDA;
}

# Returns the instruction code and additional information based on the input Swift MT record and a specified category 
# number.
#
# + instnCd - An optional array of `swiftmt:MT23E` objects containing instruction codes and additional information.
# + return - Returns a tuple of up to 8 elements where the relevant instruction code and additional info are populated 
# based on the category number.
# If no match is found or `instnCd` is null, returns a tuple with all elements set to `null`.
isolated function getMT103InstructionCode(swiftmt:MT23E[]? instnCd) returns 
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], string?,
    pacsIsoRecord:CategoryPurpose1Choice?] {
        if instnCd is swiftmt:MT23E[] {
            pacsIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
            pacsIsoRecord:InstructionForNextAgent1[] instrFrNxtAgt = [];
            string? serviceLevel = ();
            string purpose = "";
            foreach swiftmt:MT23E instruction in instnCd {
                match (instruction.InstrnCd.content) {
                    "REPA"|"PHON"|"TELE"|"PHOI"|"TELI" => {
                        instrFrNxtAgt.push ({
                            Cd: instruction.InstrnCd.content,
                            InstrInf: instruction.AddInfo?.content
                        });
                    }
                    "CHQB"|"HOLD"|"PHOB"|"TELB" => {
                        instrFrCdtrAgt.push({
                            Cd: instruction.InstrnCd.content,
                            InstrInf: instruction.AddInfo?.content
                        });
                    }
                    "SDVA" => {
                        serviceLevel = instruction.InstrnCd.content;
                    }
                    "INTC"|"CORT" => {
                        purpose += instruction.InstrnCd.content;
                    }
                }
            }
            if purpose.length() == 8 && !(purpose.substring(0,4).equalsIgnoreCaseAscii(purpose.substring(4))) {
                purpose = purpose.substring(0,4) + " " + purpose.substring(4);
                return [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, {Prtry:purpose}];
            }
            if purpose.length() == 0 {
                return [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel];
            }
            return [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, {Cd: purpose.substring(0,4)}];
        }
        return [];
}

# Extracts and returns specific instruction codes and additional information from the provided `MT23E` array
# based on the given `num` parameter. The function checks the instruction codes and returns a tuple with values
# based on predefined patterns and the value of `num`. If no matching instruction code is found, it returns a default tuple.
#
# + instnCd - An optional array of `MT23E` objects that contain instruction codes and additional information.
# + return - Returns a tuple of strings and/or null values corresponding to the instruction code and additional information.
# The structure of the tuple depends on the `num` parameter and the matched instruction code.
isolated function getMT101InstructionCode(swiftmt:MT23E[]? instnCd) returns 
    [painIsoRecord:InstructionForDebtorAgent1?, camtIsoRecord:InstructionForCreditorAgent3[]?, 
    painIsoRecord:ServiceLevel8Choice[]?, painIsoRecord:CategoryPurpose1Choice?] {
        if instnCd is swiftmt:MT23E[] {
            painIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
            painIsoRecord:InstructionForDebtorAgent1? instrFrDbtrAgt = ();
            painIsoRecord:ServiceLevel8Choice[] serviceLevel = [];
            string purpose = "";
            foreach swiftmt:MT23E instruction in instnCd {
                match (instruction.InstrnCd.content) {
                    "CMTO"|"CMSW"|"CMZB"|"REPA" => {
                        instrFrDbtrAgt = {
                            Cd: instruction.InstrnCd.content,
                            InstrInf: instruction.AddInfo?.content
                        };
                    }
                    "CHQB"|"PHON"|"EQUI" => {
                        instrFrCdtrAgt.push({
                            Cd: instruction.InstrnCd.content,
                            InstrInf: instruction.AddInfo?.content
                        });
                    }
                    "URGP" => {
                        serviceLevel.push({
                            Cd: instruction.InstrnCd.content
                        });
                    }
                    "CORT"|"INTC" => {
                        purpose += instruction.InstrnCd.content;
                    }
                }
            }
            if purpose.length() == 8 && !(purpose.substring(0,4).equalsIgnoreCaseAscii(purpose.substring(4))) {
                purpose = purpose.substring(0,4) + " " + purpose.substring(4);
                return [instrFrDbtrAgt, instrFrCdtrAgt, serviceLevel, {Prtry:purpose}];
            }
            if purpose.length() == 0 {
                return [instrFrDbtrAgt, instrFrCdtrAgt, serviceLevel];
            }
            return [instrFrDbtrAgt, instrFrCdtrAgt, serviceLevel, {Cd: purpose.substring(0,4)}];
        }
        return [];
}

# Retrieves a specific MT101 repeating field from a given transaction set or message based on the `typeName` provided.
#
# + block4 - The parsed block4 of MT101 SWIFT message containing multiple transactions.
# + content - An optional field of one of the types `MT50C`, `MT50F`, `MT50G`, `MT50H`, `MT50L`, `MT52A`, or `MT52C` 
# used as the return value if a match is found in the transaction set.
# + typeName - A string that specifies the type of field to retrieve (e.g., "50F", "50G").
# + return - Returns the `content` if a match is found in the transaction set; otherwise, returns the appropriate MT 
# field from the `message` object based on `typeName`.
isolated function getMT101RepeatingFields(swiftmt:MT101Block4 block4, swiftmt:MT50C?|swiftmt:MT50F?|swiftmt:MT50G?|
    swiftmt:MT50H?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C? content, string typeName) returns 
    swiftmt:MT50C?|swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C? {
        foreach swiftmt:MT101Transaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
            }
        }
        match (typeName) {
            "50F" => {
                return block4.MT50F;
            }
            "50G" => {
                return block4.MT50G;
            }
            "50H" => {
                return block4.MT50H;
            }
            "52A" => {
                return block4.MT52A;
            }
            "52C" => {
                return block4.MT52C;
            }
        }
        return ();
}

# Converts a given date in SWIFT MT format to an ISO 20022 standard date format (YYYY-MM-DD).
#
# + date - A `swiftmt:Dt` object containing the date in the format YYMMDD.
# + return - Returns the date in ISO 20022 format (YYYY-MM-DD). 
isolated function convertToISOStandardDate(swiftmt:Dt? date) returns string? {
    if date !is swiftmt:Dt {
        return ();
    }
    return YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
        date.content.substring(4, 6);
}

# Converts a given date in SWIFT MT format to an ISO 20022 standard date format (YYYY-MM-DD).
#
# + date - A `swiftmt:Dt` object containing the date in the format YYMMDD.
# + return - Returns the date in ISO 20022 format (YYYY-MM-DD).
isolated function convertToISOStandardDateMandatory(swiftmt:Dt date) returns string {
    return YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
        date.content.substring(4, 6);
}

# Converts a SWIFT MT date and time to an ISO 20022 standard date-time format.
#
# + date - The date component of the SWIFT MT message in the format YYMMDD.
# + time - The time component of the SWIFT MT message in the format HHMM.
# + isCreationDateTime - The indicator to identify whether it is creation date and time.
# + return - A string containing the date-time in ISO 20022 format, or null if the input is not valid.
isolated function convertToISOStandardDateTime(swiftmt:Dt? date, swiftmt:Tm? time, boolean isCreationDateTime = false)
    returns string? {
        if date is swiftmt:Dt && time is swiftmt:Tm {
            return YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
            date.content.substring(4, 6) + "T" + time.content.substring(0, 2) + ":" +
            time.content.substring(2, 4) + ":00";
        }
        if isCreationDateTime {
            return time:utcToString(time:utcNow()).substring(0,19);
        }
        return ();
}

# Retrieves a specific MT101 repeating field from a given transaction set or message based on the `typeName` provided.
#
# + block4 - The parsed block4 of MT102 STP SWIFT message containing multiple transactions.
# + content - An optional field of one of the types `MT26T`, `MT36`, `MT50A`, `MT50F`, `MT50K`, `MT52A`, `MT52B`, 
# `MT52C`, `MT71A`, or `MT77B` used as the return value if a match is found in the transaction set.
# + typeName - A string that specifies the type of field to retrieve (e.g., "50F", "50G").
# + return - Returns the `content` if a match is found in the transaction set; otherwise, returns the appropriate MT 
# field from the `message` object based on `typeName`.
isolated function getMT102STPRepeatingFields(swiftmt:MT102STPBlock4 block4, swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?
    |swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? content,
    string typeName) returns swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|
    swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? {
        foreach swiftmt:MT102STPTransaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) || 
                    item.toString().substring(9, 11).equalsIgnoreCaseAscii(typeName){
                    return content;
                }
            }
        }
        match (typeName) {
            "26T" => {
                return block4.MT26T;
            }
            "36" => {
                return block4.MT36;
            }
            "50F" => {
                return block4.MT50F;
            }
            "50A" => {
                return block4.MT50A;
            }
            "50K" => {
                return block4.MT50K;
            }
            "52A" => {
                return block4.MT52A;
            }
            "71A" => {
                return block4.MT71A;
            }
            "77B" => {
                return block4.MT77B;
            }
        }
        return ();
}

# Extracts and returns the content from the `MT77T` envelope based on the envelope content type.
#
# + envelopeContent - A `swiftmt:MT77T` object containing the envelope content in the `EnvCntnt` field.
# + return - Returns a tuple of strings
# Handles errors during extraction by returning a tuple of empty or null values.
isolated function getEnvelopeContent(string envelopeContent) returns [string, string?, string?] {
    if envelopeContent.length() >= 7 {
        if envelopeContent.substring(1, 5).equalsIgnoreCaseAscii("SWIF") {
            return [envelopeContent.substring(6), (), ()];
        }
        if envelopeContent.substring(1, 5).equalsIgnoreCaseAscii("IXML") {
            return ["", envelopeContent.substring(6), ()];
        }
        if envelopeContent.substring(1, 5).equalsIgnoreCaseAscii("NARR") {
            return ["", (), envelopeContent.substring(6)];
        }
        return ["", (), ()];
    }
    return ["", (), ()];
}

# Retrieves the specific field from a list of MT102 transactions based on the provided type name.
# If a matching type is found within the transaction set, the function returns the corresponding content.
#
# + block4 - The parsed block4 of MT102 SWIFT message containing multiple transactions.
# + content - The content related to the field type, which can be any of `swiftmt:MT26T`, `swiftmt:MT36`,
# `swiftmt:MT50F`, etc.
# + typeName - A string that specifies the field type name (e.g., "26T", "50A").
# + return - Returns the content of the matching type if found in the transaction set or message block. Returns `null`
# if no match is found.
isolated function getMT102RepeatingFields(swiftmt:MT102Block4 block4, swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|
    swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? content,
    string typeName) returns swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|
    swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? {
        foreach swiftmt:MT102Transaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
                if item.toString().substring(9, 11).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
            }
        }
        match (typeName) {
            "26T" => {
                return block4.MT26T;
            }
            "36" => {
                return block4.MT36;
            }
            "50F" => {
                return block4.MT50F;
            }
            "50A" => {
                return block4.MT50A;
            }
            "50K" => {
                return block4.MT50K;
            }
            "52A" => {
                return block4.MT52A;
            }
            "52B" => {
                return block4.MT52B;
            }
            "52C" => {
                return block4.MT52C;
            }
            "71A" => {
                return block4.MT71A;
            }
            "77B" => {
                return block4.MT77B;
            }
        }
        return ();
}

# Retrieves the specific field from a list of MT104 transactions based on the provided type name.
# If a matching type is found within the transaction set, the function returns the corresponding content.
#
# + block4 - The parsed block4 of MT104 SWIFT message containing multiple transactions.
# + content - The content related to the field type, which can be any of `swiftmt:MT26T`, `swiftmt:MT50C`, 
# `swiftmt:MT50K`, etc.
# + typeName - A string that specifies the field type name (e.g., "26T", "50A").
# + return - Returns the content of the matching type if found in the transaction set or message block. Returns `null` 
# if no match is found.
isolated function getMT104RepeatingFields(swiftmt:MT104Block4 block4, swiftmt:MT23E?|swiftmt:MT26T?|swiftmt:MT50A?|
    swiftmt:MT50C?|swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|
    swiftmt:MT77B? content, string typeName) returns swiftmt:MT23E?|swiftmt:MT26T?|swiftmt:MT50A?|swiftmt:MT50C?|
    swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|swiftmt:MT77B? {
        foreach swiftmt:MT104Transaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
            }
        }
        match (typeName) {
            "23E" => {
                return block4.MT23E;
            }
            "26T" => {
                return block4.MT26T;
            }
            "50A" => {
                return block4.MT50A;
            }
            "50C" => {
                return block4.MT50C;
            }
            "50K" => {
                return block4.MT50K;
            }
            "50L" => {
                return block4.MT50L;
            }
            "52A" => {
                return block4.MT52A;
            }
            "52C" => {
                return block4.MT52C;
            }
            "52D" => {
                return block4.MT52D;
            }
            "71A" => {
                return block4.MT71A;
            }
            "77B" => {
                return block4.MT77B;
            }
        }
        return ();
}

# Retrieves the specific field from a list of MT107 transactions based on the provided type name.
# If a matching type is found within the transaction set, the function returns the corresponding content.
#
# + block4 - The parsed block4 of MT107 SWIFT message containing multiple transactions.
# + content - The content related to the field type, which can be any of `swiftmt:MT26T`, `swiftmt:MT50C`, 
# `swiftmt:MT50K`, etc.
# + typeName - A string that specifies the field type name (e.g., "26T", "50A").
# + return - Returns the content of the matching type if found in the transaction set or message block. Returns `null` 
# if no match is found.
isolated function getMT107RepeatingFields(swiftmt:MT107Block4 block4, swiftmt:MT23E?|swiftmt:MT26T?|swiftmt:MT50A?|
    swiftmt:MT50C?|swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|
    swiftmt:MT77B? content, string typeName) returns swiftmt:MT23E?|swiftmt:MT26T?|swiftmt:MT50A?|swiftmt:MT50C?|
    swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|swiftmt:MT77B? {
        foreach swiftmt:MT107Transaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
            }
        }
        match (typeName) {
            "23E" => {
                return block4.MT23E;
            }
            "26T" => {
                return block4.MT26T;
            }
            "50A" => {
                return block4.MT50A;
            }
            "50C" => {
                return block4.MT50C;
            }
            "50K" => {
                return block4.MT50K;
            }
            "50L" => {
                return block4.MT50L;
            }
            "52A" => {
                return block4.MT52A;
            }
            "52C" => {
                return block4.MT52C;
            }
            "52D" => {
                return block4.MT52D;
            }
            "71A" => {
                return block4.MT71A;
            }
            "77B" => {
                return block4.MT77B;
            }
        }
        return ();
}

# Retrieves the specified repeating fields (MT72) from the transactions in an MT201 SWIFT message.
#
# + block4 - The parsed block4 of MT201 SWIFT message containing multiple transactions.
# + content - An optional MT72 content object, which can be returned if the matching field is found.
# + typeName - A string representing the specific type code to match against in the transaction data.
# + return - Returns the provided `content` if a matching field is found, or the MT72 block from the message if not.
isolated function getMT201RepeatingFields(swiftmt:MT201Block4 block4, swiftmt:MT72? content, string typeName) 
    returns swiftmt:MT72? {
        foreach swiftmt:MT201Transaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 11).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
            }
        }
        return block4.MT72;
}

# Retrieves the specified repeating fields (MT72) from the transactions in an MT203 SWIFT message.
#
# + block4 - The parsed block4 of MT203 SWIFT message containing multiple transactions.
# + content - An optional MT72 content object, which can be returned if the matching field is found.
# + typeName - A string representing the specific type code to match against in the transaction data.
# + return - Returns the provided `content` if a matching field is found, or the MT72 block from the message if not.
isolated function getMT203RepeatingFields(swiftmt:MT203Block4 block4, swiftmt:MT72? content, string typeName)
    returns swiftmt:MT72? {
        foreach swiftmt:MT203Transaction transaxion in block4.Transaction {
            foreach var item in transaxion {
                if item.toString().substring(9, 11).equalsIgnoreCaseAscii(typeName) {
                    return content;
                }
            }
        }
        return block4.MT72;
}

# Extracts and converts floor limit data from the MT34F SWIFT message into ISO 20022 Limit2 format.
#
# + floorLimit - An optional array of MT34F objects, each representing a floor limit.
# + return - Returns an array of Limit2 objects for ISO 20022, or an error if conversion fails.
isolated function getFloorLimit(swiftmt:MT34F[]? floorLimit) returns camtIsoRecord:Limit2[]?|error {
    if floorLimit is () {
       return (); 
    }
    if floorLimit.length() > 1 {
        return [
            {
                Amt: {
                    content: check convertToDecimalMandatory(floorLimit[0].Amnt),
                    Ccy: floorLimit[0].Ccy.content
                },
                CdtDbtInd: getCdtDbtFloorLimitIndicator(floorLimit[0].Cd)
            },
            {
                Amt: {
                    content: check convertToDecimalMandatory(floorLimit[1].Amnt),
                    Ccy: floorLimit[1].Ccy.content
                },
                CdtDbtInd: getCdtDbtFloorLimitIndicator(floorLimit[1].Cd)
            }
        ];
    }
    return [
        {
            Amt: {
                content: check convertToDecimalMandatory(floorLimit[0].Amnt),
                Ccy: floorLimit[0].Ccy.content
            },
            CdtDbtInd: camtIsoRecord:BOTH
        }
    ];
}

# Determines the credit or debit indicator from the SWIFT MT field and maps it to the ISO 20022 `FloorLimitType1Code`.
#
# + code - The optional SWIFT MT Cd element containing the credit or debit indicator.
# + return - Returns the ISO 20022 `FloorLimitType1Code`, which can be either DEBT (debit) or CRED (credit).
isolated function getCdtDbtFloorLimitIndicator(swiftmt:Cd? code) returns camtIsoRecord:FloorLimitType1Code {
    if code is () {
        return camtIsoRecord:DEBT;
    }
    if code.content.equalsIgnoreCaseAscii("D") {
        return camtIsoRecord:DEBT;
    }
    return camtIsoRecord:CRED;
}

# Retrieves and converts the list of MT61 statement entries into ISO 20022 `ReportEntry14` objects.
#
# This function takes an array of SWIFT MT61 statement lines, extracts relevant data such as 
# reference, value date, amount, and transaction details, and maps them to the corresponding 
# ISO 20022 `ReportEntry14` structure.
#
# + statement - The optional array of SWIFT MT61 statement lines, containing details of account transactions.
# + return - Returns an array of `ReportEntry14` objects with mapped values, or an error if conversion fails.
isolated function getEntries(swiftmt:MT61[]? statement) returns camtIsoRecord:ReportEntry14[]|error {
    camtIsoRecord:ReportEntry14[] entries = [];
    if statement is () {
        return entries;
    }
    foreach swiftmt:MT61 stmtLine in statement {
        entries.push({
            ValDt: {
                Dt: convertToISOStandardDate(stmtLine.ValDt)
            },
            CdtDbtInd: convertDbtOrCrdToISOStandard(stmtLine),
            Amt: {
                content: check convertToDecimalMandatory(stmtLine.Amnt),
                Ccy: getMandatoryFields(stmtLine.FndCd?.content)
            },
            BkTxCd: {
                Prtry: {
                    Cd: stmtLine.TranTyp.content
                }
            },
            Sts: {
                Cd: "BOOK"
            },
            AcctSvcrRef: stmtLine.RefAccSerInst?.content,
            NtryDtls: [{
                TxDtls: [{
                    Refs: {
                        EndToEndId: stmtLine.RefAccOwn.content
                    },
                    Amt: {
                        content: check convertToDecimalMandatory(stmtLine.Amnt),
                        Ccy: getMandatoryFields(stmtLine.FndCd?.content)
                    },
                    CdtDbtInd: convertDbtOrCrdToISOStandard(stmtLine),
                    AddtlTxInf: stmtLine.SpmtDtls?.content
                }]
            }]
        });
    }
    return entries;
}

# Converts the credit/debit indicator from the SWIFT MT message into the ISO 20022 `CreditDebitCode`.
#
# + content - The SWIFT MT message content (MT60F, MT62F, MT65, MT64, MT60M, MT62M, or MT61) which contains 
# the credit or debit indicator.
# + return - Returns the ISO 20022 `CreditDebitCode`, either `CRDT` or `DBIT`.
isolated function convertDbtOrCrdToISOStandard(swiftmt:MT60F|swiftmt:MT62F|swiftmt:MT65|swiftmt:MT64|swiftmt:MT60M|
    swiftmt:MT62M|swiftmt:MT61 content) returns camtIsoRecord:CreditDebitCode {
        if content.Cd.content.equalsIgnoreCaseAscii("C") || content.Cd.content.equalsIgnoreCaseAscii("RD") {
            return camtIsoRecord:CRDT;
        }
        return camtIsoRecord:DBIT;
}

# Retrieves and converts the balance information from multiple SWIFT MT message types 
# (MT60F, MT62F, MT64, MT60M, MT62M, and MT65) 
# into the corresponding ISO 20022 CashBalance8 format.
#
# This function processes various SWIFT MT balance fields including opening, closing, available, and forward balances. 
# It transforms these into ISO 20022 standard formats, identifying their type (e.g., "PRCD" for previous closing 
# balance, "CLBD" for closing balance, "ITBD" for intraday balance, and "FWAV" for forward available balance) and 
# constructing an array of CashBalance8 objects.
#
# + firstOpenBalance - The first opening balance (MT60F).
# + firstCloseBalance - The first closing balance (MT62F).
# + closeAvailableBalance - The available closing balances (MT64[]).
# + inmdOpenBalance - The intraday opening balances (MT60M[]), defaults to null if not provided.
# + inmdCloseBalance - The intraday closing balances (MT62M[]), defaults to null if not provided.
# + forwardAvailableBalance - The forward available balances (MT65[]), defaults to null if not provided.
# + return - Returns an array of `CashBalance8` objects representing the balances in ISO 20022 format or 
# an error if any conversion fails.
isolated function getBalance(swiftmt:MT60F? firstOpenBalance, swiftmt:MT62F? firstCloseBalance, swiftmt:MT64[]? 
    closeAvailableBalance, swiftmt:MT60M[]? inmdOpenBalance = (), swiftmt:MT62M[]? inmdCloseBalance = (), 
    swiftmt:MT65[]? forwardAvailableBalance = ()) returns camtIsoRecord:CashBalance8[]|error {
        camtIsoRecord:CashBalance8[] balanceArray = [];

    if firstOpenBalance is swiftmt:MT60F {
        balanceArray.push(check createBalanceRecord(firstOpenBalance, "OPBD"));
    }

    if inmdOpenBalance is swiftmt:MT60M[] {
        foreach swiftmt:MT60M inmdOpnBal in inmdOpenBalance {
            balanceArray.push(check createBalanceRecord(inmdOpnBal, "OPBD/INTM"));
        }
    }

    if firstCloseBalance is swiftmt:MT62F {
        balanceArray.push(check createBalanceRecord(firstCloseBalance, "CLBD"));
    }

    if inmdCloseBalance is swiftmt:MT62M[] {
        foreach swiftmt:MT62M inmdClsBal in inmdCloseBalance {
            balanceArray.push(check createBalanceRecord(inmdClsBal, "CLBD/INTM"));
        }
    }

    if closeAvailableBalance is swiftmt:MT64[] {
        foreach swiftmt:MT64 clsAvblBal in closeAvailableBalance {
            balanceArray.push(check createBalanceRecord(clsAvblBal, "CLAV"));
        }
    }

    if forwardAvailableBalance is swiftmt:MT65[] {
        foreach swiftmt:MT65 fwdAvblBal in forwardAvailableBalance {
            balanceArray.push(check createBalanceRecord(fwdAvblBal, "FWAV"));
        }
    }
    return balanceArray;
}

# Helper function to create a balance record
#
# + balance - The balance information
# + typeCode - The type code for the balance
# + return - A CashBalance8 record
isolated function createBalanceRecord(swiftmt:MT60F|swiftmt:MT60M|swiftmt:MT62F|swiftmt:MT62M|swiftmt:MT64|
    swiftmt:MT65 balance, string typeCode) returns camtIsoRecord:CashBalance8|error {
        return {
            Amt: {
                content: check convertToDecimalMandatory(balance.Amnt),
                Ccy: balance.Ccy.content
            },
            Dt: {Dt: convertToISOStandardDate(balance.Dt)},
            CdtDbtInd: convertDbtOrCrdToISOStandard(balance),
            Tp: {
                CdOrPrtry: {
                    Cd: typeCode
                }
            }
        };
}

# Retrieves and concatenates additional information (MT86) from the `infoToAccOwnr` array into a single string.
#
# The function processes multiple MT86 blocks of additional information, combining them into a comma-separated string 
# and returning the final concatenated result. If there is no information, it returns null.
#
# + infoToAccOwnr - An optional array of MT86 additional information blocks.
# + return - Returns the concatenated additional information as a string or null if the input is not provided or empty.
isolated function getInfoToAccOwnr(swiftmt:MT86[]? infoToAccOwnr) returns string? {
    
    if infoToAccOwnr is () {
        return ();
    }
    string finalInfo = "";
    foreach swiftmt:MT86 information in infoToAccOwnr {
        foreach int index in 0 ... information.AddInfo.length() - 1 {
            if index == information.AddInfo.length() - 1 {
                finalInfo += information.AddInfo[index].content;
            } else {
                finalInfo = finalInfo + information.AddInfo[index].content + ", ";
            }
        }
    }
    return finalInfo;
}

# Calculates the total number of credit and debit entries.
#
# The function takes in two optional `TtlNum` values representing the number of credit and debit entries 
# and returns the sum as a string or throws an error if the values are invalid.
#
# + creditEntryNum - Optional value representing the total number of credit entries.
# + debitEntryNum - Optional value representing the total number of debit entries.
# + return - Returns the total number of entries as a string, or an error if the values are not valid integers.
isolated function getTotalNumOfEntries(swiftmt:TtlNum? creditEntryNum, swiftmt:TtlNum? debitEntryNum) 
    returns string|error? {
        int total = 0;
        do {
            if creditEntryNum is swiftmt:TtlNum {
                total += check int:fromString(creditEntryNum.content);
            }
            if debitEntryNum is swiftmt:TtlNum {
                total += check int:fromString(debitEntryNum.content);
            }
            return ();
        } on fail {
            return error("Provide integer for total number of credit and debit entries.");
        }
}

# Calculates the total sum of credit and debit entry amounts.
#
# The function takes two optional `Amnt` values (credit and debit amounts), converts them to decimals, 
# and returns the sum. If any conversion fails, an error is thrown.
#
# + creditEntryAmnt - Optional value representing the total credit entry amount.
# + debitEntryAmnt - Optional value representing the total debit entry amount.
# + return - Returns the total sum of entries as a decimal, or an error if the values are not valid decimals.
isolated function getTotalSumOfEntries(swiftmt:Amnt? creditEntryAmnt, swiftmt:Amnt? debitEntryAmnt) 
    returns decimal|error? {
        decimal total = 0;
        do {
            if creditEntryAmnt is swiftmt:Amnt {
                total += check convertToDecimalMandatory(creditEntryAmnt);
            }
            if debitEntryAmnt is swiftmt:Amnt {
                total += check convertToDecimalMandatory(debitEntryAmnt);
            }
            return ();
        } on fail {
            return error("Provide decimal value for sum of credit and debit entries.");
        }
}

# Retrieves the end-to-end identification string based on available identifiers.
#
# This function checks for the presence of three optional identifiers in the following
# order: `cstmRefNum`, `remmitanceInfo`, and `transactionId`. It returns the first 
# available non-empty identifier as the end-to-end ID.
#
# + cstmRefNum - An optional custom reference number for the transaction.
# + remmitanceInfo - An optional remittance information reference.
# + transactionId - An optional transaction ID.
# + return - The first available identifier as a string, or an empty string if none are provided.
isolated function getEndToEndId(string? cstmRefNum = (), string? remmitanceInfo = (), string? transactionId = ()) 
    returns string {
        if cstmRefNum is string {
            return cstmRefNum;
        }
        if remmitanceInfo is string && remmitanceInfo.substring(1, 4).equalsIgnoreCaseAscii("ROC") {
            return remmitanceInfo.substring(5);
        }
        if transactionId is string {
            return transactionId;
        }
        return "";
}

# Retrieves the cancellation reason code from an MT79 narrative.
#
# This function checks the narrative content of an MT79 message to find and return a cancellation
# reason code that matches a predefined set of reason codes (`REASON_CODE`).
#
# + narrative - An optional `swiftmt:MT79` record containing the narrative with possible reason codes.
# + return - Returns the matching reason code as a `string` if found; otherwise, returns null.
isolated function getCancellationReasonCode(swiftmt:MT79? narrative) returns string? {
    if narrative is () {
        return ();
    }
    foreach string code in REASON_CODE {
        if code.equalsIgnoreCaseAscii(narrative.Nrtv[0].content) {
            return code;
        }
    }
    return ();
}

# Retrieves additional cancellation information from an MT79 narrative.
#
# This function extracts additional information following the cancellation reason
# code from an MT79 narrative by retrieving subsequent content in the `Nrtv` array.
#
# + narrative - An optional `swiftmt:MT79` record containing additional narrative information.
# + return - Returns an array of `string` values with additional cancellation information, or null if none is found.
isolated function getAdditionalCancellationInfo(swiftmt:MT79? narrative) returns string[]? {
    
    if narrative is () {
        return ();
    }
    string[] additionalInfo = [];
    foreach int i in 1 ... narrative.Nrtv.length() - 1 {
        additionalInfo.push(narrative.Nrtv[i].content);
    }
    return additionalInfo;
}

# Retrieves the sender's logical terminal identifier from the message.
#
# This function retrieves the first eight characters of either the `mirLogicalTerminal`
# or `logicalTerminal`, which represents the sender's identifier in an MT message.
#
# + logicalTerminal - An optional string representing the logical terminal ID of the sender.
# + mirLogicalTerminal - An optional string representing the MIR logical terminal ID of the sender.
# + return - Returns the sender's logical terminal identifier as a `string` or null if none is found.
isolated function getMessageSender(string? logicalTerminal, string? mirLogicalTerminal) returns string? {
    if mirLogicalTerminal is string {
        return mirLogicalTerminal.substring(0, 11);
    }
    if logicalTerminal is string {
        return logicalTerminal.substring(0, 11);
    }
    return ();
}

# Retrieves the receiver's logical terminal identifier from the message.
#
# This function retrieves the first eight characters of either the `receiverAddress`
# or `logicalTerminal`, representing the receiver's identifier in an MT message.
#
# + logicalTerminal - An optional string representing the logical terminal ID of the receiver.
# + receiverAddress - An optional string representing the address of the receiver.
# + return - Returns the receiver's logical terminal identifier as a `string` or null if none is found.
isolated function getMessageReceiver(string? logicalTerminal, string? receiverAddress) returns string? {
    if receiverAddress is string {
        return receiverAddress.substring(0, 11);
    }
    if logicalTerminal is string {
        return logicalTerminal.substring(0, 11);
    }
    return ();
}

# Constructs a concatenated description from an array of narrative elements.
#
# This function concatenates the content of each narrative element in the provided array,
# forming a complete description from the message's `Nrtv` array.
#
# + narrative - An optional array of `swiftmt:Nrtv` records containing narrative content.
# + return - Returns a single concatenated string of all narratives or null if no narrative is provided.
isolated function getDescriptionOfMessage(swiftmt:Nrtv[]? narrative) returns string? {
    if narrative is () {
        return ();
    }
    string description = "";
    foreach swiftmt:Nrtv narration in narrative {
        description += narration.content;
    }
    return description;
}

# Extracts justification reasons from a narration string for missing or incorrect data.
#
# This function parses a given narration string and identifies specific codes for missing or incorrect information
# based on predefined lists (`MISSING_INFO_CODE` and `INCORRECT_INFO_CODE`). Each identified reason includes
# an optional additional explanation.
#
# + narration - A `string` containing the narration to analyze.
# + return - Returns an `camtIsoRecord:MissingOrIncorrectData1` record with arrays of missing and incorrect information reasons.
isolated function getJustificationReason(string narration) returns camtIsoRecord:MissingOrIncorrectData1 {
    camtIsoRecord:UnableToApplyMissing2[] missingInfoArray = [];
    camtIsoRecord:UnableToApplyIncorrect2[] incorrectInfoArray = [];
    string[] queriesArray = getCodeAndAddtnlInfo(narration);

    foreach int i in 0 ... queriesArray.length() - 1 {
        boolean isMissingInfo = false;
        string? additionalInfo = ();
        if queriesArray[i].length() <= 2 {
            if i != queriesArray.length() - 1 {
                if queriesArray[i + 1].length() > 2 {
                    additionalInfo = queriesArray[i + 1];
                } else {
                    additionalInfo = ();
                }
            } else {
                additionalInfo = ();
            }
            foreach string code in MISSING_INFO_CODE {
                if queriesArray[i].equalsIgnoreCaseAscii(code) {
                    missingInfoArray.push({
                        Tp: {
                            Cd: code
                        },
                        AddtlMssngInf: additionalInfo
                    });
                    isMissingInfo = true;
                    break;
                }
            }
            if !isMissingInfo {
                foreach string code in INCORRECT_INFO_CODE {
                    if queriesArray[i].equalsIgnoreCaseAscii(code) {
                        incorrectInfoArray.push({
                            Tp: {
                                Cd: code
                            },
                            AddtlIncrrctInf: additionalInfo
                        });
                    }
                }
            }
        }
    }
    return {
        MssngInf: missingInfoArray,
        IncrrctInf: incorrectInfoArray
    };
}

# Extracts cancellation reasons and additional information from a narration string.
#
# + narration - A `string` containing the narration with codes and additional information.
# + return - Returns an array of `camtIsoRecord:CancellationStatusReason5` records with the following structure:
#    - `Rsn`: Contains the cancellation reason code (`Cd`).
#    - `AddtlInf` (optional): Contains additional information related to the reason, if present.
isolated function getCancellationReason(string narration) returns camtIsoRecord:CancellationStatusReason5[] {
    camtIsoRecord:CancellationStatusReason5[] cancellationReasonArray = [];
    string[] answersArray = getCodeAndAddtnlInfo(narration);

    foreach int i in 0 ... answersArray.length() - 1 {
        if answersArray[i].length() <= 2 || answersArray[i].length() == 4  {
            if i != answersArray.length() - 1 {
                if answersArray[i + 1].length() > 4 {
                    cancellationReasonArray.push({
                        Rsn: {
                            Cd:answersArray[i]
                        }, 
                        AddtlInf: [answersArray[i + 1]]
                    });
                    continue;
                } 
                cancellationReasonArray.push({
                    Rsn: {
                        Cd: answersArray[i]
                    }
                });
                continue;
            } 
            cancellationReasonArray.push({
                Rsn: {
                    Cd: answersArray[i]
                }
            });
        }
    }
    return cancellationReasonArray;
}

# Parses a narration string into an array of individual queries based on separator patterns.
#
# This function divides a narration string by recognizing sections marked by '/' characters,
# capturing information into an array of strings.
#
# + narration - A `string` containing the narration to split.
# + return - Returns an array of `string` values containing individual queries extracted from the narration.
isolated function getCodeAndAddtnlInfo(string narration) returns string[] {
    string supplementaryInfo = "";
    string[] queriesOrAnswersArray = [];
    int count = 0;

    foreach int i in 1 ... narration.length() - 1 {
        if narration.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
            if i == narration.length() - 1 {
                queriesOrAnswersArray.push(supplementaryInfo);
                break;
            }
            count += 1;
            if count == 2 || narration.substring(i + 1, i + 2).equalsIgnoreCaseAscii("/") {
                continue;
            }
            queriesOrAnswersArray.push(supplementaryInfo);
            supplementaryInfo = "";
            continue;
        }
        if count < 2 && narration.substring(i, i + 1) != "\n" {
            supplementaryInfo += narration.substring(i, i + 1);
            if i == narration.length() - 1 {
                queriesOrAnswersArray.push(supplementaryInfo);
                break;
            }
            count = 0;
            continue;
        }
        if count == 2 && narration.substring(i, i + 1) != "\n" {
            supplementaryInfo += " ".concat(narration.substring(i, i + 1));
            count = 0;
        }
    }
    return queriesOrAnswersArray;
}

# Retrieves a rejection reason code from a narration string.
#
# This function extracts a code from a specific part of the narration string and returns the corresponding
# investigation rejection reason code if it matches a value in `INVTGTN_RJCT_RSN`.
#
# + narration - A `string` containing the narration with the rejection reason code.
# + return - Returns the `camtIsoRecord:InvestigationRejection1Code` if found, or an error if the code is invalid.
isolated function getRejectedReason(string narration) returns camtIsoRecord:InvestigationRejection1Code|error {
    string? code = narration.length() >= 5 ? INVTGTN_RJCT_RSN[narration.substring(1, 5)] : ();
    if code is string {
        return code.ensureType();
    }
    return error("Provide a valid rejection reason code.");
}

# Retrieves the corresponding ISO 20022 message name based on the given SWIFT message type.
#
# + messageName - A `string?` representing the SWIFT message type (e.g., `"101"`, `"103"`, etc.).
# + return - Returns a `string` representing the corresponding ISO 20022 message name.
isolated function getOrignalMessageName(string? messageName) returns string {
    match messageName {
        "101" => {
            return "pain.001";
        }
        "102"|"103" => {
            return "pacs.008";
        }
        "104"|"107" => {
            return "pacs.003";
        }
        "200"|"201"|"202"|"202COV"|"203"|"205"|"205COV" => {
            return "pacs.009";
        }
        "204" => {
            return "pacs.010";
        }
        "210" => {
            return "camt.057";
        }
    }
    return "";
}

# Retrieves the underlying customer transaction fields from a given MT202COV or MT205COV message
# based on the specified type name.
#
# This function checks if the provided `typeName` matches any underlying customer credit transfers.
# If a match is found, it returns (). Otherwise, it retrieves and returns the appropriate field 
# based on the specified `typeName`.
#
# + ordgInstn1 - A MT52A field containing ordering institution details.
# + ordgInstn2 - A MT52D field containing ordering institution details.
# + block4 - A MT202COV or MT 205COV block4 containing transaction details. 
# + return - Returns a tuple of MT52 field.
isolated function getUnderlyingCustomerTransactionField52(swiftmt:MT52A? ordgInstn1, swiftmt:MT52D? ordgInstn2, 
    swiftmt:MT202COVBlock4|swiftmt:MT205COVBlock4 block4) returns [swiftmt:MT52A?, swiftmt:MT52D?] {
        if ordgInstn1 is swiftmt:MT52A {
            return [ordgInstn1, ()];
        }
        if ordgInstn2 is swiftmt:MT52D {
            return [(), ordgInstn2] ;
        }
        return [block4.MT52A, block4.MT52D];
}

# Retrieves the underlying customer transaction fields from a given MT202COV or MT205COV message
# based on the specified type name.
#
# This function checks if the provided `typeName` matches any underlying customer credit transfers.
# If a match is found, it returns (). Otherwise, it retrieves and returns the appropriate field 
# based on the specified `typeName`.
#
# + cdtrAgt1 - A MT57A field containing ordering institution details.
# + cdtrAgt2 - A MT57B field containing ordering institution details.
# + cdtrAgt3 - A MT57C field containing ordering institution details.
# + cdtrAgt4 - A MT57D field containing ordering institution details.
# + block4 - A MT202COV or MT 205COV block4 containing transaction details. 
# + return - Returns a tuple of MT57 field.
isolated function getUnderlyingCustomerTransactionField57(swiftmt:MT57A? cdtrAgt1, swiftmt:MT57B? cdtrAgt2, 
    swiftmt:MT57C? cdtrAgt3, swiftmt:MT57D? cdtrAgt4, swiftmt:MT202COVBlock4|swiftmt:MT205COVBlock4 block4) 
    returns [swiftmt:MT57A?, swiftmt:MT57B?, swiftmt:MT57C?, swiftmt:MT57D?] {
        if cdtrAgt1 is swiftmt:MT57A {
            return [cdtrAgt1, (), (), ()];
        }
        if cdtrAgt2 is swiftmt:MT57B {
            return [(), cdtrAgt2, (), ()] ;
        }
        if cdtrAgt3 is swiftmt:MT57C {
            return [ (), (), cdtrAgt3, ()];
        }
        if cdtrAgt4 is swiftmt:MT57D {
            return [(), (), (), cdtrAgt4] ;
        }
        return [block4.MT58A, (), (), block4.MT58D];
}

# Extracts and returns other identification details for the given accounts.
#
# + account1 - An optional `swiftmt:Acc` record representing the first account.
# + account2 - An optional `swiftmt:Acc` record representing the second account.
# + account3 - An optional `swiftmt:Acc` record representing the third account (default is `()`).
# + prtyIdn - An optional `swiftmt:PrtyIdn` record representing partyIdentifier
# + isDebtor - To indicate whether it is debtor or creditor.
# + return - An optional array of `GenericOrganisationIdentification3` records containing the identification details.
# If no accounts (`account1`, `account2`, or `account3`) are provided, a record with the ID `"NOTPROVIDED"` and 
# the scheme name `"TxId"` is returned.
# Returns `()` if at least one of the accounts is provided.
isolated function getOtherId(swiftmt:Acc? account1, swiftmt:Acc? account2, swiftmt:Acc? account3 = (), 
    swiftmt:PrtyIdn? prtyIdn = (), boolean isDebtor = false) 
    returns camtIsoRecord:GenericOrganisationIdentification3[]? {
        if account1 is swiftmt:Acc || account2 is swiftmt:Acc || account3 is swiftmt:Acc || prtyIdn is swiftmt:PrtyIdn {
            return ();
        }
        if isDebtor {
            return [{
                Id: "NOTPROVIDED",
                SchmeNm: {
                    Cd: "TxId"
                }
            }];
        }
        return [{
            Id: "NOTPROVIDED"
        }];
}

# Extracts a status confirmation code from the given narration string if certain conditions are met.
#
# + narration - A `string` containing the narration from which the status confirmation code is to be extracted.
# + return -  A `string` containing the extracted status confirmation code (substring from the 1st to the 5th character) 
# if the narration satisfies the following conditions:The length of the narration is greater than 4.
# the narration starts with any of the prefixes: `"/CNCL"`, `"/PDCR"`, or `"RJCR"`.
# Returns () if the narration does not meet the above conditions.
isolated function getStatusConfirmation(string narration) returns string? {
    if narration.length() > 4 && (narration.startsWith("/CNCL") || narration.startsWith("/PDCR") 
    || narration.startsWith("RJCR")) {
        return narration.substring(1,5);
    }
    return ();
}

isolated function getDebtorAgent(swiftmt:MT910Block4 block4) returns 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? {
        if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
            return ();
        }
        return getFinancialInstitution(block4.MT52A?.IdnCd?.content, block4.MT52D?.Nm, block4.MT52A?.PrtyIdn,
            block4.MT52D?.PrtyIdn, (), (), block4.MT52D?.AdrsLine); 
} 

isolated function getDebtorAgent2(swiftmt:MT910Block4 block4) returns 
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? {
        if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
            return getFinancialInstitution(block4.MT52A?.IdnCd?.content, block4.MT52D?.Nm, block4.MT52A?.PrtyIdn,
                block4.MT52D?.PrtyIdn, (), (), block4.MT52D?.AdrsLine);
        } 
        return ();
} 

isolated function getDebtor(swiftmt:MT910Block4 block4) returns pacsIsoRecord:PartyIdentification272? {
    if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
        return getDebtorOrCreditor(block4.MT50A?.IdnCd, block4.MT50A?.Acc,
            block4.MT50K?.Acc, (), block4.MT50F?.PrtyIdn,
            block4.MT50F?.Nm, block4.MT50K?.Nm,
            block4.MT50F?.AdrsLine, block4.MT50K?.AdrsLine,
            block4.MT50F?.CntyNTw, true);
    }
    return ();
} 

isolated function getDebtorAccount(swiftmt:MT910Block4 block4) returns pacsIsoRecord:CashAccount40? {
    if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
        return getCashAccount2(block4.MT50A?.Acc, block4.MT50K?.Acc, (), block4.MT50F?.PrtyIdn);
    }
    return getCashAccount(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn);
} 

isolated function getDebtorForPacs004(swiftmt:MT50A? field50A, swiftmt:MT50F? field50F, swiftmt:MT50K? field50K, string? regulatoryReport) returns pacsIsoRecord:Party50Choice {
    if field50K?.Acc?.content == "/NOTPROVIDED" {
        return {
            Agt: {
                FinInstnId: {
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getName(field50K?.Nm)}},
                    PstlAdr: {
                        AdrLine: getAddressLine(field50K?.AdrsLine)}}}};
    }

    return {
        Pty: {
            Id: {
                OrgId: {
                    AnyBIC: field50A?.IdnCd?.content,
                    Othr: getOtherId((), ())},
                PrvtId: {
                    Othr: [{
                        Id: getPartyIdentifierOrAccount(field50F?.PrtyIdn)[0],
                        SchmeNm: {
                            Cd: getPartyIdentifierOrAccount(field50F?.PrtyIdn)[3]
                        },
                        Issr: getPartyIdentifierOrAccount(field50F?.PrtyIdn)[4]
                        }]}},
            Nm: getName(field50F?.Nm, field50K?.Nm),
            CtryOfRes: getCountryOfResidence(regulatoryReport, true),
            PstlAdr: {
                AdrLine: getAddressLine(field50F?.AdrsLine, field50K?.AdrsLine),
                Ctry: getCountryAndTown(field50F?.CntyNTw)[0],
                TwnNm: getCountryAndTown(field50F?.CntyNTw)[1]}}};
}

isolated function getCreditorForPacs004(swiftmt:MT59? field59, swiftmt:MT59A? field59A, swiftmt:MT59F? field59F, string? regulatoryReport) returns pacsIsoRecord:Party50Choice {
    if field59?.Acc?.content == "/NOTPROVIDED" {
        return {
            Agt: {
                FinInstnId: {
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getName(field59?.Nm)}},
                    PstlAdr: {
                        AdrLine: getAddressLine(field59?.AdrsLine)}}}};
    }
    return {
        Pty: {
            Id: {
                OrgId: {
                    AnyBIC: field59A?.IdnCd?.content,
                    Othr: getOtherId((), ())}},
            Nm: getName(field59F?.Nm, field59?.Nm),
            CtryOfRes: getCountryOfResidence(regulatoryReport, false),
            PstlAdr: {
                AdrLine: getAddressLine(field59F?.AdrsLine, field59?.AdrsLine),
                Ctry: getCountryAndTown(field59F?.CntyNTw)[0],
                TwnNm: getCountryAndTown(field59F?.CntyNTw)[1]}}};
}

isolated function get103RETNSndRcvrInfoForPacs004(swiftmt:MT72? sndRcvInfo) returns 
    [string?, string?, pacsIsoRecord:PaymentReturnReason7[], pacsIsoRecord:Charges16[]]|error {
    if sndRcvInfo is swiftmt:MT72 {
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        int index = 0;
        pacsIsoRecord:PaymentReturnReason7[] returnReasonArray = [];
        pacsIsoRecord:Charges16[] chargesInfoArray = [];
        [string?, string?] [instructionId, endToEndId] = [];
        foreach int i in 0 ... infoArray.length() - 1 {
            if index == i {
                continue;
            }
            if i + 1 <= infoArray.length() - 1 && !(infoArray[i + 1].matches(re `^[A-Z]{2,8}$`)) {
                index = i + 1;
                if infoArray[i].equalsIgnoreCaseAscii("MREF") {
                    instructionId = infoArray[i + 1];
                } else if infoArray[i].equalsIgnoreCaseAscii("TREF") {
                    endToEndId = infoArray[i + 1];
                } else if infoArray[i].equalsIgnoreCaseAscii("CHGS") && infoArray[i + 1].matches(re `^[A-Z]{3}\d{1,15},\d{0,5}$`) {
                    swiftmt:Amnt amount = {content: infoArray[i + 1].substring(3)};
                    chargesInfoArray.push({
                        Amt: {content: check convertToDecimalMandatory(amount), 
                            Ccy: infoArray[i + 1].substring(0,3)},
                        Agt: {FinInstnId: {Nm: "NOTPROVIDED", PstlAdr: {AdrLine: ["NOTPROVIDED"]}}
                        }
                    });
                } else if infoArray[i].equalsIgnoreCaseAscii("TEXT") {
                    returnReasonArray.push({
                        AddtlInf: [infoArray[i + 1]]
                    });
                } else if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}`) {
                    returnReasonArray.push({
                        Rsn: {Cd: infoArray[i]},
                        AddtlInf: [infoArray[i + 1]]
                    });
                }
                continue;
            }
            if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}$`) {
                returnReasonArray.push({
                    Rsn: {Cd: infoArray[i]}
                });
            }
        } 
        return [instructionId, endToEndId, returnReasonArray, chargesInfoArray];
    }
    return [];
}

isolated function getChargesInfo (pacsIsoRecord:Charges16[]? charges, pacsIsoRecord:Charges16[] sndRcvrInfoChrgs) returns pacsIsoRecord:Charges16[]? {
    if charges is pacsIsoRecord:Charges16[] && charges.length() > 0 {
        return charges;
    }
    if sndRcvrInfoChrgs.length() > 0 {
        return sndRcvrInfoChrgs;
    }
    return ();
}

isolated function getNameForCdtrAgtInPacs004(swiftmt:MT57B? field57B, string? name, string field57Acct, string[]? field57AdrsLine) returns string? {
    string? field57PrtyIdn = getPartyIdentifierOrAccount2(field57B?.PrtyIdn)[0];
    if field57B?.PrtyIdn?.content !is () {
        if field57PrtyIdn is () && field57AdrsLine is string[] {
            return "NOTPROVIDED";
        }
        if field57Acct != "" {
            return "/" + field57Acct;
        }
    }

    return name;
}

isolated function getAddressForCdtrAgtInPacs004(string field57Acct, string[]? field57AdrsLine) returns string[]? {
    if field57Acct != "" && field57AdrsLine is () {
        return ["NOTPROVIDED"];
    }
    return field57AdrsLine;
}

isolated function get202Or205RETNSndRcvrInfoForPacs004(swiftmt:MT72? sndRcvInfo) returns [string?, pacsIsoRecord:PaymentReturnReason7[]] {
    if sndRcvInfo is swiftmt:MT72 {
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        int index = 0;
        pacsIsoRecord:PaymentReturnReason7[] returnReasonArray = [];
        string? instructionId = ();
        foreach int i in 0 ... infoArray.length() - 1 {
            if index == i {
                continue;
            }
            if i + 1 <= infoArray.length() - 1 && !(infoArray[i + 1].matches(re `^[A-Z]{2,8}$`)) {
                index = i + 1;
                if infoArray[i].equalsIgnoreCaseAscii("MREF") {
                    instructionId = infoArray[i + 1];
                } else if infoArray[i].equalsIgnoreCaseAscii("TEXT") {
                    returnReasonArray.push({
                        AddtlInf: [infoArray[i + 1]]
                    });
                } else if infoArray[i].matches(re `^[A-Z]{2}[0-9]{2}$`) {
                    returnReasonArray.push({
                        Rsn: {Cd: infoArray[i]},
                        AddtlInf: [infoArray[i + 1]]
                    });
                }
                continue;
            }
            if infoArray[i].matches(re `^[A-Z]{2}[0-9]{2}$`) {
                returnReasonArray.push({
                    Rsn: {Cd: infoArray[i]}
                });
            }
        } 
        return [instructionId, returnReasonArray];
    }
    return [];
}

isolated function getCountryOfResidence(string? regulatoryReport, boolean isDebtor) returns string? {
    if regulatoryReport is string && regulatoryReport.length() > 11 {
        if regulatoryReport.substring(1,9) == "ORDERRES" && isDebtor {
            return regulatoryReport.substring(10, 12);
        } 
        if regulatoryReport.substring(1,9) == "BENEFRES" && !isDebtor {
            return regulatoryReport.substring(10, 12);
        }
    }
    return ();
}

isolated function getInfoFromField79ForPacs002(swiftmt:Nrtv[]? narrativeArray) returns 
    [pacsIsoRecord:Max105Text[], string?, string?, string?, string?] {
        if narrativeArray is swiftmt:Nrtv[] {
            [pacsIsoRecord:Max105Text[], string?, string?, string?, string?] [addtnlInfo, messageId, endToEndId, uetr,
                reason] = [];
            foreach swiftmt:Nrtv narration in narrativeArray {
                if narration.content.startsWith("/MREF/") && narration.content.length() > 6 {
                    messageId = narration.content.substring(6);
                }
                if narration.content.startsWith("/TREF/") && narration.content.length() > 6 {
                    endToEndId = narration.content.substring(6);
                }
                if narration.content.startsWith("/TEXT//UETR/") && narration.content.length() > 12 {
                    uetr = narration.content.substring(12);
                }
                if !narration.content.startsWith("/REJT/") && narration.content.length() > 4 
                    && narration.content.substring(1,5).matches(re `[A-Z]{2}[0-9]{2}`) {
                        reason = narration.content.substring(1,5);
                        if narration.content.length() > 6 {
                            addtnlInfo.push(narration.content.substring(6));
                        }
                }
                if narration.content.startsWith("/TEXT/") && !narration.content.includes("/UETR/") && 
                    narration.content.length() > 6 {
                        addtnlInfo.push(narration.content.substring(6));
                    }
            } 
            return [addtnlInfo, messageId, endToEndId, uetr, reason];
        }
        return [];
}

isolated function getCashAccount(swiftmt:PrtyIdn? acc1, swiftmt:PrtyIdn? acc2, swiftmt:PrtyIdn? acc3 = (), swiftmt:PrtyIdn? acc4 = ()) returns pacsIsoRecord:CashAccount40? {
    [string?, string?, string?] [_, iban, bban] = getPartyIdentifierOrAccount2(acc1, acc2, acc3, acc4);
    if iban is () && bban is () {
        return ();
    }
    return {
        Id: {
            IBAN: iban,
            Othr: {
                Id: bban
                // SchmeNm: {
                //     Cd: getSchemaCode(prtyIdn1 = acc1, prtyIdn2 = acc2, prtyIdn3 = acc3, prtyIdn4 = acc4)
                // }
            }
        }
    }; 
}

isolated function getFinancialInstitution(string? idnCd, swiftmt:Nm[]? name, swiftmt:PrtyIdn? prtyIdn1, swiftmt:PrtyIdn? prtyIdn2,
    swiftmt:PrtyIdn? prtyIdn3 = (), swiftmt:PrtyIdn? prtyIdn4 = (), swiftmt:AdrsLine[]? adrsLine1 = (),
    string? adrsLine2 = ()) returns pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? {
        string? partyIdentifier = getPartyIdentifierOrAccount2(prtyIdn1, prtyIdn2, prtyIdn3, prtyIdn4)[0];
        string[]? adrsLine = getAddressLine(adrsLine1, address3 = adrsLine2);
        
        if idnCd is string || name is swiftmt:Nm[] || partyIdentifier is string || adrsLine is string[] {
            return {
                FinInstnId: {
                    BICFI: idnCd,
                    ClrSysMmbId: partyIdentifier is () ? () : {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: partyIdentifier
                        }
                    },
                    Nm: getName(name),
                    PstlAdr: adrsLine is () ? () : {
                        AdrLine: adrsLine
                    }
                }
            };
        }
        return ();
}

isolated function getCashAccount2(swiftmt:Acc? acc1, swiftmt:Acc? acc2, swiftmt:Acc? acc3 = (), swiftmt:PrtyIdn? acc4 = ()) returns pacsIsoRecord:CashAccount40? {
    string? iban = getAccountId(validateAccountNumber(acc1, acc2, acc3)[0], getPartyIdentifierOrAccount(acc4)[1]);
    string? bban = getAccountId(validateAccountNumber(acc1, acc2, acc3)[1], getPartyIdentifierOrAccount(acc4)[2]);
    if iban is () && bban is () {
        return ();
    }
    return {
        Id: {
            IBAN: iban,
            Othr: {
                Id: bban,
                SchmeNm: bban == "NOTPROVIDED" ? {
                    Cd: "TXID"
                } : ()
            }
        }
    }; 
}

isolated function getDebtorOrCreditor(swiftmt:IdnCd? identifierCode, swiftmt:Acc? acc1, swiftmt:Acc? acc2,
    swiftmt:Acc? acc3, swiftmt:PrtyIdn? prtyIdn, swiftmt:Nm[]? name1, swiftmt:Nm[]? name2, swiftmt:AdrsLine[]? address1,
    swiftmt:AdrsLine[]? address2, swiftmt:CntyNTw[]? country = (), boolean isDebtor = false, swiftmt:Nrtv? narrative = ()) returns pacsIsoRecord:PartyIdentification272 {
        pacsIsoRecord:GenericOrganisationIdentification3[]? otherId = getOtherId(acc1, acc2, acc3, prtyIdn, isDebtor);
        [string?, string?, string?, string?, string?] [partyIdentifier, _, _, code, issr] = 
            getPartyIdentifierOrAccount(prtyIdn);
        string[]? adrsLine = getAddressLineForDbtrOrCdtr(address1, address2, country);
        
        return {
            Id: identifierCode?.content is () && otherId is () && partyIdentifier is () ? () : { 
                OrgId: identifierCode?.content is () && otherId is () ? () : {
                    AnyBIC: identifierCode?.content,
                    Othr: otherId
                },
                PrvtId: partyIdentifier is () && code is () && issr is () ? () : {
                    Othr: [
                        {
                            Id: partyIdentifier,
                            SchmeNm: code is () ? () : {
                                Cd: code
                            },
                            Issr: issr
                        }
                    ]
                }
            },
            CtryOfRes: getCountryOfResidence(narrative?.content, isDebtor),
            Nm: getName(name1, name2),
            PstlAdr: adrsLine is () ? () : {
                AdrLine: adrsLine
            }
        };
}

# Extracts and returns address lines from the provided `AdrsLine` arrays.
# It first checks if the first address array (`address1`) is available and uses it;
# if not, it checks the second address array (`address2`). If neither is available,
# it returns `null`. The function aggregates all address lines into a string array.
#
# + address1 - An optional array of `AdrsLine` that may contain address lines.
# + address2 - An optional array of `AdrsLine` that may also contain address lines (default is `null`).
# + country - An optional array of country of residence.
# + return - Returns an array of strings representing the address lines if any address lines are found;
# otherwise, returns `null`.
isolated function getAddressLineForDbtrOrCdtr(swiftmt:AdrsLine[]? address1, swiftmt:AdrsLine[]? address2 = (),
    swiftmt:CntyNTw[]? country = ()) returns string[]? {
        swiftmt:AdrsLine[] finalAddress = [];
        string[] addressLine = [];
        boolean isOptionF = false;
        if address1 is swiftmt:AdrsLine[] {
            finalAddress = address1;
            isOptionF = true;
        } else if address2 is swiftmt:AdrsLine[] {
            finalAddress = address2;
        } else {
            return ();
        }
        if isOptionF {
            foreach swiftmt:AdrsLine address in finalAddress {
                addressLine.push("2/" + address.content);
            }
            if country is swiftmt:CntyNTw[] {
                addressLine.push("3/" + country[0].content);
            }
            return addressLine;
        }
        return from swiftmt:AdrsLine adrsLine in finalAddress
            select adrsLine.content;
}

isolated function getChargesAmount(string narration) returns camtIsoRecord:ChargesBreakdown1[]|error{
    string amount = "";
    string currency = "";
    string code = "";
    boolean isAmount = false;

    foreach int i in 1 ... narration.length() - 1{
        if isAmount && (narration.substring(i, i + 1).matches(re `^[0-9]$`) || narration.substring(i, i + 1) == ",") {
            amount += narration.substring(i, i + 1);
            continue;
        }
        if narration.substring(i, i + 1) == "/" {
            if isAmount {
                break;
            }
            if narration.length() - 1 >= i + 3 {
                currency = narration.substring(i + 1, i + 4);
            }
            code = narration.substring(1, i);
            isAmount = true;
        }
    }
    if amount.endsWith(",") {
        amount = amount.substring(0, amount.length() - 1);
    } else {
        amount = regex:replace(amount, "\\,", ".");
    }
    return [{Amt: {content: check decimal:fromString(amount), Ccy: currency},
        Tp: {Cd: code},
        CdtDbtInd: "DBIT"}];
};

isolated function get103REJTSndRcvrInfoForPacs004(swiftmt:MT72? sndRcvInfo) returns 
    [string?, string?, pacsIsoRecord:StatusReasonInformation14[]]|error {
    if sndRcvInfo is swiftmt:MT72 {
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        int index = 0;
        pacsIsoRecord:PaymentReturnReason7[] statusReasonArray = [];
        [string?, string?] [instructionId, endToEndId] = [];
        foreach int i in 0 ... infoArray.length() - 1 {
            if index == i {
                continue;
            }
            if i + 1 <= infoArray.length() - 1 && !(infoArray[i + 1].matches(re `^[A-Z]{2,8}$`)) {
                index = i + 1;
                if infoArray[i].equalsIgnoreCaseAscii("MREF") {
                    instructionId = infoArray[i + 1];
                } else if infoArray[i].equalsIgnoreCaseAscii("TREF") {
                    endToEndId = infoArray[i + 1];
                } else if infoArray[i].equalsIgnoreCaseAscii("TEXT") {
                    statusReasonArray.push({
                        AddtlInf: [infoArray[i + 1]]
                    });
                } else if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}`) {
                    statusReasonArray.push({
                        Rsn: {Cd: infoArray[i]},
                        AddtlInf: [infoArray[i + 1]]
                    });
                }
                continue;
            }
            if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}$`) {
                statusReasonArray.push({
                    Rsn: {Cd: infoArray[i]}
                });
            }
        } 
        return [instructionId, endToEndId, statusReasonArray];
    }
    return [];
}

isolated function getOrgnlUETR(string? narration) returns string? {
    if narration is string && narration.startsWith("/UETR/") && narration.length() > 6 {
        string narrative = "";
        foreach int i in 6 ... narration.length() - 1 {
            if narration.substring(i, i + 1) == "/" {
                continue;
            }
            narrative += narration.substring(i, i + 1);
        }
    }
    return ();
}

isolated function getChrgRqstrAndInstrFrAgt(string? narration) returns [string?, string?, string?] {
    if narration is string {
        string[] infoArray = getCodeAndAddtnlInfo(narration);
        [string?, string?, string?] [chrgRqstr, instr, info] = [];

        foreach int i in 0 ... infoArray.length() - 1 {
            if infoArray[i].equalsIgnoreCaseAscii("CHRQ") {
                chrgRqstr = infoArray.length() > i ? infoArray[i + 1] : ();
                continue;
            }
            if infoArray[i].length() == 4 {
                instr = infoArray[i];
                info = infoArray.length() > i && !infoArray[i + 1].equalsIgnoreCaseAscii("CHRQ") ?
                    infoArray[i + 1] : ();
            }
        }
        return [chrgRqstr, instr, info];
    }
    return [];
}

// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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
import ballerina/log;
import ballerina/lang.regexp;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transform MT104 message to corresponding ISO20022 XML format.
#
# + message - MT104 SWIFT message to transform
# + return - XML message or error
isolated function getMT104TransformFunction(swiftmt:MT104Message message) returns xml|error {
    log:printDebug("Starting getMT104TransformFunction with message type MT104");
    if message.block4.MT23E?.InstrnCd?.content is () {
        log:printDebug("No instruction code found in message, handling as transaction level instruction");
        return handleMT104Transaction(message);
    }
    log:printDebug("Instruction code found in message, handling as message level instruction");
    return handleMT104MessageInstruction(message);
}

# Handle MT104 transaction processing.
#
# + message - MT104 message to process
# + return - XML message or error
isolated function handleMT104Transaction(swiftmt:MT104Message message) returns xml|error {
    log:printDebug("Starting handleMT104Transaction for MT104 message");
    foreach swiftmt:MT104Transaction transaxion in message.block4.Transaction {
        if transaxion.MT23E is swiftmt:MT23E {
            string instructionCode = check transaxion.MT23E?.InstrnCd?.content.ensureType(string);
            log:printDebug("Found instruction code in transaction: " + instructionCode);

            if instructionCode.equalsIgnoreCaseAscii("RTND") {
                log:printDebug("Rejecting message due to RTND instruction code");
                return error("Return direct debit transfer message is not supported.");
            }

            if isValidInstructionCode(instructionCode) {
                log:printDebug("Valid instruction code found for pacs.003: " + instructionCode);
                return xmldata:toXml(check transformMT104ToPacs003(message));
            }

            if isValidInstructionCode(instructionCode, true) {
                log:printDebug("Valid instruction code found for pain.008: " + instructionCode);
                return xmldata:toXml(check transformMT104ToPain008(message));
            }
        }
    }
    log:printDebug("No valid instruction code found in message");
    return error("Instruction code is required to identify ISO 20022 message type.");
}

# Handle MT104 message instruction processing.
#
# + message - MT104 message to process
# + return - XML message or error
isolated function handleMT104MessageInstruction(swiftmt:MT104Message message) returns xml|error {
    log:printDebug("Starting handleMT104MessageInstruction for MT104 message");
    string instructionCode = check message.block4.MT23E?.InstrnCd?.content.ensureType(string);
    log:printDebug("Found message level instruction code: " + instructionCode);

    if isValidInstructionCode(instructionCode) {
        log:printDebug("Valid instruction code found for pacs.003: " + instructionCode);
        return xmldata:toXml(check transformMT104ToPacs003(message), {textFieldName: "content"});
    }

    if isValidInstructionCode(instructionCode, true) {
        log:printDebug("Valid instruction code found for pain.008: " + instructionCode);
        return xmldata:toXml(check transformMT104ToPain008(message), {textFieldName: "content"});
    }

    log:printDebug("Message rejected due to unsupported instruction code");
    return error("Return direct debit transfer message is not supported.");
}

# Transform MT107 message to corresponding ISO20022 XML format.
#
# + message - The MT107 SWIFT message to be transformed
# + return - Returns the transformed XML message or an error if transformation fails
isolated function getMT107TransformFunction(swiftmt:MT107Message message) returns xml|error {
    log:printDebug("Starting getMT107TransformFunction with message type MT107");
    // Handle message level instruction code
    if message.block4.MT23E?.InstrnCd?.content is string {
        string msgInstructionCode = check message.block4.MT23E?.InstrnCd?.content.ensureType(string);
        log:printDebug("Found message level instruction code: " + msgInstructionCode);
        return check handleMessageLevelInstruction(message, msgInstructionCode);
    }

    // Handle transaction level instruction codes
    log:printDebug("No message level instruction code found, checking transaction level codes");
    foreach swiftmt:MT107Transaction transaxion in message.block4.Transaction {
        if transaxion.MT23E is swiftmt:MT23E {
            string? txnInstructionCode = check transaxion.MT23E?.InstrnCd?.content.ensureType(string);
            if txnInstructionCode is string {
                log:printDebug("Found transaction level instruction code: " + txnInstructionCode);
                if txnInstructionCode.equalsIgnoreCaseAscii(RTND_CODE) {
                    log:printDebug("Rejecting message due to RTND instruction code");
                    return error(UNSUPPORTED_MSG);
                }
                if isValidInstructionCode(txnInstructionCode) {
                    log:printDebug("Valid instruction code found for pacs.003: " + txnInstructionCode);
                    return xmldata:toXml(check transformMT107ToPacs003(message));
                }
            }
        }
    }

    // Default transformation if no specific instruction code found
    log:printDebug("No specific instruction code found, using default transformation to pacs.003");
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
    log:printDebug("Starting handleMessageLevelInstruction with instruction code: " + instructionCode);
    if isValidInstructionCode(instructionCode) {
        log:printDebug("Valid instruction code found for pacs.003: " + instructionCode);
        return xmldata:toXml(check transformMT107ToPacs003(message));
    }
    log:printDebug("Invalid or unsupported instruction code");
    return error(UNSUPPORTED_MSG);
}

# Transform MTn96 message to corresponding ISO20022 XML format.
#
# + message - MTn96 SWIFT message to transform
# + return - XML message or error if transformation fails
isolated function getMTn96TransformFunction(swiftmt:MTn96Message message) returns xml|error {
    log:printDebug("Starting getMTn96TransformFunction for MTn96 message");

    if message.block4.MT76?.Nrtv.content.length() < 5 {
        log:printDebug("Invalid MTn96 message: Missing answer code");
        return error("Invalid MTn96 message: Missing answer code.");
    }

    string answerCode = message.block4.MT76.Nrtv.content.substring(1, 5);
    log:printDebug("Extracted answer code from message: " + answerCode);

    xml result = check transformBasedOnAnswerCode(message, answerCode);
    log:printDebug("Completed MTn96 transformation");
    return result;
}

# Transform message based on answer code
#
# + message - MTn96 message to transform
# + answerCode - Answer code from the message
# + return - Transformed XML or error
isolated function transformBasedOnAnswerCode(swiftmt:MTn96Message message, string answerCode) returns xml|error {
    log:printDebug("Starting transformBasedOnAnswerCode with answerCode: " + answerCode);

    if isAnswerCodeValid(answerCode) {
        log:printDebug("Answer code is valid for camt.031: " + answerCode);
        return xmldata:toXml(check transformMTn96ToCamt031(message));
    }

    log:printDebug("Answer code not valid for camt.031, transforming to camt.028: " + answerCode);
    return xmldata:toXml(check transformMTn96ToCamt028(message));
}

# Validate answer code
#
# + code - Answer code to validate
# + return - True if valid, false otherwise
isolated function isAnswerCodeValid(string code) returns boolean {
    log:printDebug("Checking if answer code is valid: " + code);

    boolean result = code.equalsIgnoreCaseAscii(CANCEL_CODE) ||
            code.equalsIgnoreCaseAscii(PENDING_CANCEL_CODE) ||
            code.equalsIgnoreCaseAscii(REJECT_CODE);

    log:printDebug("Answer code " + code + " is valid: " + result.toString());
    return result;
}

# Validates if the given instruction code is valid based on context
#
# + code - Instruction code to validate
# + checkForRequest - Whether to check for request-specific codes
# + return - True if valid, false otherwise
isolated function isValidInstructionCode(string code, boolean checkForRequest = false) returns boolean {
    log:printDebug("Validating instruction code: " + code + ", checkForRequest: " + checkForRequest.toString());

    string[] validCodes = [AUTH_CODE, NAUT_CODE, OTHR_CODE];

    if checkForRequest {
        validCodes.push(RFDD_CODE);
        log:printDebug("Added request-specific code to valid codes");
    }

    boolean result = validCodes.some(validCode => code.equalsIgnoreCaseAscii(validCode));
    log:printDebug("Instruction code " + code + " is valid: " + result.toString());
    return result;
}

# Converts SWIFT amount/rate to decimal value
#
# + value - The SWIFT amount or rate to convert
# + return - Decimal value or error if conversion fails
isolated function convertToDecimal(swiftmt:Amnt?|swiftmt:Rt? value) returns decimal|error? {
    log:printDebug("Starting convertToDecimal with value: " + value.toString());

    if value is () {
        log:printDebug("Value is null, returning null");
        return ();
    }

    do {
        string numericString = value.content;
        log:printDebug("Converting numeric string: " + numericString);

        int? lastCommaIndex = numericString.lastIndexOf(",");

        if lastCommaIndex is int && lastCommaIndex == numericString.length() - 1 {
            log:printDebug("Found trailing comma, removing it before conversion");
            decimal result = check decimal:fromString(numericString.substring(0, lastCommaIndex));
            log:printDebug("Converted value: " + result.toString());
            return result;
        }

        log:printDebug("Converting with comma replacement");
        decimal result = check decimal:fromString(regexp:replace(re `\\,`, numericString, "."));
        log:printDebug("Converted value: " + result.toString());
        return result;
    } on fail {
        log:printDebug("Error converting decimal value: " + value.toString());
        return error(DECIMAL_ERROR);
    }
}

# Converts the given `Amnt` or `Rt` content to a `decimal` value, handling the conversion from a string representation
# that may include commas as decimal separators.
#
# + value - The optional `Amnt` or `Rt` content containing the string value to be converted to a decimal.
# + return - Returns the converted decimal value.
isolated function convertToDecimalMandatory(swiftmt:Amnt?|swiftmt:Rt? value) returns decimal|error {
    log:printDebug("Starting convertToDecimalMandatory with value: " + value.toString());

    if value is () {
        log:printDebug("Value is null, returning 0");
        return 0;
    }

    do {
        string numericString = value.content;
        log:printDebug("Converting numeric string: " + numericString);

        int? lastCommaIndex = numericString.lastIndexOf(",");

        if lastCommaIndex is int && lastCommaIndex == numericString.length() - 1 {
            log:printDebug("Found trailing comma, removing it before conversion");
            decimal result = check decimal:fromString(numericString.substring(0, lastCommaIndex));
            log:printDebug("Converted value: " + result.toString());
            return result;
        }

        log:printDebug("Converting with comma replacement");
        decimal result = check decimal:fromString(regexp:replace(re `\\,`, numericString, "."));
        log:printDebug("Converted value: " + result.toString());
        return result;
    } on fail {
        log:printDebug("Error converting decimal value: " + value.toString());
        return error(DECIMAL_ERROR);
    }
}

# Extracts and returns the remittance information from the provided `MT70` message.
# Depending on the remmitance information code, it returns the remmitance information or an empty string.
#
# + remmitanceInfo - The optional `MT70` object containing remittance information.
# + return - Returns remmitance information as a string or an empty string if no remmitance information was found.
isolated function getRemmitanceInformation(string? remmitanceInfo) returns string {
    log:printDebug("Starting getRemmitanceInformation with remmitanceInfo: " + remmitanceInfo.toString());

    if remmitanceInfo is () {
        log:printDebug("No remittance information found, returning empty string");
        return "";
    }

    log:printDebug("Returning remittance information: " + remmitanceInfo);
    return remmitanceInfo;
}

# Extracts and returns the content of the provided field if it is of type string.
# If the content is not a string, it returns an empty string.
#
# + content - The optional field that may be of type string.
# + return - Returns the string content if the content is a string; otherwise, returns an empty string.
isolated function getMandatoryFields(string? content) returns string {
    log:printDebug("Starting getMandatoryFields with content: " + content.toString());
    if content is () {
        log:printDebug("Content is null, returning empty string");
        return "";
    }
    log:printDebug("Returning content: " + content);
    return content;
}

isolated function getCurrency(string? currency1, string? currency2) returns string {
    log:printDebug("Starting getCurrency with currency1: " + currency1.toString() + ", currency2: " + currency2.toString());
    if currency1 is string {
        log:printDebug("Using currency1: " + currency1);
        return currency1;
    }
    if currency2 is string {
        log:printDebug("Using currency2: " + currency2);
        return currency2;
    }
    log:printDebug("No valid currency found, returning empty string");
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
    log:printDebug("Starting getAddressLine with address1: " + address1.toString() + ", address2: " + address2.toString() + ", address3: " + address3.toString());

    swiftmt:AdrsLine[] finalAddress = [];
    if address1 is swiftmt:AdrsLine[] {
        log:printDebug("Using address1");
        finalAddress = address1;
    } else if address2 is swiftmt:AdrsLine[] {
        log:printDebug("Using address2");
        finalAddress = address2;
    } else if address3 is string {
        log:printDebug("Using address3 string: " + address3);
        return [address3];
    } else {
        log:printDebug("No valid address found, returning null");
        return ();
    }

    string[] result = from swiftmt:AdrsLine adrsLine in finalAddress
        select adrsLine.content;

    log:printDebug("Returning address lines: " + result.toString());
    return result;
}

# Extracts and returns street name from the provided `AdrsLine` arrays.
# It first checks if the first address array (`address1`) is available and uses it;
# if not, it checks the second address array (`address2`). If neither is available,
# it returns `null`. The function aggregates all address lines into a string array.
#
# + address1 - An optional array of `AdrsLine` that may contain address lines.
# + address2 - An optional array of `AdrsLine` that may also contain address lines (default is `null`).
# + address3 - An optional string of address.
# + return - Returns a strin representing the address lines if any address lines are found;
# otherwise, returns `null`.
isolated function getStreetName(swiftmt:AdrsLine[]? address1, swiftmt:AdrsLine[]? address2 = (),
        string? address3 = ()) returns string? {
    log:printDebug("Starting getAddressLine with address1: " + address1.toString() + ", address2: " + address2.toString() + ", address3: " + address3.toString());

    swiftmt:AdrsLine[] finalAddress = [];
    if address1 is swiftmt:AdrsLine[] {
        log:printDebug("Using address1");
        finalAddress = address1;
    } else if address2 is swiftmt:AdrsLine[] {
        log:printDebug("Using address2");
        finalAddress = address2;
    } else if address3 is string {
        log:printDebug("Using address3 string: " + address3);
        return address3;
    } else {
        log:printDebug("No valid address found, returning null");
        return ();
    }

    string streetName = "";

    foreach swiftmt:AdrsLine adrsLine in finalAddress {
        if adrsLine.content.includes("/") {
            continue;
        }
        streetName += adrsLine.content + " ";    
    }

    log:printDebug("Returning address line: " + streetName.trim().toString());
    return streetName.trim();
}

# Retrieves the details charges code based on the provided `Cd` code.
# It looks up the code in an array and returns the corresponding details charge description.
# If the code is not found, it returns an error.
#
# + code - An optional `Cd` object that contains the code to be looked up.
# + return - Returns the details charge description associated with the provided code;
# Otherwise an error.
isolated function getDetailsChargesCd(swiftmt:Cd? code) returns string|error {
    log:printDebug("Starting getDetailsChargesCd with code: " + code.toString());

    string[][] chargesCodeArray = DETAILS_CHRGS;
    if code is () {
        log:printDebug("Code is null, returning error");
        return error("Details of charges code is madatory.");
    }

    foreach string[] line in chargesCodeArray {
        if line[0].equalsIgnoreCaseAscii(code.content) {
            log:printDebug("Found matching charge code: " + line[0] + ", returning: " + line[1]);
            return line[1];
        }
    }

    log:printDebug("No matching charge code found, returning error");
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
    log:printDebug("Starting getRegulatoryReporting with rgltyRptg: " + rgltyRptg.toString());

    if rgltyRptg is () {
        log:printDebug("Regulatory reporting is null, returning null");
        return ();
    }

    if rgltyRptg.substring(1, 9).equalsIgnoreCaseAscii("BENEFRES") ||
        rgltyRptg.substring(1, 9).equalsIgnoreCaseAscii("ORDERRES") {
        log:printDebug("Found BENEFRES or ORDERRES pattern");

        pacsIsoRecord:Max35Text[] additionalInfoArray = [];
        string additionalInfo = "";
        if rgltyRptg.length() > 14 {
            log:printDebug("Extracting additional info from position 14 onwards");
            foreach int i in 14 ... rgltyRptg.length() - 1 {
                if rgltyRptg.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
                    continue;
                }
                if rgltyRptg.substring(i, i + 1).equalsIgnoreCaseAscii("\n") {
                    additionalInfoArray.push(additionalInfo);
                    additionalInfo = "";
                    continue;
                }
                additionalInfo += rgltyRptg.substring(i, i + 1);
            }
            additionalInfoArray.push(additionalInfo);
        }

        log:printDebug("Regulatory reporting country code: " + rgltyRptg.substring(10, 12) + ", additional info: " + additionalInfo);
        return [
            {
                Dtls: [
                    {
                        Cd: rgltyRptg.substring(1, 9),
                        Ctry: rgltyRptg.substring(10, 12),
                        Inf: additionalInfoArray
                    }
                ]
            }
        ];
    }

    log:printDebug("No specific pattern found, using full content as regulatory reporting info");
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
    log:printDebug("Starting getPartyIdentifierOrAccount with prtyIdnOrAcc: " + prtyIdnOrAcc.toString());

    if prtyIdnOrAcc is () {
        log:printDebug("Party identifier is null, returning empty tuple");
        return [];
    }

    string content = prtyIdnOrAcc.content;
    log:printDebug("Processing party identifier content: " + content);

    if content.length() > 4 {
        log:printDebug("Content length > 4, checking format");

        if content.substring(0, 1).equalsIgnoreCaseAscii("/") {
            log:printDebug("Content starts with /, validating as account number");
            [string?, string?] result = validateAccountNumber(prtyIdn = prtyIdnOrAcc);
            log:printDebug("Account validation result: " + result.toString());
            return [(), ...result, (), ()];
        }

        string? partyIdentifier = ();
        string? schemaCode = ();
        string? issuer = ();

        foreach string code in SCHEMA_CODE {
            if !code.equalsIgnoreCaseAscii(content.substring(0, 4)) {
                continue;
            }

            log:printDebug("Found matching schema code: " + code);
            schemaCode = code;
            int count = 0;

            foreach int i in 0 ... content.length() - 1 {
                if content.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
                    count += 1;
                    log:printDebug("Found / at position " + i.toString() + ", count: " + count.toString());
                }

                if count == 2 {
                    partyIdentifier = content.substring(i + 1);
                    log:printDebug("Found party identifier after second /: " + partyIdentifier.toString());
                }

                if count == 3 {
                    partyIdentifier = content.substring(i + 1);
                    issuer = content.substring(8, i);
                    log:printDebug("Found party identifier after third /: " + partyIdentifier.toString() + ", issuer: " + issuer.toString());
                    break;
                }
            }
            break;
        }

        log:printDebug("Returning party identifier result: [" + partyIdentifier.toString() + ", (), (), " +
                    schemaCode.toString() + ", " + issuer.toString() + "]");
        return [partyIdentifier, (), (), schemaCode, issuer];
    }

    log:printDebug("Content length <= 4, returning empty tuple");
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
    log:printDebug("Starting getPartyIdentifierOrAccount2 with prtyIdn1: " + prtyIdn1.toString() +
                ", prtyIdn2: " + prtyIdn2.toString() +
                ", prtyIdn3: " + prtyIdn3.toString() +
                ", prtyIdn4: " + prtyIdn4.toString());

    if prtyIdn1 is swiftmt:PrtyIdn && isValidPartyIdentifier(prtyIdn1.content) {
        log:printDebug("prtyIdn1 is valid party identifier: " + prtyIdn1.content);
        return [prtyIdn1.content.substring(1), (), ()];
    }

    if prtyIdn2 is swiftmt:PrtyIdn && isValidPartyIdentifier(prtyIdn2.content) {
        log:printDebug("prtyIdn2 is valid party identifier: " + prtyIdn2.content);
        return [prtyIdn2.content.substring(1), (), ()];
    }

    if prtyIdn3 is swiftmt:PrtyIdn && isValidPartyIdentifier(prtyIdn3.content) {
        log:printDebug("prtyIdn3 is valid party identifier: " + prtyIdn3.content);
        return [prtyIdn3.content.substring(1), (), ()];
    }

    if prtyIdn1 is swiftmt:PrtyIdn && isValidAccountNumber(prtyIdn1.content) {
        log:printDebug("prtyIdn1 is valid account number: " + prtyIdn1.content);
        return [(), ...validateAccountNumber(prtyIdn = prtyIdn1)];
    }

    if prtyIdn2 is swiftmt:PrtyIdn && isValidAccountNumber(prtyIdn2.content) {
        log:printDebug("prtyIdn2 is valid account number: " + prtyIdn2.content);
        return [(), ...validateAccountNumber(prtyIdn = prtyIdn2)];
    }

    if prtyIdn3 is swiftmt:PrtyIdn && isValidAccountNumber(prtyIdn3.content) {
        log:printDebug("prtyIdn3 is valid account number: " + prtyIdn3.content);
        return [(), ...validateAccountNumber(prtyIdn = prtyIdn3)];
    }

    log:printDebug("No valid party identifier or account number found, returning empty tuple");
    return [];
}

isolated function isValidPartyIdentifier(string content) returns boolean {
    log:printDebug("Checking if content is valid party identifier: " + content);

    string[] excluded_prefixes = ["/CH", "/FW", "/RT"];
    int? index = excluded_prefixes.indexOf(content.substring(0, 3));

    boolean result = content.length() > 1 && content.startsWith("/") && index is ();
    log:printDebug("Content is valid party identifier: " + result.toString());

    return result;
}

isolated function isValidAccountNumber(string content) returns boolean {
    log:printDebug("Checking if content is valid account number: " + content);

    boolean result = content.length() > 0 && (!content.startsWith("/") || content.startsWith("/CH"));
    log:printDebug("Content is valid account number: " + result.toString());

    return result;
}

# Concatenates the contents of `Nm` elements from one of two possible arrays into a single string.
# The function handles cases where either one or both of the arrays might be provided.
#
# + name1 - An optional array of `Nm` elements that may contain the first set of name components.
# + name2 - An optional array of `Nm` elements that may contain the second set of name components.
# + return - Returns a single concatenated string of all name components, separated by spaces, or `null` if no valid 
# input is provided.
isolated function getName(swiftmt:Nm[]? name1, swiftmt:Nm[]? name2 = ()) returns string? {
    log:printDebug("Starting getName with name1: " + name1.toString() + ", name2: " + name2.toString());

    string finalName = "";
    swiftmt:Nm[] nameArray;

    if name1 is swiftmt:Nm[] {
        log:printDebug("Using name1 array with " + name1.length().toString() + " elements");
        nameArray = name1;
    } else if name2 is swiftmt:Nm[] {
        log:printDebug("Using name2 array with " + name2.length().toString() + " elements");
        nameArray = name2;
    } else {
        log:printDebug("No valid name array found, returning null");
        return ();
    }

    foreach int index in 0 ... nameArray.length() - 1 {
        if index == nameArray.length() - 1 {
            finalName += nameArray[index].content;
            log:printDebug("Added final name component: " + nameArray[index].content);
            break;
        }
        finalName = finalName + nameArray[index].content + " ";
        log:printDebug("Added name component: " + nameArray[index].content);
    }

    log:printDebug("Returning final name: " + finalName);
    return finalName;
}

# Extracts the country and town information from the provided `CntyNTw` array.
# The country is extracted from the first two characters of the first element, 
# and the town is extracted from the remaining part of the string if present.
#
# + cntyNTw - An optional array of `CntyNTw` elements that contains country and town information.
# + adrsline1 - An optional array of `AdrsLine` elements that may contain address lines.
# + adrsline2 - A second optional array of `AdrsLine` elements that may also contain address lines.
# + return - Returns a tuple with two elements: the country (first two characters) and the town 
# (remainder of the string), or `[null, null]` if the input is invalid.
isolated function getCountryAndTown(swiftmt:CntyNTw[]? cntyNTw, swiftmt:AdrsLine[]? adrsline1, swiftmt:AdrsLine[]? adrsline2) returns [string?, string?] {
    log:printDebug("Starting getCountryAndTown with cntyNTw: " + cntyNTw.toString());

    if cntyNTw is () {
        log:printDebug("Country and town info is null, returning empty tuple");
        swiftmt:AdrsLine[] adrsline = [];
        if adrsline1 is swiftmt:AdrsLine[] {
            adrsline = adrsline1;
        } else if adrsline2 is swiftmt:AdrsLine[] {
            adrsline = adrsline2;
        } else {
            log:printDebug("No valid address line found, returning empty tuple");
            return [];
        }
        foreach swiftmt:AdrsLine adrsLine in adrsline {
            if adrsLine.content.includes("/") && adrsLine.content.length() > 3 {
                return [adrsLine.content.substring(0, 2), adrsLine.content.substring(3)];
            }
        }
        return [];
    }

    [string?, string?] cntyNTwArray = [];
    cntyNTwArray[0] = cntyNTw[0].content.substring(0, 2);
    log:printDebug("Extracted country code: " + cntyNTwArray[0].toString());

    if cntyNTw[0].content.length() > 3 {
        cntyNTwArray[1] = cntyNTw[0].content.substring(3);
        log:printDebug("Extracted town name: " + cntyNTwArray[1].toString());
        return cntyNTwArray;
    }

    cntyNTwArray[1] = ();
    log:printDebug("No town name found, returning country only");
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
    log:printDebug("Starting validateAccountNumber with acc1: " + acc1.toString() +
                ", prtyIdn: " + prtyIdn.toString() +
                ", acc2: " + acc2.toString() +
                ", acc3: " + acc3.toString());

    // Get first valid account number
    string|error finalAccount = getFirstValidAccount(acc1, acc2, acc3, prtyIdn);
    if finalAccount is error {
        log:printDebug("No valid account found: " + finalAccount.message());
        return [];
    }

    log:printDebug("Found valid account: " + finalAccount);

    // Validate IBAN format
    if !finalAccount.matches(re `${IBAN_PATTERN}`) {
        log:printDebug("Account doesn't match IBAN pattern, returning as non-IBAN account");
        return [(), finalAccount];
    }

    log:printDebug("Account matches IBAN pattern, validating IBAN");
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
    log:printDebug("Starting getFirstValidAccount with acc1: " + acc1.toString() +
                ", acc2: " + acc2.toString() +
                ", acc3: " + acc3.toString() +
                ", prtyIdn: " + prtyIdn.toString());

    if acc1 is swiftmt:Acc {
        log:printDebug("Using acc1: " + acc1.content);
        return acc1.content;
    }
    if acc2 is swiftmt:Acc {
        log:printDebug("Using acc2: " + acc2.content);
        return acc2.content;
    }
    if acc3 is swiftmt:Acc {
        log:printDebug("Using acc3: " + acc3.content);
        return acc3.content;
    }
    if prtyIdn is swiftmt:PrtyIdn && prtyIdn.content.length() > 1 {
        string result = prtyIdn.content.startsWith("/") ?
            prtyIdn.content.substring(1) : prtyIdn.content;
        log:printDebug("Using party identifier: " + result);
        return result;
    }

    log:printDebug("No valid account found in any source");
    return error("No valid account found");
}

# Validates IBAN number
#
# + account - Account number to validate
# + return - Tuple containing [validated IBAN, empty string] or [empty, original account]
isolated function validateIBAN(string account) returns [string?, string?] {
    log:printDebug("Starting validateIBAN with account: " + account);

    foreach string country in COUNTRY_CODES {
        if !account.substring(0, COUNTRY_CODE_LENGTH).equalsIgnoreCaseAscii(country) {
            continue;
        }

        log:printDebug("Found matching country code: " + country);
        string|error result = processIBANValidation(account);
        if result is string {
            log:printDebug("IBAN validation successful");
            return [account, ()];
        }
        log:printDebug("IBAN validation failed: " + (result is error ? result.message() : "Unknown error"));
    }

    log:printDebug("No country code match or IBAN validation failed, returning as non-IBAN account");
    return [(), account];
}

# Processes IBAN validation calculation
#
# + account - Account number to process
# + return - Validated account number or error
isolated function processIBANValidation(string account) returns string|error {
    log:printDebug("Starting processIBANValidation with account: " + account);

    string rearrangedAccount = account.substring(IBAN_CHECK_DIGITS_LENGTH) +
                            account.substring(0, IBAN_CHECK_DIGITS_LENGTH);
    log:printDebug("Rearranged account: " + rearrangedAccount);

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

    log:printDebug("IBAN checksum validation failed");
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
    log:printDebug("Starting getPartyIdentifier with identifier1: " + identifier1.toString() +
                ", identifier2: " + identifier2.toString() +
                ", identifier3: " + identifier3.toString() +
                ", identifier4: " + identifier4.toString());

    if identifier1 is swiftmt:PrtyIdn && (identifier1.content).length() > 1 {
        log:printDebug("Using identifier1: " + identifier1.content);
        return identifier1?.content;
    }
    if identifier2 is swiftmt:PrtyIdn && (identifier2.content).length() > 1 {
        log:printDebug("Using identifier2: " + identifier2.content);
        return identifier2?.content;
    }
    if identifier3 is swiftmt:PrtyIdn && (identifier3.content).length() > 1 {
        log:printDebug("Using identifier3: " + identifier3.content);
        return identifier3?.content;
    }
    if identifier4 is swiftmt:PrtyIdn && (identifier4.content).length() > 1 {
        log:printDebug("Using identifier4: " + identifier4.content);
        return identifier4?.content;
    }

    log:printDebug("No valid party identifier found");
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
    log:printDebug("Starting getInstructedAmount with transAmnt: " + transAmnt.toString() +
                ", instrdAmnt: " + instrdAmnt.toString() +
                ", stlmntAmnt: " + stlmntAmnt.toString());

    if instrdAmnt is swiftmt:MT33B {
        log:printDebug("Using instructed amount from MT33B");
        decimal|error amount = convertToDecimalMandatory(instrdAmnt.Amnt);
        log:printDebug("Converted amount: " + (amount is decimal ? amount.toString() : "error"));
        return amount;
    }
    if transAmnt is swiftmt:MT32B {
        log:printDebug("Using transaction amount from MT32B");
        decimal|error amount = convertToDecimalMandatory(transAmnt.Amnt);
        log:printDebug("Converted amount: " + (amount is decimal ? amount.toString() : "error"));
        return amount;
    }
    if stlmntAmnt is swiftmt:MT32A {
        log:printDebug("Using settlement amount from MT32A");
        decimal|error amount = convertToDecimalMandatory(stlmntAmnt.Amnt);
        log:printDebug("Converted amount: " + (amount is decimal ? amount.toString() : "error"));
        return amount;
    }

    log:printDebug("No valid amount found, returning 0");
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
    log:printDebug("Starting getTotalInterBankSettlementAmount with sumAmnt: " + sumAmnt.toString() +
                    ", stlmntAmnt: " + stlmntAmnt.toString());

    if sumAmnt is swiftmt:MT19 {
        log:printDebug("Using sum amount from MT19");
        decimal|error result = convertToDecimalMandatory(sumAmnt.Amnt);
        log:printDebug("Converted sum amount: " + (result is decimal ? result.toString() : "error"));
        return result;
    }

    if stlmntAmnt is swiftmt:MT32A|swiftmt:MT32B {
        log:printDebug("Using settlement amount from MT32A or MT32B");
        decimal|error result = convertToDecimalMandatory(stlmntAmnt.Amnt);
        log:printDebug("Converted settlement amount: " + (result is decimal ? result.toString() : "error"));
        return result;
    }

    log:printDebug("No valid amount found, returning 0");
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
    log:printDebug("Starting getSchemaCode with account1: " + account1.toString() +
                ", account2: " + account2.toString() +
                ", account3: " + account3.toString() +
                ", prtyIdn1: " + prtyIdn1.toString() +
                ", prtyIdn2: " + prtyIdn2.toString() +
                ", prtyIdn3: " + prtyIdn3.toString() +
                ", prtyIdn4: " + prtyIdn4.toString());

    if account1?.content != "NOTPROVIDED" || account2?.content != "NOTPROVIDED" || account3?.content != "NOTPROVIDED"
            || prtyIdn1?.content != "NOTPROVIDED" || prtyIdn2?.content != "NOTPROVIDED"
            || prtyIdn3?.content != "NOTPROVIDED" || prtyIdn4?.content != "NOTPROVIDED" {
        log:printDebug("At least one account/identifier is not 'NOTPROVIDED', checking validation");

        if !(validateAccountNumber(account1)[1] is ()) || !(validateAccountNumber(account2)[1] is ())
                || !(validateAccountNumber(account3)[1] is ()) || !(getPartyIdentifierOrAccount2(prtyIdn1)[2] is ())
                || !(getPartyIdentifierOrAccount2(prtyIdn2)[2] is ()) ||
                !(getPartyIdentifierOrAccount2(prtyIdn3)[2] is ()) {
            log:printDebug("Found valid account or party identifier, returning 'BBAN'");
            return "BBAN";
        }
    }

    log:printDebug("No valid account or party identifier found, returning null");
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
        swiftmt:Acc? account3 = (), swiftmt:PrtyIdn? prtyIdn1 = (), swiftmt:PrtyIdn? prtyIdn2 = (),
        swiftmt:PrtyIdn? prtyIdn3 = (), swiftmt:PrtyIdn? prtyIdn4 = ()) returns string? {
    log:printDebug("Starting getSchemaCodeForDbtr with account1: " + account1.toString() +
                ", account2: " + account2.toString() +
                ", account3: " + account3.toString() +
                ", prtyIdn1: " + prtyIdn1.toString() +
                ", prtyIdn2: " + prtyIdn2.toString() +
                ", prtyIdn3: " + prtyIdn3.toString() +
                ", prtyIdn4: " + prtyIdn4.toString());

    if account1?.content != "NOTPROVIDED" || account2?.content != "NOTPROVIDED" || account3?.content != "NOTPROVIDED"
            || prtyIdn1?.content != "NOTPROVIDED" || prtyIdn2?.content != "NOTPROVIDED"
            || prtyIdn3?.content != "NOTPROVIDED" || prtyIdn4?.content != "NOTPROVIDED" {
        log:printDebug("At least one account/identifier is not 'NOTPROVIDED', checking validation");

        if !(validateAccountNumber(account1)[1] is ()) || !(validateAccountNumber(account2)[1] is ())
                || !(validateAccountNumber(account3)[1] is ()) || !(getPartyIdentifierOrAccount(prtyIdn1)[2] is ())
                || !(getPartyIdentifierOrAccount(prtyIdn2)[2] is ()) || !(getPartyIdentifierOrAccount(prtyIdn3)[2] is ()) {
            log:printDebug("Found valid account or party identifier, returning 'BBAN'");
            return "BBAN";
        }
    }

    log:printDebug("No valid account or party identifier found, returning null");
    return ();
}

# Returns the account ID or party identifier based on the provided inputs.
# It prioritizes returning the `account` if it is not null; otherwise, it returns the `prtyIdn` if it is not null.
#
# + account - A string that may represent an account ID.
# + prtyIdn - A string that may represent a party identifier.
# + return - Returns the `account` if it is not null; otherwise, returns `prtyIdn` if it is not null.
isolated function getAccountId(string? account, string? prtyIdn) returns string? {
    log:printDebug("Starting getAccountId with account: " + account.toString() + ", prtyIdn: " + prtyIdn.toString());

    if account !is () {
        log:printDebug("Using account: " + account);
        return account;
    }

    if prtyIdn !is () {
        log:printDebug("Using party identifier: " + prtyIdn);
        return prtyIdn;
    }

    log:printDebug("No account or party identifier found, returning null");
    return ();
}

# Returns an array of `camtIsoRecord:Charges16` objects that contains charges information based on the provided `MT71F` 
# and `MT71G` SWIFT message records.
#
# + sndsChrgs - An optional `swiftmt:MT71F` object that contains information about sender's charges.
# + rcvsChrgs - An optional `swiftmt:MT71G` object that contains information about receiver's charges.
# + receiver - The BIC code of the receiver.
# + return - An array of `camtIsoRecord:Charges16` containing two entries:
# - The first entry includes the sender's charges amount and currency, with a charge type of "CRED".
# - The second entry includes the receiver's charges amount and currency, with a charge type of "DEBT".
#
# The function uses helper methods `convertToDecimalMandatory` to convert the amount and 
# `getMandatoryFields` to fetch the currency.
isolated function getChargesInformation(swiftmt:MT71F[]? sndsChrgs, swiftmt:MT71G? rcvsChrgs, string? receiver)
    returns camtIsoRecord:Charges16[]?|error {
    log:printDebug("Starting getChargesInformation with sndsChrgs: " + sndsChrgs.toString() +
                ", rcvsChrgs: " + rcvsChrgs.toString());

    camtIsoRecord:Charges16[] chrgsInf = [];

    if sndsChrgs is swiftmt:MT71F[] {
        log:printDebug("Processing sender's charges, count: " + sndsChrgs.length().toString());

        foreach swiftmt:MT71F charges in sndsChrgs {
            decimal amount = check convertToDecimalMandatory(charges?.Amnt);
            string currency = getMandatoryFields(charges?.Ccy.content);

            log:printDebug("Adding sender charge: amount=" + amount.toString() + ", currency=" + currency);

            chrgsInf.push({
                Amt: {
                    content: amount,
                    Ccy: currency
                },
                Agt: {
                    FinInstnId: {
                        Nm: "NOTPROVIDED",
                        PstlAdr: {AdrLine: ["NOTPROVIDED"]}
                    }
                }
            });
        }
    }

    if rcvsChrgs is swiftmt:MT71G {
        decimal amount = check convertToDecimalMandatory(rcvsChrgs?.Amnt);
        string currency = getMandatoryFields(rcvsChrgs?.Ccy.content);

        log:printDebug("Adding receiver charge: amount=" + amount.toString() + ", currency=" + currency);

        chrgsInf.push({
            Amt: {
                content: amount,
                Ccy: currency
            },
            Agt: {
                FinInstnId: {
                    BICFI: receiver
                }
            }
        });
    }

    if chrgsInf.length() == 0 {
        log:printDebug("No charges information found, returning null");
        return ();
    }

    log:printDebug("Returning charges information with " + chrgsInf.length().toString() + " entries");
    return chrgsInf;
}

# Extracts and returns the time indication based on the provided `MT13C` message.
#
# + tmInd - An optional `swiftmt:MT13C` record containing the time indication information.
# + return - Returns a tuple with the time in "HH:MM:SS" format based on the content of `tmInd`.
# - If no code matches, it returns a tuple of `null` values.
isolated function getTimeIndication(swiftmt:MT13C? tmInd) returns [string?, string?, string?] {
    log:printDebug("Starting getTimeIndication with tmInd: " + tmInd.toString());

    if tmInd is swiftmt:MT13C {
        string code = tmInd.Cd.content;
        string time = tmInd.Tm.content;
        string sign = tmInd.Sgn.content;
        string timeOffset = tmInd.TmOfst.content;

        log:printDebug("Processing time indication with code: " + code +
                    ", time: " + time +
                    ", sign: " + sign +
                    ", offset: " + timeOffset);

        match (code) {
            "CLSTIME" => {
                string formattedTime = time.substring(0, 2) + ":" + time.substring(2) + ":00" +
                    sign + timeOffset.substring(0, 2) + ":" + timeOffset.substring(2);

                log:printDebug("Returning CLSTIME: " + formattedTime);
                return [formattedTime, (), ()];
            }
            "RNCTIME" => {
                // Dummy date is added to translate the time to ISO standard date and time;
                string formattedTime = "0001-01-01T" + time.substring(0, 2) + ":" + time.substring(2) +
                    ":00" + sign + timeOffset.substring(0, 2) + ":" + timeOffset.substring(2);

                log:printDebug("Returning RNCTIME: " + formattedTime);
                return [(), formattedTime, ()];
            }
            "SNDTIME" => {
                // Dummy date is added to translate the time to ISO standard date and time;
                string formattedTime = "0001-01-01T" + time.substring(0, 2) + ":" + time.substring(2) +
                    ":00" + sign + timeOffset.substring(0, 2) + ":" + timeOffset.substring(2);

                log:printDebug("Returning SNDTIME: " + formattedTime);
                return [(), (), formattedTime];
            }
        }

        log:printDebug("Unrecognized time indication code: " + code);
    }

    log:printDebug("No valid time indication found, returning empty tuple");
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
    log:printDebug("Starting getMT1XXSenderToReceiverInformation with sndRcvInfo: " + sndRcvInfo.toString());

    if sndRcvInfo is swiftmt:MT72 {
        string[] code = [];
        string?[] additionalInfo = [];
        [boolean, boolean] [isAddtnlInfoPresent, isPreviousValidCode] = [false, true];
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);

        log:printDebug("Parsed info array from sender-to-receiver information: " + infoArray.toString());

        foreach int i in 0 ... infoArray.length() - 1 {
            foreach string item in MT_1XX_SNDR_CODE {
                if i == 0 && item.equalsIgnoreCaseAscii(infoArray[i]) {
                    code.push(item);
                    isAddtnlInfoPresent = false;
                    log:printDebug("Found valid first code: " + item);
                    break;
                }
                if item.equalsIgnoreCaseAscii(infoArray[i]) && i != 0 {
                    code.push(item);
                    if isPreviousValidCode {
                        additionalInfo.push(());
                        log:printDebug("Added empty additional info for previous code");
                    }
                    isPreviousValidCode = true;
                    isAddtnlInfoPresent = false;
                    log:printDebug("Found valid subsequent code: " + item);
                    break;
                }
                isAddtnlInfoPresent = true;
            }
            if isAddtnlInfoPresent {
                if i == 0 {
                    log:printDebug("First code is not supported: " + infoArray[i]);
                    return error("Sender to receiver information code is not supported.");
                }
                isPreviousValidCode = false;
                additionalInfo.push(infoArray[i]);
                log:printDebug("Added additional info: " + infoArray[i]);
            }
        }

        if code.length() != additionalInfo.length() {
            additionalInfo.push(());
            log:printDebug("Added final empty additional info to match code array length");
        }

        log:printDebug("Extracted codes: " + code.toString() + ", additional info: " + additionalInfo.toString());
        return getMT1XXSenderToReceiverInformationForAgts(code, additionalInfo);
    }

    log:printDebug("No sender-to-receiver information provided, returning empty tuple");
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
    log:printDebug("Starting getMT1XXSenderToReceiverInformationForAgts with codes: " + code.toString() +
                ", additionalInfo: " + additionalInfo.toString());

    pacsIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
    pacsIsoRecord:InstructionForNextAgent1[] instrFrNxtAgt = [];
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt2 = ();
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? prvsInstgAgt1 = ();
    [string?, pacsIsoRecord:LocalInstrument2Choice?, pacsIsoRecord:CategoryPurpose1Choice?]
            [serviceLevel, lclInstrm, purpose] = [(), (), ()];

    foreach int i in 0 ... code.length() - 1 {
        log:printDebug("Processing code[" + i.toString() + "]: " + code[i]);

        match (code[i]) {
            "INT" => {
                log:printDebug("Adding instruction for next agent with code INT");
                instrFrNxtAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
            }
            "ACC" => {
                log:printDebug("Adding instruction for creditor agent with code ACC");
                instrFrCdtrAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
            }
            "INS"|"INTA" => {
                if additionalInfo[i] is string {
                    log:printDebug("Processing INS/INTA with additional info: " + additionalInfo[i].toString());

                    if additionalInfo[i].toString().length() >= 8 &&
                        additionalInfo[i].toString().substring(0, 6).matches(re `^[A-Z]+$`) &&
                        additionalInfo[i].toString().substring(6, 7).matches(re `^[A-Z2-9]+$`) &&
                        additionalInfo[i].toString().substring(7, 8).matches(re `^[A-NP-Z0-9]+$`) {

                        log:printDebug("Additional info appears to be a valid BIC");

                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            log:printDebug("Setting previous instructing agent with BIC: " + additionalInfo[i].toString());
                            prvsInstgAgt1 = {FinInstnId: {BICFI: additionalInfo[i]}};
                        } else {
                            log:printDebug("Setting intermediary agent with BIC: " + additionalInfo[i].toString());
                            intrmyAgt2 = {FinInstnId: {BICFI: additionalInfo[i]}};
                        }
                    } else {
                        log:printDebug("Additional info is not a valid BIC, using as Name");

                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            log:printDebug("Setting previous instructing agent with Name: " + additionalInfo[i].toString());
                            prvsInstgAgt1 = {FinInstnId: {Nm: additionalInfo[i]}};
                        } else {
                            log:printDebug("Setting intermediary agent with Name: " + additionalInfo[i].toString());
                            intrmyAgt2 = {FinInstnId: {Nm: additionalInfo[i]}};
                        }
                    }
                } else {
                    log:printDebug("No additional info provided for INS/INTA code");
                }
            }
            "SVCLVL" => {
                log:printDebug("Setting service level: " + code[i]);
                serviceLevel = code[i];
            }
            "LOCINS" => {
                log:printDebug("Setting local instrument: " + code[i]);
                lclInstrm = {Cd: code[i]};
            }
            "CATPURP" => {
                log:printDebug("Setting category purpose: " + code[i]);
                purpose = {Cd: code[i]};
            }
            _ => {
                log:printDebug("Unrecognized code: " + code[i]);
            }
        }
    }

    log:printDebug("Returning extracted information - instrFrCdtrAgt: " + instrFrCdtrAgt.toString() +
                ", instrFrNxtAgt: " + instrFrNxtAgt.toString() +
                ", prvsInstgAgt1: " + prvsInstgAgt1.toString() +
                ", intrmyAgt2: " + intrmyAgt2.toString() +
                ", serviceLevel: " + serviceLevel.toString() +
                ", localInstrument: " + lclInstrm.toString() +
                ", purpose: " + purpose.toString());

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
    log:printDebug("Starting getInformationForAgents with instnCd: " + instnCd.toString() +
                ", sndRcvInfo: " + sndRcvInfo.toString());

    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], string?,
            pacsIsoRecord:CategoryPurpose1Choice?] [instrFrCdtrAgt, instrFrNxtAgt, finalServiceLevel, finalPurpose] = [];

    log:printDebug("Getting instruction codes from MT103InstructionCode");
    [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[], string?,
    pacsIsoRecord:CategoryPurpose1Choice?] mt103Instructions = getMT103InstructionCode(instnCd);

    log:printDebug("Getting sender-to-receiver information");
    var sndRcvInformation = check getMT1XXSenderToReceiverInformation(sndRcvInfo);

    [string?, string?] [serviceLevel1, serviceLevel2] = [
        mt103Instructions[2],
        sndRcvInformation[4]
    ];

    log:printDebug("Service levels - from MT103: " + serviceLevel1.toString() + ", from MT1XX: " + serviceLevel2.toString());

    [pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:CategoryPurpose1Choice?] [purpose1, purpose2] =
            [mt103Instructions[3], sndRcvInformation[6]];

    log:printDebug("Purpose codes - from MT103: " + purpose1.toString() + ", from MT1XX: " + purpose2.toString());

    foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in mt103Instructions[0] {
        instrFrCdtrAgt.push(instruction);
        log:printDebug("Added creditor agent instruction from MT103: " + instruction.toString());
    }

    foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in sndRcvInformation[0] {
        instrFrCdtrAgt.push(instruction);
        log:printDebug("Added creditor agent instruction from sender-to-receiver info: " + instruction.toString());
    }

    foreach pacsIsoRecord:InstructionForNextAgent1 instruction in mt103Instructions[1] {
        instrFrNxtAgt.push(instruction);
        log:printDebug("Added next agent instruction from MT103: " + instruction.toString());
    }

    foreach pacsIsoRecord:InstructionForNextAgent1 instruction in sndRcvInformation[1] {
        instrFrNxtAgt.push(instruction);
        log:printDebug("Added next agent instruction from sender-to-receiver info: " + instruction.toString());
    }

    if serviceLevel1 is string {
        finalServiceLevel = serviceLevel1;
        log:printDebug("Using service level from MT103: " + finalServiceLevel.toString());
    } else {
        finalServiceLevel = serviceLevel2;
        log:printDebug("Using service level from sender-to-receiver info: " + finalServiceLevel.toString());
    }

    if purpose1 is pacsIsoRecord:CategoryPurpose1Choice {
        finalPurpose = purpose1;
        log:printDebug("Using purpose from MT103: " + finalPurpose.toString());
    } else {
        finalPurpose = purpose2;
        log:printDebug("Using purpose from sender-to-receiver info: " + finalPurpose.toString());
    }

    log:printDebug("Returning combined information - instrFrCdtrAgt: " + instrFrCdtrAgt.toString() +
                    ", instrFrNxtAgt: " + instrFrNxtAgt.toString() +
                    ", finalServiceLevel: " + finalServiceLevel.toString() +
                    ", finalPurpose: " + finalPurpose.toString());

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
    log:printDebug("Starting getMT2XXSenderToReceiverInfo with sndRcvInfo: " + sndRcvInfo.toString() +
                ", sndCdNum: " + sndCdNum.toString());

    if sndRcvInfo is swiftmt:MT72 {
        [string[], string?[], boolean, boolean, string[]] [code, additionalInfo, isAddtnlInfoPresent,
                isPreviousValidCode, codeArray] = [[], [], false, true, []];

        if sndCdNum == 1 {
            codeArray = MT_2XX_SNDR_CODE1;
            log:printDebug("Using code array MT_2XX_SNDR_CODE1");
        }
        if sndCdNum == 2 {
            codeArray = MT_2XX_SNDR_CODE2;
            log:printDebug("Using code array MT_2XX_SNDR_CODE2");
        }
        if sndCdNum == 3 {
            codeArray = MT_2XX_SNDR_CODE3;
            log:printDebug("Using code array MT_2XX_SNDR_CODE3");
        }

        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        log:printDebug("Parsed info array from sender-to-receiver information: " + infoArray.toString());

        foreach int i in 0 ... infoArray.length() - 1 {
            log:printDebug("Processing infoArray[" + i.toString() + "]: " + infoArray[i]);

            foreach string item in codeArray {
                if i == 0 && item.equalsIgnoreCaseAscii(infoArray[i]) {
                    code.push(item);
                    isAddtnlInfoPresent = false;
                    log:printDebug("Found valid first code: " + item);
                    break;
                }
                if item.equalsIgnoreCaseAscii(infoArray[i]) && i != 0 {
                    code.push(item);
                    if isPreviousValidCode {
                        additionalInfo.push(());
                        log:printDebug("Added empty additional info for previous code");
                    }
                    isPreviousValidCode = true;
                    isAddtnlInfoPresent = false;
                    log:printDebug("Found valid subsequent code: " + item);
                    break;
                }
                isAddtnlInfoPresent = true;
            }

            if isAddtnlInfoPresent {
                if i == 0 {
                    log:printDebug("First code is not supported: " + infoArray[i]);
                    return error("Sender to receiver information code is not supported.");
                }
                additionalInfo.push(infoArray[i]);
                isPreviousValidCode = false;
                log:printDebug("Added additional info: " + infoArray[i]);
            }
        }

        if code.length() != additionalInfo.length() {
            additionalInfo.push(());
            log:printDebug("Added final empty additional info to match code array length");
        }

        log:printDebug("Extracted codes: " + code.toString() + ", additional info: " + additionalInfo.toString());
        return check getMT2XXSenderToReceiverInfoForAgts(code, additionalInfo);
    }

    log:printDebug("No sender-to-receiver information provided, returning empty tuple");
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
    log:printDebug("Starting getMT2XXSenderToReceiverInfoForAgts with codes: " + code.toString() +
                ", additionalInfo: " + additionalInfo.toString());

    pacsIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
    pacsIsoRecord:InstructionForNextAgent1[] instrFrNxtAgt = [];
    [pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?]
            [intrmyAgt2, prvsInstgAgt1] = [(), ()];
    [string?, pacsIsoRecord:LocalInstrument2Choice?, pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:RemittanceInformation2?,
            pacsIsoRecord:Purpose2Choice?] [serviceLevel, lclInstrm, catPurpose, remmitanceInfo, purpose] = [(), (), (), (), ()];

    foreach int i in 0 ... code.length() - 1 {
        log:printDebug("Processing code[" + i.toString() + "]: " + code[i]);

        match (code[i]) {
            "INT"|"PHON"|"TELE"|"TELEIBK"|"PHONIBK" => {
                log:printDebug("Adding instruction for next agent with code: " + code[i]);
                instrFrNxtAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
            }
            "ACC"|"UDLC"|"PHONBEN"|"TELEBEN" => {
                log:printDebug("Adding instruction for creditor agent with code: " + code[i]);
                instrFrCdtrAgt.push({Cd: code[i], InstrInf: additionalInfo[i]});
            }
            "INS"|"INTA" => {
                if additionalInfo[i] is string {
                    log:printDebug("Processing INS/INTA with additional info: " + additionalInfo[i].toString());

                    if additionalInfo[i].toString().length() >= 8 &&
                        additionalInfo[i].toString().substring(0, 6).matches(re `^[A-Z]+$`) &&
                        additionalInfo[i].toString().substring(6, 7).matches(re `^[A-Z2-9]+$`) &&
                        additionalInfo[i].toString().substring(7).matches(re `^[A-NP-Z0-9]+$`) {

                        log:printDebug("Additional info appears to be a valid BIC");

                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            log:printDebug("Setting previous instructing agent with BIC: " + additionalInfo[i].toString());
                            prvsInstgAgt1 = {FinInstnId: {BICFI: additionalInfo[i]}};
                        } else {
                            log:printDebug("Setting intermediary agent with BIC: " + additionalInfo[i].toString());
                            intrmyAgt2 = {FinInstnId: {BICFI: additionalInfo[i]}};
                        }
                    } else {
                        log:printDebug("Additional info is not a valid BIC, using as Name");

                        if code[i].toString().equalsIgnoreCaseAscii("INS") {
                            log:printDebug("Setting previous instructing agent with Name: " + additionalInfo[i].toString());
                            prvsInstgAgt1 = {FinInstnId: {Nm: additionalInfo[i]}};
                        } else {
                            log:printDebug("Setting intermediary agent with Name: " + additionalInfo[i].toString());
                            intrmyAgt2 = {FinInstnId: {Nm: additionalInfo[i]}};
                        }
                    }
                } else {
                    log:printDebug("No additional info provided for INS/INTA code");
                }
            }
            "BNF"|"TSU" => {
                log:printDebug("Setting remittance information with code: " + code[i]);
                remmitanceInfo = {
                    Ustrd: [check additionalInfo[i].ensureType(pacsIsoRecord:Max140Text)]
                };
            }
            "PURP" => {
                log:printDebug("Setting purpose with code: " + code[i]);
                purpose = {
                    Cd: code[i]
                };
            }
            "SVCLVL" => {
                log:printDebug("Setting service level: " + code[i]);
                serviceLevel = code[i];
            }
            "LOCINS" => {
                log:printDebug("Setting local instrument: " + code[i]);
                lclInstrm = {Cd: code[i]};
            }
            "CATPURP" => {
                log:printDebug("Setting category purpose: " + code[i]);
                catPurpose = {Cd: code[i]};
            }
            _ => {
                log:printDebug("Unrecognized code: " + code[i]);
            }
        }
    }

    log:printDebug("Returning extracted information - instrFrCdtrAgt: " + instrFrCdtrAgt.toString() +
                ", instrFrNxtAgt: " + instrFrNxtAgt.toString() +
                ", prvsInstgAgt1: " + prvsInstgAgt1.toString() +
                ", intrmyAgt2: " + intrmyAgt2.toString() +
                ", serviceLevel: " + serviceLevel.toString() +
                ", lclInstrm: " + lclInstrm.toString() +
                ", catPurpose: " + catPurpose.toString() +
                ", remmitanceInfo: " + remmitanceInfo.toString() +
                ", purpose: " + purpose.toString());

    return [
        instrFrCdtrAgt,
        instrFrNxtAgt,
        prvsInstgAgt1,
        intrmyAgt2,
        serviceLevel,
        lclInstrm,
        catPurpose,
        remmitanceInfo,
        purpose
    ];
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
    log:printDebug("Starting getSettlementMethod with mt53A: " + mt53A.toString() +
                ", mt53B: " + mt53B.toString() +
                ", mt53D: " + mt53D.toString());

    if mt53B is swiftmt:MT53B {
        log:printDebug("MT53B is provided, checking party identifier type");

        match (mt53B.PrtyIdnTyp?.content) {
            "C" => {
                log:printDebug("Party identifier type is 'C', returning INGA");
                return camtIsoRecord:INGA;
            }
            "D" => {
                log:printDebug("Party identifier type is 'D', returning INDA");
                return camtIsoRecord:INDA;
            }
            _ => {
                log:printDebug("Party identifier type is neither 'C' nor 'D'");
            }
        }
    }

    if mt53A is swiftmt:MT53A || mt53D is swiftmt:MT53D {
        log:printDebug("MT53A or MT53D is provided, returning COVE");
        return camtIsoRecord:COVE;
    }

    log:printDebug("No matching conditions found, returning default INDA");
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
    log:printDebug("Starting getMT103InstructionCode with instnCd: " + instnCd.toString());

    if instnCd is swiftmt:MT23E[] {
        log:printDebug("Processing " + instnCd.length().toString() + " instruction codes");

        pacsIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
        pacsIsoRecord:InstructionForNextAgent1[] instrFrNxtAgt = [];
        string? serviceLevel = ();
        string purpose = "";

        foreach swiftmt:MT23E instruction in instnCd {
            log:printDebug("Processing instruction code: " + instruction.InstrnCd.content);

            match (instruction.InstrnCd.content) {
                "REPA"|"PHON"|"TELE"|"PHOI"|"TELI" => {
                    log:printDebug("Found instruction for next agent: " + instruction.InstrnCd.content);
                    instrFrNxtAgt.push({
                        Cd: instruction.InstrnCd.content,
                        InstrInf: instruction.AddInfo?.content
                    });
                }
                "CHQB"|"HOLD"|"PHOB"|"TELB" => {
                    log:printDebug("Found instruction for creditor agent: " + instruction.InstrnCd.content);
                    instrFrCdtrAgt.push({
                        Cd: instruction.InstrnCd.content,
                        InstrInf: instruction.AddInfo?.content
                    });
                }
                "SDVA" => {
                    log:printDebug("Found service level instruction: " + instruction.InstrnCd.content);
                    serviceLevel = instruction.InstrnCd.content;
                }
                "INTC"|"CORT" => {
                    log:printDebug("Found purpose instruction: " + instruction.InstrnCd.content);
                    purpose += instruction.InstrnCd.content;
                }
                _ => {
                    log:printDebug("Unrecognized instruction code: " + instruction.InstrnCd.content);
                }
            }
        }

        log:printDebug("Completed processing instructions - purpose length: " + purpose.length().toString());

        if purpose.length() == 8 && !(purpose.substring(0, 4).equalsIgnoreCaseAscii(purpose.substring(4))) {
            log:printDebug("Purpose contains two different 4-character codes, returning as Prtry");
            purpose = purpose.substring(0, 4) + " " + purpose.substring(4);
            log:printDebug("Final result - instrFrCdtrAgt: " + instrFrCdtrAgt.length().toString() +
                        ", instrFrNxtAgt: " + instrFrNxtAgt.length().toString() +
                        ", serviceLevel: " + serviceLevel.toString() +
                        ", purpose: " + purpose);
            return [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, {Prtry: purpose}];
        }

        if purpose.length() == 0 {
            log:printDebug("No purpose codes found");
            log:printDebug("Final result - instrFrCdtrAgt: " + instrFrCdtrAgt.length().toString() +
                        ", instrFrNxtAgt: " + instrFrNxtAgt.length().toString() +
                        ", serviceLevel: " + serviceLevel.toString());
            return [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel];
        }

        log:printDebug("Returning with purpose code: " + purpose.substring(0, 4));
        log:printDebug("Final result - instrFrCdtrAgt: " + instrFrCdtrAgt.length().toString() +
                    ", instrFrNxtAgt: " + instrFrNxtAgt.length().toString() +
                    ", serviceLevel: " + serviceLevel.toString() +
                    ", purpose: " + purpose.substring(0, 4));
        return [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, {Cd: purpose.substring(0, 4)}];
    }

    log:printDebug("No instruction codes provided, returning empty tuple");
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
    log:printDebug("Starting getMT101InstructionCode with instnCd: " + instnCd.toString());

    if instnCd is swiftmt:MT23E[] {
        log:printDebug("Processing " + instnCd.length().toString() + " instruction codes");

        painIsoRecord:InstructionForCreditorAgent3[] instrFrCdtrAgt = [];
        painIsoRecord:InstructionForDebtorAgent1? instrFrDbtrAgt = ();
        painIsoRecord:ServiceLevel8Choice[] serviceLevel = [];
        string purpose = "";

        foreach swiftmt:MT23E instruction in instnCd {
            log:printDebug("Processing instruction code: " + instruction.InstrnCd.content);

            match (instruction.InstrnCd.content) {
                "CMTO"|"CMSW"|"CMZB"|"REPA" => {
                    log:printDebug("Found instruction for debtor agent: " + instruction.InstrnCd.content);
                    instrFrDbtrAgt = {
                        Cd: instruction.InstrnCd.content,
                        InstrInf: instruction.AddInfo?.content
                    };
                }
                "CHQB"|"PHON"|"EQUI" => {
                    log:printDebug("Found instruction for creditor agent: " + instruction.InstrnCd.content);
                    instrFrCdtrAgt.push({
                        Cd: instruction.InstrnCd.content,
                        InstrInf: instruction.AddInfo?.content
                    });
                }
                "URGP" => {
                    log:printDebug("Found service level instruction: " + instruction.InstrnCd.content);
                    serviceLevel.push({
                        Cd: instruction.InstrnCd.content
                    });
                }
                "CORT"|"INTC" => {
                    log:printDebug("Found purpose instruction: " + instruction.InstrnCd.content);
                    purpose += instruction.InstrnCd.content;
                }
                _ => {
                    log:printDebug("Unrecognized instruction code: " + instruction.InstrnCd.content);
                }
            }
        }

        log:printDebug("Completed processing instructions - purpose length: " + purpose.length().toString());

        if purpose.length() == 8 && !(purpose.substring(0, 4).equalsIgnoreCaseAscii(purpose.substring(4))) {
            log:printDebug("Purpose contains two different 4-character codes, returning as Prtry");
            purpose = purpose.substring(0, 4) + " " + purpose.substring(4);
            log:printDebug("Final result - instrFrDbtrAgt: " + instrFrDbtrAgt.toString() +
                        ", instrFrCdtrAgt: " + instrFrCdtrAgt.length().toString() +
                        ", serviceLevel: " + serviceLevel.length().toString() +
                        ", purpose: " + purpose);
            return [instrFrDbtrAgt, instrFrCdtrAgt, serviceLevel, {Prtry: purpose}];
        }

        if purpose.length() == 0 {
            log:printDebug("No purpose codes found");
            log:printDebug("Final result - instrFrDbtrAgt: " + instrFrDbtrAgt.toString() +
                        ", instrFrCdtrAgt: " + instrFrCdtrAgt.length().toString() +
                        ", serviceLevel: " + serviceLevel.length().toString());
            return [instrFrDbtrAgt, instrFrCdtrAgt, serviceLevel];
        }

        log:printDebug("Returning with purpose code: " + purpose.substring(0, 4));
        log:printDebug("Final result - instrFrDbtrAgt: " + instrFrDbtrAgt.toString() +
                    ", instrFrCdtrAgt: " + instrFrCdtrAgt.length().toString() +
                    ", serviceLevel: " + serviceLevel.length().toString() +
                    ", purpose: " + purpose.substring(0, 4));
        return [instrFrDbtrAgt, instrFrCdtrAgt, serviceLevel, {Cd: purpose.substring(0, 4)}];
    }

    log:printDebug("No instruction codes provided, returning empty tuple");
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
    log:printDebug("Starting getMT101RepeatingFields with typeName: " + typeName +
                ", content type: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT101Transaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if itemString.length() >= 12 && itemString.substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, checking block4 for " + typeName);
    match (typeName) {
        "50F" => {
            log:printDebug("Returning block4.MT50F");
            return block4.MT50F;
        }
        "50G" => {
            log:printDebug("Returning block4.MT50G");
            return block4.MT50G;
        }
        "50H" => {
            log:printDebug("Returning block4.MT50H");
            return block4.MT50H;
        }
        "52A" => {
            log:printDebug("Returning block4.MT52A");
            return block4.MT52A;
        }
        "52C" => {
            log:printDebug("Returning block4.MT52C");
            return block4.MT52C;
        }
    }
    log:printDebug("No matching field found in block4, returning null");
    return ();

}

# Converts a given date in SWIFT MT format to an ISO 20022 standard date format (YYYY-MM-DD).
#
# + date - A `swiftmt:Dt` object containing the date in the format YYMMDD.
# + return - Returns the date in ISO 20022 format (YYYY-MM-DD). 
isolated function convertToISOStandardDate(swiftmt:Dt? date) returns string? {
    log:printDebug("Starting convertToISOStandardDate with date: " + date.toString());

    if date !is swiftmt:Dt {
        log:printDebug("Date is null, returning null");
        return ();
    }

    string result = YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
        date.content.substring(4, 6);

    log:printDebug("Converted date to ISO format: " + result);
    return result;
}

# Converts a given date in SWIFT MT format to an ISO 20022 standard date format (YYYY-MM-DD).
#
# + date - A `swiftmt:Dt` object containing the date in the format YYMMDD.
# + return - Returns the date in ISO 20022 format (YYYY-MM-DD).
isolated function convertToISOStandardDateMandatory(swiftmt:Dt date) returns string {
    log:printDebug("Starting convertToISOStandardDateMandatory with date: " + date.toString());

    string result = YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
        date.content.substring(4, 6);

    log:printDebug("Converted date to mandatory ISO format: " + result);
    return result;
}

# Converts a SWIFT MT date and time to an ISO 20022 standard date-time format.
#
# + date - The date component of the SWIFT MT message in the format YYMMDD.
# + time - The time component of the SWIFT MT message in the format HHMM.
# + isCreationDateTime - The indicator to identify whether it is creation date and time.
# + return - A string containing the date-time in ISO 20022 format, or null if the input is not valid.
isolated function convertToISOStandardDateTime(swiftmt:Dt? date, swiftmt:Tm? time, boolean isCreationDateTime = false)
    returns string? {
    log:printDebug("Starting convertToISOStandardDateTime with date: " + date.toString() + ", time: " + time.toString() +
                ", isCreationDateTime: " + isCreationDateTime.toString());

    if date is swiftmt:Dt && time is swiftmt:Tm {
        log:printDebug("Both date and time are provided");
        if isCreationDateTime {
            log:printDebug("Processing as creation date time");
            string result = YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
                date.content.substring(4, 6) + "T" + time.content.substring(0, 2) + ":" +
                time.content.substring(2, 4) + ":00" + DEFAULT_TIME_OFFSET;
            log:printDebug("Returning ISO formatted creation date-time: " + result);
            return result;
        }
        string result = YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" +
            date.content.substring(4, 6) + "T" + time.content.substring(0, 2) + ":" +
            time.content.substring(2, 4) + ":00";
        log:printDebug("Returning ISO formatted date-time: " + result);
        return result;
    }

    if isCreationDateTime {
        log:printDebug("No date/time provided but isCreationDateTime is true, using current time");
        string result = time:utcToString(time:utcNow()).substring(0, 19) + "+00:00";
        log:printDebug("Returning current UTC time: " + result);
        return result;
    }

    log:printDebug("No valid date/time provided, returning null");
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
    log:printDebug("Starting getMT102STPRepeatingFields with typeName: " + typeName +
                ", content type: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT102STPTransaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if (itemString.length() >= 12 && itemString.substring(9, 12).equalsIgnoreCaseAscii(typeName)) ||
                (itemString.length() >= 11 && itemString.substring(9, 11).equalsIgnoreCaseAscii(typeName)) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, checking block4 for " + typeName);
    match (typeName) {
        "26T" => {
            log:printDebug("Returning block4.MT26T");
            return block4.MT26T;
        }
        "36" => {
            log:printDebug("Returning block4.MT36");
            return block4.MT36;
        }
        "50F" => {
            log:printDebug("Returning block4.MT50F");
            return block4.MT50F;
        }
        "50A" => {
            log:printDebug("Returning block4.MT50A");
            return block4.MT50A;
        }
        "50K" => {
            log:printDebug("Returning block4.MT50K");
            return block4.MT50K;
        }
        "52A" => {
            log:printDebug("Returning block4.MT52A");
            return block4.MT52A;
        }
        "71A" => {
            log:printDebug("Returning block4.MT71A");
            return block4.MT71A;
        }
        "77B" => {
            log:printDebug("Returning block4.MT77B");
            return block4.MT77B;
        }
    }

    log:printDebug("No matching field found in block4, returning null");
    return ();
}

# Extracts and returns the content from the `MT77T` envelope based on the envelope content type.
#
# + envelopeContent - A `swiftmt:MT77T` object containing the envelope content in the `EnvCntnt` field.
# + return - Returns a tuple of strings
# Handles errors during extraction by returning a tuple of empty or null values.
isolated function getEnvelopeContent(string envelopeContent) returns [string, string?, string?] {
    log:printDebug("Starting getEnvelopeContent with envelopeContent: " + envelopeContent);

    if envelopeContent.length() >= 7 {
        if envelopeContent.substring(1, 5).equalsIgnoreCaseAscii("SWIF") {
            log:printDebug("Found SWIF envelope type, returning SWIFT content");
            return [envelopeContent.substring(6), (), ()];
        }
        if envelopeContent.substring(1, 5).equalsIgnoreCaseAscii("IXML") {
            log:printDebug("Found IXML envelope type, returning XML content");
            return ["", envelopeContent.substring(6), ()];
        }
        if envelopeContent.substring(1, 5).equalsIgnoreCaseAscii("NARR") {
            log:printDebug("Found NARR envelope type, returning narrative content");
            return ["", (), envelopeContent.substring(6)];
        }

        log:printDebug("Unknown envelope type, returning empty content");
        return ["", (), ()];
    }

    log:printDebug("Envelope content too short, returning empty content");
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
    log:printDebug("Starting getMT102RepeatingFields with typeName: " + typeName +
                    ", content: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT102Transaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if itemString.length() >= 12 && itemString.substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
            if itemString.length() >= 11 && itemString.substring(9, 11).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " (2-char code) in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, checking block4 for " + typeName);
    match (typeName) {
        "26T" => {
            log:printDebug("Returning block4.MT26T");
            return block4.MT26T;
        }
        "36" => {
            log:printDebug("Returning block4.MT36");
            return block4.MT36;
        }
        "50F" => {
            log:printDebug("Returning block4.MT50F");
            return block4.MT50F;
        }
        "50A" => {
            log:printDebug("Returning block4.MT50A");
            return block4.MT50A;
        }
        "50K" => {
            log:printDebug("Returning block4.MT50K");
            return block4.MT50K;
        }
        "52A" => {
            log:printDebug("Returning block4.MT52A");
            return block4.MT52A;
        }
        "52B" => {
            log:printDebug("Returning block4.MT52B");
            return block4.MT52B;
        }
        "52C" => {
            log:printDebug("Returning block4.MT52C");
            return block4.MT52C;
        }
        "71A" => {
            log:printDebug("Returning block4.MT71A");
            return block4.MT71A;
        }
        "77B" => {
            log:printDebug("Returning block4.MT77B");
            return block4.MT77B;
        }
    }

    log:printDebug("No matching field found in block4 for typeName: " + typeName + ", returning null");
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
    log:printDebug("Starting getMT104RepeatingFields with typeName: " + typeName +
                    ", content: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT104Transaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if itemString.length() >= 12 && itemString.substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, checking block4 for " + typeName);
    match (typeName) {
        "23E" => {
            log:printDebug("Returning block4.MT23E");
            return block4.MT23E;
        }
        "26T" => {
            log:printDebug("Returning block4.MT26T");
            return block4.MT26T;
        }
        "50A" => {
            log:printDebug("Returning block4.MT50A");
            return block4.MT50A;
        }
        "50C" => {
            log:printDebug("Returning block4.MT50C");
            return block4.MT50C;
        }
        "50K" => {
            log:printDebug("Returning block4.MT50K");
            return block4.MT50K;
        }
        "50L" => {
            log:printDebug("Returning block4.MT50L");
            return block4.MT50L;
        }
        "52A" => {
            log:printDebug("Returning block4.MT52A");
            return block4.MT52A;
        }
        "52C" => {
            log:printDebug("Returning block4.MT52C");
            return block4.MT52C;
        }
        "52D" => {
            log:printDebug("Returning block4.MT52D");
            return block4.MT52D;
        }
        "71A" => {
            log:printDebug("Returning block4.MT71A");
            return block4.MT71A;
        }
        "77B" => {
            log:printDebug("Returning block4.MT77B");
            return block4.MT77B;
        }
    }

    log:printDebug("No matching field found in block4 for typeName: " + typeName + ", returning null");
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
    log:printDebug("Starting getMT107RepeatingFields with typeName: " + typeName +
                    ", content: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT107Transaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if itemString.length() >= 12 && itemString.substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, checking block4 for " + typeName);
    match (typeName) {
        "23E" => {
            log:printDebug("Returning block4.MT23E");
            return block4.MT23E;
        }
        "26T" => {
            log:printDebug("Returning block4.MT26T");
            return block4.MT26T;
        }
        "50A" => {
            log:printDebug("Returning block4.MT50A");
            return block4.MT50A;
        }
        "50C" => {
            log:printDebug("Returning block4.MT50C");
            return block4.MT50C;
        }
        "50K" => {
            log:printDebug("Returning block4.MT50K");
            return block4.MT50K;
        }
        "50L" => {
            log:printDebug("Returning block4.MT50L");
            return block4.MT50L;
        }
        "52A" => {
            log:printDebug("Returning block4.MT52A");
            return block4.MT52A;
        }
        "52C" => {
            log:printDebug("Returning block4.MT52C");
            return block4.MT52C;
        }
        "52D" => {
            log:printDebug("Returning block4.MT52D");
            return block4.MT52D;
        }
        "71A" => {
            log:printDebug("Returning block4.MT71A");
            return block4.MT71A;
        }
        "77B" => {
            log:printDebug("Returning block4.MT77B");
            return block4.MT77B;
        }
    }

    log:printDebug("No matching field found in block4 for typeName: " + typeName + ", returning null");
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
    log:printDebug("Starting getMT201RepeatingFields with typeName: " + typeName +
                    ", content: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT201Transaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if itemString.length() >= 11 && itemString.substring(9, 11).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, returning block4.MT72");
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
    log:printDebug("Starting getMT203RepeatingFields with typeName: " + typeName +
                    ", content: " + content.toString());

    log:printDebug("Searching for " + typeName + " in transaction set");
    foreach swiftmt:MT203Transaction transaxion in block4.Transaction {
        foreach var item in transaxion {
            string itemString = item.toString();
            if itemString.length() >= 11 && itemString.substring(9, 11).equalsIgnoreCaseAscii(typeName) {
                log:printDebug("Found matching field " + typeName + " in transaction, returning provided content");
                return content;
            }
        }
    }

    log:printDebug("No match found in transactions, returning block4.MT72");
    return block4.MT72;
}

# Extracts and converts floor limit data from the MT34F SWIFT message into ISO 20022 Limit2 format.
#
# + floorLimit - An optional array of MT34F objects, each representing a floor limit.
# + return - Returns an array of Limit2 objects for ISO 20022, or an error if conversion fails.
isolated function getFloorLimit(swiftmt:MT34F[]? floorLimit) returns camtIsoRecord:Limit2[]?|error {
    log:printDebug("Starting getFloorLimit with floorLimit: " + floorLimit.toString());

    if floorLimit is () {
        log:printDebug("Floor limit is null, returning null");
        return ();
    }

    if floorLimit.length() > 1 {
        log:printDebug("Multiple floor limits found, processing " + floorLimit.length().toString() + " limits");

        decimal firstAmount = check convertToDecimalMandatory(floorLimit[0].Amnt);
        string firstCurrency = floorLimit[0].Ccy.content;
        camtIsoRecord:FloorLimitType1Code firstIndicator = getCdtDbtFloorLimitIndicator(floorLimit[0].Cd);

        decimal secondAmount = check convertToDecimalMandatory(floorLimit[1].Amnt);
        string secondCurrency = floorLimit[1].Ccy.content;
        camtIsoRecord:FloorLimitType1Code secondIndicator = getCdtDbtFloorLimitIndicator(floorLimit[1].Cd);

        log:printDebug("Creating first limit with amount: " + firstAmount.toString() +
                    ", currency: " + firstCurrency +
                    ", indicator: " + firstIndicator.toString());

        log:printDebug("Creating second limit with amount: " + secondAmount.toString() +
                    ", currency: " + secondCurrency +
                    ", indicator: " + secondIndicator.toString());

        return [
            {
                Amt: {
                    content: firstAmount,
                    Ccy: firstCurrency
                },
                CdtDbtInd: firstIndicator
            },
            {
                Amt: {
                    content: secondAmount,
                    Ccy: secondCurrency
                },
                CdtDbtInd: secondIndicator
            }
        ];
    }

    log:printDebug("Single floor limit found");
    decimal amount = check convertToDecimalMandatory(floorLimit[0].Amnt);
    string currency = floorLimit[0].Ccy.content;

    log:printDebug("Creating limit with amount: " + amount.toString() +
                ", currency: " + currency +
                ", indicator: BOTH");

    return [
        {
            Amt: {
                content: amount,
                Ccy: currency
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
    log:printDebug("Starting getCdtDbtFloorLimitIndicator with code: " + code.toString());

    if code is () {
        log:printDebug("Code is null, returning default DEBT");
        return camtIsoRecord:DEBT;
    }

    if code.content.equalsIgnoreCaseAscii("D") {
        log:printDebug("Code is 'D', returning DEBT");
        return camtIsoRecord:DEBT;
    }

    log:printDebug("Code is not 'D', returning CRED");
    return camtIsoRecord:CRED;
}

# Retrieves and converts the list of MT61 statement entries into ISO 20022 `ReportEntry14` objects.
#
# This function takes an array of SWIFT MT61 statement lines, extracts relevant data such as 
# reference, value date, amount, and transaction details, and maps them to the corresponding 
# ISO 20022 `ReportEntry14` structure.
#
# + statement - The optional array of SWIFT MT61 statement lines, containing details of account transactions.
# + currency - The currency code for the statement entries.
# + return - Returns an array of `ReportEntry14` objects with mapped values, or an error if conversion fails.
isolated function getEntries(swiftmt:MT61[]? statement, string currency) returns camtIsoRecord:ReportEntry14[]|error {
    log:printDebug("Starting getEntries with statement: " + statement.toString());

    camtIsoRecord:ReportEntry14[] entries = [];
    if statement is () {
        log:printDebug("Statement is null, returning empty entries array");
        return entries;
    }

    log:printDebug("Processing " + statement.length().toString() + " statement entries");

    foreach swiftmt:MT61 stmtLine in statement {
        log:printDebug("Processing statement line with reference: " + stmtLine.RefAccOwn.content);

        decimal amount = check convertToDecimalMandatory(stmtLine.Amnt);
        string? valueDate = convertToISOStandardDate(stmtLine.ValDt);
        camtIsoRecord:CreditDebitCode creditDebitIndicator = convertDbtOrCrdToISOStandard(stmtLine);

        log:printDebug("Statement entry values - amount: " + amount.toString() +
                    ", currency: " + currency +
                    ", valueDate: " + valueDate.toString() +
                    ", creditDebitIndicator: " + creditDebitIndicator.toString());

        entries.push({
            ValDt: {
                Dt: valueDate
            },
            CdtDbtInd: creditDebitIndicator,
            Amt: {
                content: amount,
                Ccy: currency
            },
            BkTxCd: {
                Prtry: {
                    Cd: "NOTPROVIDED",
                    Issr: "NOTPROVIDED"
                }
            },
            Sts: {
                Cd: "BOOK"
            },
            AcctSvcrRef: stmtLine.RefAccSerInst?.content,
            NtryDtls: [
                {
                    TxDtls: [
                        {
                            Refs: {
                                EndToEndId: stmtLine.RefAccOwn.content
                            },
                            Amt: {
                                content: amount,
                                Ccy: currency
                            },
                            CdtDbtInd: creditDebitIndicator,
                            AddtlTxInf: stmtLine.SpmtDtls?.content
                        }
                    ]
                }
            ]
        });

        log:printDebug("Added entry to entries array with EndToEndId: " + stmtLine.RefAccOwn.content);
    }

    log:printDebug("Returning " + entries.length().toString() + " entries");
    return entries;
}

# Converts the credit/debit indicator from the SWIFT MT message into the ISO 20022 `CreditDebitCode`.
#
# + content - The SWIFT MT message content (MT60F, MT62F, MT65, MT64, MT60M, MT62M, or MT61) which contains 
# the credit or debit indicator.
# + return - Returns the ISO 20022 `CreditDebitCode`, either `CRDT` or `DBIT`.
isolated function convertDbtOrCrdToISOStandard(swiftmt:MT60F|swiftmt:MT62F|swiftmt:MT65|swiftmt:MT64|swiftmt:MT60M|
        swiftmt:MT62M|swiftmt:MT61 content) returns camtIsoRecord:CreditDebitCode {
    log:printDebug("Starting convertDbtOrCrdToISOStandard with content code: " + content.Cd.content);

    if content.Cd.content.equalsIgnoreCaseAscii("C") || content.Cd.content.equalsIgnoreCaseAscii("RD") {
        log:printDebug("Code is 'C' or 'RD', returning CRDT");
        return camtIsoRecord:CRDT;
    }

    log:printDebug("Code is not 'C' or 'RD', returning DBIT");
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
    log:printDebug("Starting getBalance with firstOpenBalance: " + firstOpenBalance.toString() +
                ", firstCloseBalance: " + firstCloseBalance.toString() +
                ", closeAvailableBalance: " + closeAvailableBalance.toString() +
                ", inmdOpenBalance: " + inmdOpenBalance.toString() +
                ", inmdCloseBalance: " + inmdCloseBalance.toString() +
                ", forwardAvailableBalance: " + forwardAvailableBalance.toString());

    camtIsoRecord:CashBalance8[] balanceArray = [];

    if firstOpenBalance is swiftmt:MT60F {
        log:printDebug("Processing first opening balance");
        balanceArray.push(check createBalanceRecord(firstOpenBalance, "OPBD"));
        log:printDebug("Added first opening balance with type code OPBD");
    }

    if inmdOpenBalance is swiftmt:MT60M[] {
        log:printDebug("Processing " + inmdOpenBalance.length().toString() + " intraday opening balances");
        foreach swiftmt:MT60M inmdOpnBal in inmdOpenBalance {
            balanceArray.push(check createBalanceRecord(inmdOpnBal, "OPBD/INTM"));
            log:printDebug("Added intraday opening balance with type code OPBD/INTM");
        }
    }

    if firstCloseBalance is swiftmt:MT62F {
        log:printDebug("Processing first closing balance");
        balanceArray.push(check createBalanceRecord(firstCloseBalance, "CLBD"));
        log:printDebug("Added first closing balance with type code CLBD");
    }

    if inmdCloseBalance is swiftmt:MT62M[] {
        log:printDebug("Processing " + inmdCloseBalance.length().toString() + " intraday closing balances");
        foreach swiftmt:MT62M inmdClsBal in inmdCloseBalance {
            balanceArray.push(check createBalanceRecord(inmdClsBal, "CLBD/INTM"));
            log:printDebug("Added intraday closing balance with type code CLBD/INTM");
        }
    }

    if closeAvailableBalance is swiftmt:MT64[] {
        log:printDebug("Processing " + closeAvailableBalance.length().toString() + " closing available balances");
        foreach swiftmt:MT64 clsAvblBal in closeAvailableBalance {
            balanceArray.push(check createBalanceRecord(clsAvblBal, "CLAV"));
            log:printDebug("Added closing available balance with type code CLAV");
        }
    }

    if forwardAvailableBalance is swiftmt:MT65[] {
        log:printDebug("Processing " + forwardAvailableBalance.length().toString() + " forward available balances");
        foreach swiftmt:MT65 fwdAvblBal in forwardAvailableBalance {
            balanceArray.push(check createBalanceRecord(fwdAvblBal, "FWAV"));
            log:printDebug("Added forward available balance with type code FWAV");
        }
    }

    log:printDebug("Returning " + balanceArray.length().toString() + " balance records");
    return balanceArray;
}

# Helper function to create a balance record
#
# + balance - The balance information
# + typeCode - The type code for the balance
# + return - A CashBalance8 record
isolated function createBalanceRecord(swiftmt:MT60F|swiftmt:MT60M|swiftmt:MT62F|swiftmt:MT62M|swiftmt:MT64|
        swiftmt:MT65 balance, string typeCode) returns camtIsoRecord:CashBalance8|error {
    log:printDebug("Starting createBalanceRecord for type code: " + typeCode);

    decimal amount = check convertToDecimalMandatory(balance.Amnt);
    string currency = balance.Ccy.content;
    string? date = convertToISOStandardDate(balance.Dt);
    camtIsoRecord:CreditDebitCode creditDebitIndicator = convertDbtOrCrdToISOStandard(balance);

    log:printDebug("Balance record values - amount: " + amount.toString() +
                ", currency: " + currency +
                ", date: " + date.toString() +
                ", creditDebitIndicator: " + creditDebitIndicator.toString());

    camtIsoRecord:CashBalance8 result = {
        Amt: {
            content: amount,
            Ccy: currency
        },
        Dt: {Dt: date},
        CdtDbtInd: creditDebitIndicator,
        Tp: {
            CdOrPrtry: {
                Cd: typeCode
            }
        }
    };

    log:printDebug("Created balance record successfully");
    return result;
}

# Retrieves and concatenates additional information (MT86) from the `infoToAccOwnr` array into a single string.
#
# The function processes multiple MT86 blocks of additional information, combining them into a comma-separated string 
# and returning the final concatenated result. If there is no information, it returns null.
#
# + infoToAccOwnr - An optional array of MT86 additional information blocks.
# + return - Returns the concatenated additional information as a string or null if the input is not provided or empty.
isolated function getInfoToAccOwnr(swiftmt:MT86[]? infoToAccOwnr) returns string? {
    log:printDebug("Starting getInfoToAccOwnr with infoToAccOwnr: " + infoToAccOwnr.toString());

    if infoToAccOwnr is () {
        log:printDebug("No additional information provided, returning null");
        return ();
    }

    string finalInfo = "";
    log:printDebug("Processing " + infoToAccOwnr.length().toString() + " MT86 blocks");

    foreach swiftmt:MT86 information in infoToAccOwnr {
        log:printDebug("Processing MT86 with " + information.AddInfo.length().toString() + " additional info elements");

        foreach int index in 0 ... information.AddInfo.length() - 1 {
            if index == information.AddInfo.length() - 1 {
                finalInfo += information.AddInfo[index].content;
                log:printDebug("Added final info element: " + information.AddInfo[index].content);
            } else {
                finalInfo = finalInfo + information.AddInfo[index].content + ", ";
                log:printDebug("Added info element with comma: " + information.AddInfo[index].content);
            }
        }
    }

    log:printDebug("Returning concatenated information: " + finalInfo);
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
    log:printDebug("Starting getTotalNumOfEntries with creditEntryNum: " + creditEntryNum.toString() +
                ", debitEntryNum: " + debitEntryNum.toString());

    int total = 0;
    do {
        if creditEntryNum is swiftmt:TtlNum {
            int creditNum = check int:fromString(creditEntryNum.content);
            total += creditNum;
            log:printDebug("Added credit entries: " + creditNum.toString());
        }

        if debitEntryNum is swiftmt:TtlNum {
            int debitNum = check int:fromString(debitEntryNum.content);
            total += debitNum;
            log:printDebug("Added debit entries: " + debitNum.toString());
        }

        log:printDebug("Total number of entries: " + total.toString());
        return ();
    } on fail {
        log:printDebug("Error parsing integer values from entries");
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
    log:printDebug("Starting getTotalSumOfEntries with creditEntryAmnt: " + creditEntryAmnt.toString() +
                ", debitEntryAmnt: " + debitEntryAmnt.toString());

    decimal total = 0;
    do {
        if creditEntryAmnt is swiftmt:Amnt {
            decimal creditAmount = check convertToDecimalMandatory(creditEntryAmnt);
            total += creditAmount;
            log:printDebug("Added credit amount: " + creditAmount.toString());
        }

        if debitEntryAmnt is swiftmt:Amnt {
            decimal debitAmount = check convertToDecimalMandatory(debitEntryAmnt);
            total += debitAmount;
            log:printDebug("Added debit amount: " + debitAmount.toString());
        }

        log:printDebug("Total sum of entries: " + total.toString());
        return ();
    } on fail {
        log:printDebug("Error converting decimal values from amounts");
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
    log:printDebug("Starting getEndToEndId with cstmRefNum: " + cstmRefNum.toString() +
                ", remmitanceInfo: " + remmitanceInfo.toString() +
                ", transactionId: " + transactionId.toString());

    if cstmRefNum is string {
        log:printDebug("Using customer reference number as end-to-end ID: " + cstmRefNum);
        return cstmRefNum;
    }

    if remmitanceInfo is string && remmitanceInfo.length() > 3 && remmitanceInfo.substring(1, 4).equalsIgnoreCaseAscii("ROC") {
        string result = remmitanceInfo.substring(5);
        log:printDebug("Using ROC remittance info as end-to-end ID: " + result);
        return result;
    }

    if transactionId is string {
        log:printDebug("Using transaction ID as end-to-end ID: " + transactionId);
        return transactionId;
    }

    log:printDebug("No valid identifier found, returning empty string");
    return "NOTPROVIDED";
}

# Retrieves the cancellation reason code from an MT79 narrative.
#
# This function checks the narrative content of an MT79 message to find and return a cancellation
# reason code that matches a predefined set of reason codes (`REASON_CODE`).
#
# + narrative - An optional `swiftmt:MT79` record containing the narrative with possible reason codes.
# + return - Returns the matching reason code as a `string` if found; otherwise, returns null.
isolated function getCancellationReasonCode(swiftmt:MT79? narrative) returns string? {
    log:printDebug("Starting getCancellationReasonCode with narrative: " + narrative.toString());

    if narrative is () {
        log:printDebug("No narrative provided, returning null");
        return ();
    }

    log:printDebug("Checking first narrative element: " + narrative.Nrtv[0].content);

    foreach string code in REASON_CODE {
        if narrative.Nrtv[0].content.includes(code) {
            log:printDebug("Found matching reason code: " + code);
            return code;
        }
    }

    log:printDebug("No matching reason code found");
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
    log:printDebug("Starting getAdditionalCancellationInfo with narrative: " + narrative.toString());

    if narrative is () {
        log:printDebug("No narrative provided, returning null");
        return ();
    }

    string[] additionalInfo = [];
    log:printDebug("Processing " + (narrative.Nrtv.length() - 1).toString() + " additional narrative elements");

    foreach int i in 1 ... narrative.Nrtv.length() - 1 {
        if narrative.Nrtv[i].content.includes("/UETR/") {
            continue;
        }
        additionalInfo.push(narrative.Nrtv[i].content);
        log:printDebug("Added additional info: " + narrative.Nrtv[i].content);
    }

    if additionalInfo.length() > 0 {
        log:printDebug("Returning " + additionalInfo.length().toString() + " additional info elements");
        return additionalInfo;
    } else {
        additionalInfo.push("NOTPROVIDED");
        return additionalInfo;
    }
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
    log:printDebug("Starting getMessageSender with logicalTerminal: " + logicalTerminal.toString() +
                ", mirLogicalTerminal: " + mirLogicalTerminal.toString());

    if mirLogicalTerminal is string {
        log:printDebug("Using mirLogicalTerminal, returning first 11 characters: " +
                    mirLogicalTerminal.substring(0, 11));
        return mirLogicalTerminal.substring(0, 11);
    }

    if logicalTerminal is string {
        log:printDebug("Using logicalTerminal, returning first 11 characters: " +
                    logicalTerminal.substring(0, 11));
        return logicalTerminal.substring(0, 11);
    }

    log:printDebug("No valid terminal identifier found, returning null");
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
    log:printDebug("Starting getMessageReceiver with logicalTerminal: " + logicalTerminal.toString() +
                ", receiverAddress: " + receiverAddress.toString());

    if receiverAddress is string {
        log:printDebug("Using receiverAddress, returning first 11 characters: " +
                    receiverAddress.substring(0, 11));
        return receiverAddress.substring(0, 11);
    }

    if logicalTerminal is string {
        log:printDebug("Using logicalTerminal, returning first 11 characters: " +
                    logicalTerminal.substring(0, 11));
        return logicalTerminal.substring(0, 11);
    }

    log:printDebug("No valid receiver identifier found, returning null");
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
    log:printDebug("Starting getDescriptionOfMessage with narrative: " + narrative.toString());

    if narrative is () {
        log:printDebug("No narrative provided, returning null");
        return ();
    }

    string description = "";
    log:printDebug("Processing " + narrative.length().toString() + " narrative elements");

    foreach swiftmt:Nrtv narration in narrative {
        description += narration.content;
        log:printDebug("Added narrative content: " + narration.content);
    }

    log:printDebug("Returning concatenated description: " + description);
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
    log:printDebug("Starting getJustificationReason with narration: " + narration);

    camtIsoRecord:UnableToApplyMissing2[] missingInfoArray = [];
    camtIsoRecord:UnableToApplyIncorrect2[] incorrectInfoArray = [];
    string[] queriesArray = getCodeAndAddtnlInfo(narration);

    log:printDebug("Parsed queries array from narration: " + queriesArray.toString());

    foreach int i in 0 ... queriesArray.length() - 1 {
        log:printDebug("Processing query[" + i.toString() + "]: " + queriesArray[i]);

        boolean isMissingInfo = false;
        string? additionalInfo = ();

        if queriesArray[i].length() <= 2 {
            log:printDebug("Query has length <= 2, checking for additional info");

            if i != queriesArray.length() - 1 {
                if queriesArray[i + 1].length() > 2 {
                    additionalInfo = queriesArray[i + 1];
                    log:printDebug("Found additional info: " + additionalInfo.toString());
                } else {
                    additionalInfo = ();
                    log:printDebug("No valid additional info found");
                }
            } else {
                additionalInfo = ();
                log:printDebug("Last query item, no additional info available");
            }

            log:printDebug("Checking for missing info codes");
            foreach string code in MISSING_INFO_CODE {
                if queriesArray[i].equalsIgnoreCaseAscii(code) {
                    missingInfoArray.push({
                        Tp: {
                            Cd: code
                        },
                        AddtlMssngInf: additionalInfo
                    });
                    isMissingInfo = true;
                    log:printDebug("Found missing info code: " + code + ", additional info: " + additionalInfo.toString());
                    break;
                }
            }

            if !isMissingInfo {
                log:printDebug("Not a missing info code, checking incorrect info codes");
                foreach string code in INCORRECT_INFO_CODE {
                    if queriesArray[i].equalsIgnoreCaseAscii(code) {
                        incorrectInfoArray.push({
                            Tp: {
                                Cd: code
                            },
                            AddtlIncrrctInf: additionalInfo
                        });
                        log:printDebug("Found incorrect info code: " + code + ", additional info: " + additionalInfo.toString());
                    }
                }
            }
        } else {
            log:printDebug("Query length > 2, not processing as code");
        }
    }

    log:printDebug("Found " + missingInfoArray.length().toString() + " missing info entries and " +
                incorrectInfoArray.length().toString() + " incorrect info entries");

    return {
        MssngInf: missingInfoArray,
        IncrrctInf: incorrectInfoArray
    };
}

# Extracts cancellation reasons and additional information from a narration string.
#
# + narration - A `string` containing the narration with codes and additional information.
# + return - Returns an array of `camtIsoRecord:CancellationStatusReason5` records with the following structure:
# - `Rsn`: Contains the cancellation reason code (`Cd`).
# - `AddtlInf` (optional): Contains additional information related to the reason, if present.
isolated function getCancellationReason(string narration) returns camtIsoRecord:CancellationStatusReason5[] {
    log:printDebug("Starting getCancellationReason with narration: " + narration);

    camtIsoRecord:CancellationStatusReason5[] cancellationReasonArray = [];
    string code = "";
    string additionalInfo = "";
    string:RegExp reg = re `(CNCL|PDCR|RJCR).*`;
    if reg.isFullMatch(narration) {
        if regexp:isFullMatch(re `(AC04|AGNT|AM04|ARDT|CUST|INDM|LEGL|NOAS|NOOR|PTNA|RQDA).*`, narration.substring(6)) {
            code = narration.substring(6, 10);
            additionalInfo = narration.substring(10);
        } else if (narration.substring(1, 5).equalsIgnoreCaseAscii("RJCR")) {
            code = "NARR";
            additionalInfo = narration.substring(6, narration.length());
        } else {
            log:printDebug("Invalid code, not adding to results: " + code);
            return cancellationReasonArray;
        }
    }

    log:printDebug("Last item, adding reason without additional info");
    cancellationReasonArray.push({
        Rsn: {
            Cd: code
        },
        AddtlInf: additionalInfo != "" ? [additionalInfo] : []
    });

    log:printDebug("Returning " + cancellationReasonArray.length().toString() + " cancellation reasons");
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
    log:printDebug("Starting getCodeAndAddtnlInfo with narration: " + narration);

    string supplementaryInfo = "";
    string[] queriesOrAnswersArray = [];
    int count = 0;

    log:printDebug("Processing narration character by character");
    foreach int i in 1 ... narration.length() - 1 {
        if narration.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
            log:printDebug("Found '/' character at position " + i.toString());

            if i == narration.length() - 1 {
                log:printDebug("End of string, adding final info: " + supplementaryInfo);
                queriesOrAnswersArray.push(supplementaryInfo);
                break;
            }

            count += 1;
            if count == 2 || narration.substring(i + 1, i + 2).equalsIgnoreCaseAscii("/") {
                log:printDebug("Double slash or count=2, continuing");
                continue;
            }

            log:printDebug("Adding info to array: " + supplementaryInfo);
            queriesOrAnswersArray.push(supplementaryInfo);
            supplementaryInfo = "";
            continue;
        }

        if count < 2 && narration.substring(i, i + 1) != "\n" {
            supplementaryInfo += narration.substring(i, i + 1);
            log:printDebug("Adding char to info: " + narration.substring(i, i + 1) + ", current info: " + supplementaryInfo);

            if i == narration.length() - 1 {
                log:printDebug("End of string, adding final info: " + supplementaryInfo);
                queriesOrAnswersArray.push(supplementaryInfo);
                break;
            }

            count = 0;
            continue;
        }

        if count == 2 && narration.substring(i, i + 1) != "\n" {
            supplementaryInfo += " ".concat(narration.substring(i, i + 1));
            log:printDebug("Adding space + char to info: " + narration.substring(i, i + 1) + ", current info: " + supplementaryInfo);
            count = 0;
        }
    }

    log:printDebug("Returning " + queriesOrAnswersArray.length().toString() + " info items: " + queriesOrAnswersArray.toString());
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
    log:printDebug("Starting getRejectedReason with narration: " + narration);

    string? code = narration.length() >= 5 ? INVTGTN_RJCT_RSN[narration.substring(1, 5)] : ();
    log:printDebug("Extracted code from narration: " + code.toString());

    if code is string {
        log:printDebug("Returning valid rejection reason code: " + code);
        return code.ensureType();
    }

    log:printDebug("No valid rejection reason found, returning error");
    return error("Provide a valid rejection reason code.");
}

# Retrieves the corresponding ISO 20022 message name based on the given SWIFT message type.
#
# + messageName - A `string?` representing the SWIFT message type (e.g., `"101"`, `"103"`, etc.).
# + return - Returns a `string` representing the corresponding ISO 20022 message name.
isolated function getOrignalMessageName(string? messageName) returns string {
    log:printDebug("Starting getOrignalMessageName with messageName: " + messageName.toString());

    string result = "";
    match messageName {
        "101" => {
            result = "pain.001";
            log:printDebug("Mapped MT101 to " + result);
        }
        "102"|"103" => {
            result = "pacs.008";
            log:printDebug("Mapped MT102/MT103 to " + result);
        }
        "104"|"107" => {
            result = "pacs.003";
            log:printDebug("Mapped MT104/MT107 to " + result);
        }
        "200"|"201"|"202"|"202COV"|"203"|"205"|"205COV" => {
            result = "pacs.009";
            log:printDebug("Mapped MT200/MT201/MT202/MT202COV/MT203/MT205/MT205COV to " + result);
        }
        "204" => {
            result = "pacs.010";
            log:printDebug("Mapped MT204 to " + result);
        }
        "210" => {
            result = "camt.057";
            log:printDebug("Mapped MT210 to " + result);
        }
        _ => {
            log:printDebug("No mapping found for message type: " + messageName.toString());
        }
    }

    return result;
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
    log:printDebug("Starting getUnderlyingCustomerTransactionField52 with ordgInstn1: " + ordgInstn1.toString() +
                ", ordgInstn2: " + ordgInstn2.toString());

    if ordgInstn1 is swiftmt:MT52A {
        log:printDebug("Using ordgInstn1 (MT52A), returning [ordgInstn1, ()]");
        return [ordgInstn1, ()];
    }

    if ordgInstn2 is swiftmt:MT52D {
        log:printDebug("Using ordgInstn2 (MT52D), returning [(), ordgInstn2]");
        return [(), ordgInstn2];
    }

    log:printDebug("No transaction-specific fields found, using block4 fields: [block4.MT52A, block4.MT52D]");
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
    log:printDebug("Starting getUnderlyingCustomerTransactionField57 with cdtrAgt1: " + cdtrAgt1.toString() +
                ", cdtrAgt2: " + cdtrAgt2.toString() +
                ", cdtrAgt3: " + cdtrAgt3.toString() +
                ", cdtrAgt4: " + cdtrAgt4.toString());

    if cdtrAgt1 is swiftmt:MT57A {
        log:printDebug("Using cdtrAgt1 (MT57A), returning [cdtrAgt1, (), (), ()]");
        return [cdtrAgt1, (), (), ()];
    }

    if cdtrAgt2 is swiftmt:MT57B {
        log:printDebug("Using cdtrAgt2 (MT57B), returning [(), cdtrAgt2, (), ()]");
        return [(), cdtrAgt2, (), ()];
    }

    if cdtrAgt3 is swiftmt:MT57C {
        log:printDebug("Using cdtrAgt3 (MT57C), returning [(), (), cdtrAgt3, ()]");
        return [(), (), cdtrAgt3, ()];
    }

    if cdtrAgt4 is swiftmt:MT57D {
        log:printDebug("Using cdtrAgt4 (MT57D), returning [(), (), (), cdtrAgt4]");
        return [(), (), (), cdtrAgt4];
    }

    log:printDebug("No transaction-specific fields found, using block4 fields: [block4.MT58A, (), (), block4.MT58D]");
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
    log:printDebug("Starting getOtherId with account1: " + account1.toString() +
                ", account2: " + account2.toString() +
                ", account3: " + account3.toString() +
                ", prtyIdn: " + prtyIdn.toString() +
                ", isDebtor: " + isDebtor.toString());

    if account1 is swiftmt:Acc || account2 is swiftmt:Acc || account3 is swiftmt:Acc || prtyIdn is swiftmt:PrtyIdn {
        log:printDebug("At least one account or party ID is provided, returning null");
        return ();
    }

    if isDebtor {
        log:printDebug("No accounts provided and isDebtor=true, returning NOTPROVIDED with TxId scheme");
        return [
            {
                Id: "NOTPROVIDED",
                SchmeNm: {
                    Cd: "TXID"
                }
            }
        ];
    }

    log:printDebug("No accounts provided and isDebtor=false, returning NOTPROVIDED without scheme");
    return [
        {
            Id: "NOTPROVIDED"
        }
    ];
}

# Extracts a status confirmation code from the given narration string if certain conditions are met.
#
# + narration - A `string` containing the narration from which the status confirmation code is to be extracted.
# + return - A `string` containing the extracted status confirmation code (substring from the 1st to the 5th character) 
# if the narration satisfies the following conditions:The length of the narration is greater than 4.
# the narration starts with any of the prefixes: `"/CNCL"`, `"/PDCR"`, or `"RJCR"`.
# Returns () if the narration does not meet the above conditions.
isolated function getStatusConfirmation(string narration) returns string? {
    log:printDebug("Starting getStatusConfirmation with narration: " + narration);

    if narration.length() > 4 && (narration.startsWith("/CNCL") || narration.startsWith("/PDCR")
    || narration.startsWith("RJCR")) {
        string result = narration.substring(1, 5);
        log:printDebug("Narration meets criteria, returning status code: " + result);
        return result;
    }

    log:printDebug("Narration does not meet criteria for status confirmation, returning null");
    return ();
}

isolated function getDebtorAgent(swiftmt:MT910Block4 block4) returns
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? {
    log:printDebug("Starting getDebtorAgent with block4");

    if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
        log:printDebug("MT50A, MT50F, or MT50K is present, returning null");
        return ();
    }

    log:printDebug("Getting financial institution from MT52A/MT52D");
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? result =
        getFinancialInstitution(block4.MT52A?.IdnCd?.content, block4.MT52D?.Nm, block4.MT52A?.PrtyIdn,
            block4.MT52D?.PrtyIdn, (), (), block4.MT52D?.AdrsLine);

    log:printDebug("Returning debtor agent: " + result.toString());
    return result;
}

isolated function getDebtorAgent2(swiftmt:MT910Block4 block4) returns
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? {
    log:printDebug("Starting getDebtorAgent2 with block4");

    if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
        log:printDebug("MT50A, MT50F, or MT50K is present, getting financial institution from MT52A/MT52D");
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? result =
            getFinancialInstitution(block4.MT52A?.IdnCd?.content, block4.MT52D?.Nm, block4.MT52A?.PrtyIdn,
                block4.MT52D?.PrtyIdn, (), (), block4.MT52D?.AdrsLine);

        log:printDebug("Returning debtor agent: " + result.toString());
        return result;
    }

    log:printDebug("No MT50A, MT50F, or MT50K present, returning null");
    return ();
}

isolated function getDebtor(swiftmt:MT910Block4 block4) returns pacsIsoRecord:PartyIdentification272? {
    log:printDebug("Starting getDebtor with block4");

    if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
        log:printDebug("MT50A, MT50F, or MT50K is present, getting debtor information");
        pacsIsoRecord:PartyIdentification272? result = getDebtorOrCreditor(block4.MT50A?.IdnCd, block4.MT50A?.Acc,
                block4.MT50K?.Acc, (), block4.MT50F?.PrtyIdn,
                block4.MT50F?.Nm, block4.MT50K?.Nm,
                block4.MT50F?.AdrsLine, block4.MT50K?.AdrsLine,
                block4.MT50F?.CntyNTw, true);

        log:printDebug("Returning debtor: " + result.toString());
        return result;
    }

    log:printDebug("No MT50A, MT50F, or MT50K present, returning null");
    return ();
}

isolated function getDebtorAccount(swiftmt:MT910Block4 block4) returns pacsIsoRecord:CashAccount40? {
    log:printDebug("Starting getDebtorAccount with block4");

    if block4.MT50A is swiftmt:MT50A || block4.MT50F is swiftmt:MT50F || block4.MT50K is swiftmt:MT50K {
        log:printDebug("MT50A, MT50F, or MT50K is present, getting cash account from MT50 fields");
        pacsIsoRecord:CashAccount40? result = getCashAccount2(block4.MT50A?.Acc, block4.MT50K?.Acc, (), block4.MT50F?.PrtyIdn);

        log:printDebug("Returning debtor account from MT50 fields: " + result.toString());
        return result;
    }

    log:printDebug("No MT50A, MT50F, or MT50K present, getting cash account from MT52 fields");
    pacsIsoRecord:CashAccount40? result = getCashAccount(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn);

    log:printDebug("Returning debtor account from MT52 fields: " + result.toString());
    return result;
}

isolated function getDebtorForPacs004(swiftmt:MT50A? field50A, swiftmt:MT50F? field50F, swiftmt:MT50K? field50K, string? regulatoryReport) returns pacsIsoRecord:Party50Choice {
    log:printDebug("Starting getDebtorForPacs004 with field50A: " + field50A.toString() +
                ", field50F: " + field50F.toString() +
                ", field50K: " + field50K.toString() +
                ", regulatoryReport: " + regulatoryReport.toString());

    if field50K?.Acc?.content == "/NOTPROVIDED" {
        log:printDebug("Account is '/NOTPROVIDED', returning Agent information");
        pacsIsoRecord:Party50Choice result = {
            Agt: {
                FinInstnId: {
                    ClrSysMmbId: {
                        MmbId: "NOTPROVIDED",
                        ClrSysId: {
                            Cd: getName(field50K?.Nm)
                        }
                    },
                    PstlAdr: {
                        AdrLine: getAddressLine(field50K?.AdrsLine)
                    }
                }
            }
        };

        log:printDebug("Returning debtor as Agent: " + result.toString());
        return result;
    }

    log:printDebug("Constructing Party information");
    var partyId = getPartyIdentifierOrAccount(field50F?.PrtyIdn);
    string[]? addressLine = getAddressLineForDbtrOrCdtr(field50F?.AdrsLine, field50K?.AdrsLine, field50F?.CntyNTw);
    string? name = getName(field50F?.Nm, field50K?.Nm);
    string? ctryOfRes = getCountryOfResidence(regulatoryReport, true);

    pacsIsoRecord:Party50Choice result = {
        Pty: {
            Id: {
                OrgId: {
                    AnyBIC: field50A?.IdnCd?.content,
                    Othr: getOtherId((), (), isDebtor = true)
                },
                PrvtId: {
                    Othr: [
                        {
                            Id: partyId[0],
                            SchmeNm: {
                                Cd: partyId[3]
                            },
                            Issr: partyId[4]
                        }
                    ]
                }
            },
            Nm: name,
            CtryOfRes: ctryOfRes,
            PstlAdr: {
                AdrLine: addressLine
            }
        }
    };

    log:printDebug("Returning debtor as Party: " + result.toString());
    return result;
}

isolated function getCreditorForPacs004(swiftmt:MT59? field59, swiftmt:MT59A? field59A, swiftmt:MT59F? field59F, string? regulatoryReport) returns pacsIsoRecord:Party50Choice {
    log:printDebug("Starting getCreditorForPacs004 with field59: " + field59.toString() +
                ", field59A: " + field59A.toString() +
                ", field59F: " + field59F.toString() +
                ", regulatoryReport: " + regulatoryReport.toString());

    if field59?.Acc?.content == "/NOTPROVIDED" {
        log:printDebug("Account is '/NOTPROVIDED', returning Agent information");
        pacsIsoRecord:Party50Choice result = {
            Agt: {
                FinInstnId: {
                    ClrSysMmbId: {
                        MmbId: "NOTPROVIDED",
                        ClrSysId: {
                            Cd: getName(field59?.Nm)
                        }
                    },
                    PstlAdr: {
                        AdrLine: getAddressLine(field59?.AdrsLine)
                    }
                }
            }
        };
        log:printDebug("Returning creditor as Agent: " + result.toString());
        return result;
    }

    log:printDebug("Constructing Party information");
    string? name = getName(field59F?.Nm, field59?.Nm);
    string[]? addressLine = getAddressLineForDbtrOrCdtr(field59F?.AdrsLine, field59?.AdrsLine, field59F?.CntyNTw);
    string? ctryOfRes = getCountryOfResidence(regulatoryReport, false);

    pacsIsoRecord:Party50Choice result = {
        Pty: {
            Id: {
                OrgId: {
                    AnyBIC: field59A?.IdnCd?.content,
                    Othr: getOtherId((), ())
                }
            },
            Nm: name,
            CtryOfRes: ctryOfRes,
            PstlAdr: {
                AdrLine: addressLine
            }
        }
    };

    log:printDebug("Returning creditor as Party: " + result.toString());
    return result;
}

isolated function get103Or202RETNSndRcvrInfoForPacs004(swiftmt:MT72? sndRcvInfo) returns
    [string?, string?, pacsIsoRecord:PaymentReturnReason7[], pacsIsoRecord:Charges16[]]|error {
    log:printDebug("Starting get103RETNSndRcvrInfoForPacs004 with sndRcvInfo: " + sndRcvInfo.toString());

    if sndRcvInfo is swiftmt:MT72 {
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        log:printDebug("Parsed info array from sender-to-receiver information: " + infoArray.toString());

        pacsIsoRecord:PaymentReturnReason7[] returnReasonArray = [];
        pacsIsoRecord:Charges16[] chargesInfoArray = [];
        [string?, string?] [instructionId, endToEndId] = [];

        foreach int i in 1 ... infoArray.length() - 1 {
            log:printDebug("Processing infoArray[" + i.toString() + "]: " + infoArray[i]);

            if i + 1 <= infoArray.length() - 1 && (infoArray[i].trim().matches(re `^[A-Z]{4}$`)) {
                if infoArray[i].includes("MREF") {
                    instructionId = infoArray[i + 1];
                    log:printDebug("Found MREF, setting instructionId: " + instructionId.toString());
                } else if infoArray[i].includes("TREF") {
                    endToEndId = infoArray[i + 1];
                    log:printDebug("Found TREF, setting endToEndId: " + endToEndId.toString());
                } else if infoArray[i].equalsIgnoreCaseAscii("CHGS") && infoArray[i + 1].matches(re `^[A-Z]{3}\d{1,15},\d{0,5}$`) {
                    log:printDebug("Found CHGS pattern, processing charges info: " + infoArray[i + 1]);
                    swiftmt:Amnt amount = {content: infoArray[i + 1].substring(3)};
                    decimal convertedAmount = check convertToDecimalMandatory(amount);

                    chargesInfoArray.push({
                        Amt: {
                            content: convertedAmount,
                            Ccy: infoArray[i + 1].substring(0, 3)
                        },
                        Agt: {
                            FinInstnId: {Nm: "NOTPROVIDED", PstlAdr: {AdrLine: ["NOTPROVIDED"]}}
                        }
                    });
                    log:printDebug("Added charges info with amount: " + convertedAmount.toString() +
                                ", currency: " + infoArray[i + 1].substring(0, 3));
                } else if infoArray[i].equalsIgnoreCaseAscii("TEXT") {
                    log:printDebug("Found TEXT, adding additional info: " + infoArray[i + 1]);
                    returnReasonArray.push({
                        AddtlInf: [infoArray[i + 1]]
                    });
                } else if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}`) {
                    log:printDebug("Found reason code pattern: " + infoArray[i] + ", with additional info: " + infoArray[i + 1]);
                    returnReasonArray.push({
                        Rsn: {Cd: infoArray[i]},
                        AddtlInf: [infoArray[i + 1]]
                    });
                }
                continue;
            }

            if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}$`) && infoArray[i].length() == 4 {
                log:printDebug("Found standalone reason code: " + infoArray[i]);
                returnReasonArray.push({
                    Rsn: {Cd: infoArray[i]}
                });
            }
        }

        log:printDebug("Returning parsed information - instructionId: " + instructionId.toString() +
                    ", endToEndId: " + endToEndId.toString() +
                    ", returnReasons: " + returnReasonArray.length().toString() +
                    ", chargesInfo: " + chargesInfoArray.length().toString());

        return [instructionId, endToEndId, returnReasonArray, chargesInfoArray];
    }

    log:printDebug("No sender-to-receiver information provided, returning empty result");
    return [];
}

isolated function getChargesInfo(pacsIsoRecord:Charges16[]? charges, pacsIsoRecord:Charges16[] sndRcvrInfoChrgs) returns pacsIsoRecord:Charges16[]? {
    log:printDebug("Starting getChargesInfo with charges: " + charges.toString() +
                ", sndRcvrInfoChrgs: " + sndRcvrInfoChrgs.toString());

    if charges is pacsIsoRecord:Charges16[] && charges.length() > 0 {
        log:printDebug("Using primary charges information with " + charges.length().toString() + " entries");
        return charges;
    }

    if sndRcvrInfoChrgs.length() > 0 {
        log:printDebug("Using sender-receiver info charges with " + sndRcvrInfoChrgs.length().toString() + " entries");
        return sndRcvrInfoChrgs;
    }

    log:printDebug("No charges information found, returning null");
    return ();
}

isolated function getNameForCdtrAgtInPacs004(swiftmt:MT57B? field57B, string? name, string field57Acct, string[]? field57AdrsLine) returns string? {
    log:printDebug("Starting getNameForCdtrAgtInPacs004 with field57B: " + field57B.toString() +
                ", name: " + name.toString() +
                ", field57Acct: " + field57Acct +
                ", field57AdrsLine: " + field57AdrsLine.toString());

    string? field57PrtyIdn = getPartyIdentifierOrAccount2(field57B?.PrtyIdn)[0];
    log:printDebug("Retrieved field57PrtyIdn: " + field57PrtyIdn.toString());

    if field57B?.PrtyIdn?.content !is () {
        log:printDebug("field57B.PrtyIdn.content is not null");

        if field57PrtyIdn is () && field57AdrsLine is string[] {
            log:printDebug("field57PrtyIdn is null but address lines present, returning NOTPROVIDED");
            return "NOTPROVIDED";
        }

        if field57Acct != "" {
            log:printDebug("field57Acct is not empty, returning /" + field57Acct);
            return "/" + field57Acct;
        }
    }

    log:printDebug("Returning original name: " + name.toString());
    return name;
}

isolated function getAddressForCdtrAgtInPacs004(string field57Acct, string[]? field57AdrsLine) returns string[]? {
    log:printDebug("Starting getAddressForCdtrAgtInPacs004 with field57Acct: " + field57Acct +
                ", field57AdrsLine: " + field57AdrsLine.toString());

    if field57Acct != "" && field57AdrsLine is () {
        log:printDebug("field57Acct is not empty but address lines are null, returning [NOTPROVIDED]");
        return ["NOTPROVIDED"];
    }

    log:printDebug("Returning original address lines: " + field57AdrsLine.toString());
    return field57AdrsLine;
}

isolated function get202Or205RETNSndRcvrInfoForPacs004(swiftmt:MT72? sndRcvInfo) returns [string?, pacsIsoRecord:PaymentReturnReason7[]] {
    log:printDebug("Starting get202Or205RETNSndRcvrInfoForPacs004 with sndRcvInfo: " + sndRcvInfo.toString());

    if sndRcvInfo is swiftmt:MT72 {
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        log:printDebug("Parsed info array from sender-to-receiver information: " + infoArray.toString());

        pacsIsoRecord:PaymentReturnReason7[] returnReasonArray = [];
        string? instructionId = ();

        foreach int i in 1 ... infoArray.length() - 1 {
            log:printDebug("Processing infoArray[" + i.toString() + "]: " + infoArray[i]);

            if i + 1 <= infoArray.length() - 1 && (infoArray[i].trim().matches(re `^[A-Z]{4}$`)) {
                if infoArray[i].includes("MREF") {
                    instructionId = infoArray[i + 1];
                    log:printDebug("Found MREF, setting instructionId: " + instructionId.toString());
                } else if infoArray[i].includes("TEXT") {
                    log:printDebug("Found TEXT, adding additional info: " + infoArray[i + 1]);
                    returnReasonArray.push({
                        AddtlInf: [infoArray[i + 1]]
                    });
                } else if infoArray[i].matches(re `^[A-Z]{2}[0-9]{2}$`) {
                    log:printDebug("Found reason code pattern: " + infoArray[i] + ", with additional info: " + infoArray[i + 1]);
                    returnReasonArray.push({
                        Rsn: {Cd: infoArray[i]},
                        AddtlInf: [infoArray[i + 1]]
                    });
                }
                continue;
            }

            if infoArray[i].matches(re `^[A-Z]{2}[0-9]{2}$`) && infoArray[i].length() == 4 {
                log:printDebug("Found standalone reason code: " + infoArray[i]);
                returnReasonArray.push({
                    Rsn: {Cd: infoArray[i]}
                });
            }
        }

        log:printDebug("Returning parsed information - instructionId: " + instructionId.toString() +
                    ", returnReasons: " + returnReasonArray.length().toString());

        return [instructionId, returnReasonArray];
    }

    log:printDebug("No sender-to-receiver information provided, returning empty result");
    return [];
}

isolated function getCountryOfResidence(string? regulatoryReport, boolean isDebtor) returns string? {
    log:printDebug("Starting getCountryOfResidence with regulatoryReport: " + regulatoryReport.toString() +
                ", isDebtor: " + isDebtor.toString());

    if regulatoryReport is string && regulatoryReport.length() > 11 {
        if regulatoryReport.substring(1, 9) == "ORDERRES" && isDebtor {
            log:printDebug("Found ORDERRES pattern for debtor, returning country code: " +
                        regulatoryReport.substring(10, 12));
            return regulatoryReport.substring(10, 12);
        }

        if regulatoryReport.substring(1, 9) == "BENEFRES" && !isDebtor {
            log:printDebug("Found BENEFRES pattern for creditor, returning country code: " +
                        regulatoryReport.substring(10, 12));
            return regulatoryReport.substring(10, 12);
        }

        log:printDebug("Regulatory report pattern doesn't match current party type");
    }

    log:printDebug("No valid country of residence found, returning null");
    return ();
}

isolated function getInfoFromField79ForPacs002(swiftmt:Nrtv[]? narrativeArray) returns
    [pacsIsoRecord:Max105Text[], string?, string?, string?, string?] {
    log:printDebug("Starting getInfoFromField79ForPacs002 with narrativeArray: " + narrativeArray.toString());

    if narrativeArray is swiftmt:Nrtv[] {
        [pacsIsoRecord:Max105Text[], string?, string?, string?, string?] [addtnlInfo, messageId, endToEndId, uetr,
                reason] = [];

        log:printDebug("Processing " + narrativeArray.length().toString() + " narrative elements");

        foreach swiftmt:Nrtv narration in narrativeArray {
            log:printDebug("Processing narration content: " + narration.content);

            if narration.content.startsWith("/MREF/") && narration.content.length() > 6 {
                messageId = narration.content.substring(6);
                log:printDebug("Found message ID: " + messageId.toString());
            }

            if narration.content.startsWith("/TREF/") && narration.content.length() > 6 {
                endToEndId = narration.content.substring(6);
                log:printDebug("Found end-to-end ID: " + endToEndId.toString());
            }

            if narration.content.startsWith("/TEXT//UETR/") && narration.content.length() > 12 {
                uetr = narration.content.substring(12);
                log:printDebug("Found UETR: " + uetr.toString());
            }

            if !narration.content.startsWith("/REJT/") && narration.content.length() > 4
                    && narration.content.substring(1, 5).matches(re `[A-Z]{2}[0-9]{2}`) {
                reason = narration.content.substring(1, 5);
                log:printDebug("Found reason code: " + reason.toString());

                if narration.content.length() > 6 {
                    if narration.content.endsWith("/") {
                        addtnlInfo.push(narration.content.substring(6, narration.content.length() - 1));
                    } else {
                        addtnlInfo.push(narration.content.substring(6));
                    }
                    log:printDebug("Added additional info from reason: " + narration.content.substring(6));
                }
            }

            if narration.content.startsWith("/TEXT/") && !narration.content.includes("/UETR/") &&
                    narration.content.length() > 6 {
                addtnlInfo.push(narration.content.substring(6));
                log:printDebug("Added additional info from /TEXT/: " + narration.content.substring(6));
            }
        }

        log:printDebug("Returning info - additionalInfo: " + addtnlInfo.length().toString() +
                    " items, messageId: " + messageId.toString() +
                    ", endToEndId: " + endToEndId.toString() +
                    ", uetr: " + uetr.toString() +
                    ", reason: " + reason.toString());
        return [addtnlInfo, messageId, endToEndId, uetr, reason];
    }

    log:printDebug("No narrative array provided, returning empty result");
    return [];
}

isolated function getCashAccount(swiftmt:PrtyIdn? acc1, swiftmt:PrtyIdn? acc2, swiftmt:PrtyIdn? acc3 = (), swiftmt:PrtyIdn? acc4 = ()) returns pacsIsoRecord:CashAccount40? {
    log:printDebug("Starting getCashAccount with acc1: " + acc1.toString() +
                ", acc2: " + acc2.toString() +
                ", acc3: " + acc3.toString() +
                ", acc4: " + acc4.toString());

    [string?, string?, string?] [_, iban, bban] = getPartyIdentifierOrAccount2(acc1, acc2, acc3, acc4);
    log:printDebug("Retrieved identifier details - iban: " + iban.toString() + ", bban: " + bban.toString());

    if iban is () && bban is () {
        log:printDebug("No valid IBAN or BBAN found, returning null");
        return ();
    }

    pacsIsoRecord:CashAccount40 result = {
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

    log:printDebug("Returning CashAccount40 with IBAN: " + iban.toString() + ", BBAN: " + bban.toString());
    return result;
}

isolated function getFinancialInstitution(string? idnCd, swiftmt:Nm[]? name, swiftmt:PrtyIdn? prtyIdn1, swiftmt:PrtyIdn? prtyIdn2,
        swiftmt:PrtyIdn? prtyIdn3 = (), swiftmt:PrtyIdn? prtyIdn4 = (), swiftmt:AdrsLine[]? adrsLine1 = (),
        string? adrsLine2 = ()) returns pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? {
    log:printDebug("Starting getFinancialInstitution with idnCd: " + idnCd.toString() +
                ", name: " + name.toString() +
                ", prtyIdn1: " + prtyIdn1.toString() +
                ", prtyIdn2: " + prtyIdn2.toString() +
                ", prtyIdn3: " + prtyIdn3.toString() +
                ", prtyIdn4: " + prtyIdn4.toString() +
                ", adrsLine1: " + adrsLine1.toString() +
                ", adrsLine2: " + adrsLine2.toString());

    string? partyIdentifier = getPartyIdentifierOrAccount2(prtyIdn1, prtyIdn2, prtyIdn3, prtyIdn4)[0];
    log:printDebug("Retrieved party identifier: " + partyIdentifier.toString());

    string[]? adrsLine = getAddressLine(adrsLine1, address3 = adrsLine2);
    log:printDebug("Retrieved address lines: " + adrsLine.toString());

    string? nameStr = getName(name);
    log:printDebug("Retrieved name: " + nameStr.toString());

    if idnCd is string || nameStr is string || partyIdentifier is string || adrsLine is string[] {
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 result = {
            FinInstnId: {
                BICFI: idnCd,
                ClrSysMmbId: partyIdentifier is () ? () : {
                        MmbId: "NOTPROVIDED",
                        ClrSysId: {
                            Cd: partyIdentifier
                        }
                    },
                Nm: nameStr,
                PstlAdr: adrsLine is () ? () : {
                        AdrLine: adrsLine
                    }
            }
        };

        log:printDebug("Returning financial institution with BICFI: " + idnCd.toString() +
                    ", ClrSysMmbId: " + partyIdentifier.toString() +
                    ", Name: " + nameStr.toString() +
                    ", Address lines: " + (adrsLine is string[] ? adrsLine.length().toString() : "null"));
        return result;
    }

    log:printDebug("No valid institution identification data found, returning null");
    return ();
}

isolated function getCashAccount2(swiftmt:Acc? acc1, swiftmt:Acc? acc2, swiftmt:Acc? acc3 = (), swiftmt:PrtyIdn? acc4 = ()) returns pacsIsoRecord:CashAccount40? {
    log:printDebug("Starting getCashAccount2 with acc1: " + acc1.toString() +
                ", acc2: " + acc2.toString() +
                ", acc3: " + acc3.toString() +
                ", acc4: " + acc4.toString());

    [string?, string?] validatedAccounts = validateAccountNumber(acc1, acc2, acc3);
    log:printDebug("Validated account numbers: " + validatedAccounts.toString());

    [string?, string?, string?, string?, string?] partyIdn = getPartyIdentifierOrAccount(acc4);
    log:printDebug("Retrieved party identifiers: " + partyIdn.toString());

    string? iban = getAccountId(validatedAccounts[0], partyIdn[1]);
    string? bban = getAccountId(validatedAccounts[1], partyIdn[2]);

    log:printDebug("Final account IDs - iban: " + iban.toString() + ", bban: " + bban.toString());

    if iban is () && bban is () {
        log:printDebug("No valid IBAN or BBAN found, returning null");
        return ();
    }

    pacsIsoRecord:CashAccount40 result = {
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

    log:printDebug("Returning CashAccount40 with IBAN: " + iban.toString() +
                ", BBAN: " + bban.toString() +
                ", SchemeName: " + (bban == "NOTPROVIDED" ? "TXID" : "null"));
    return result;
}

isolated function getDebtorOrCreditor(swiftmt:IdnCd? identifierCode, swiftmt:Acc? acc1, swiftmt:Acc? acc2,
        swiftmt:Acc? acc3, swiftmt:PrtyIdn? prtyIdn, swiftmt:Nm[]? name1, swiftmt:Nm[]? name2, swiftmt:AdrsLine[]? address1,
        swiftmt:AdrsLine[]? address2, swiftmt:CntyNTw[]? country = (), boolean isDebtor = false, swiftmt:Nrtv? narrative = (), boolean isMt101 = false) returns pacsIsoRecord:PartyIdentification272 {
    log:printDebug("Starting getDebtorOrCreditor with identifierCode: " + identifierCode.toString() +
                ", acc1: " + acc1.toString() +
                ", acc2: " + acc2.toString() +
                ", acc3: " + acc3.toString() +
                ", prtyIdn: " + prtyIdn.toString() +
                ", name1: " + name1.toString() +
                ", name2: " + name2.toString() +
                ", isDebtor: " + isDebtor.toString() +
                ", narrative: " + narrative.toString());

    pacsIsoRecord:GenericOrganisationIdentification3[]? otherId = getOtherId(acc1, acc2, acc3, prtyIdn, isDebtor);
    log:printDebug("Retrieved other IDs: " + otherId.toString());

    [string?, string?, string?, string?, string?] [partyIdentifier, _, _, code, issr] =
            getPartyIdentifierOrAccount(prtyIdn);
    log:printDebug("Retrieved party identifier: " + partyIdentifier.toString() +
                ", code: " + code.toString() +
                ", issuer: " + issr.toString());

    string[]? adrsLine = getAddressLineForDbtrOrCdtr(address1, address2, country);
    log:printDebug("Retrieved address lines: " + adrsLine.toString());
    string? streetName = getStreetName(address1, address2);
    [string?, string?] [cntry, townName] = getCountryAndTown(country, address1, address2);

    string? nameStr = getName(name1, name2);
    log:printDebug("Retrieved name: " + nameStr.toString());

    string? ctryOfRes = getCountryOfResidence(narrative?.content, isDebtor);
    log:printDebug("Retrieved country of residence: " + ctryOfRes.toString());

    pacsIsoRecord:PartyIdentification272 result = {
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
        CtryOfRes: ctryOfRes,
        Nm: nameStr,
        PstlAdr: adrsLine is () ? () : isMt101 ? {
                StrtNm: streetName,
                TwnNm: townName,
                Ctry: cntry
            } : {
                AdrLine: adrsLine
            }
    };

    log:printDebug("Returning " + (isDebtor ? "debtor" : "creditor") + " with" +
                " OrgId.AnyBIC: " + identifierCode?.content.toString() +
                ", PrvtId.Othr.Id: " + partyIdentifier.toString() +
                ", Name: " + nameStr.toString() +
                ", CountryOfResidence: " + ctryOfRes.toString() +
                ", Address lines: " + (adrsLine is string[] ? adrsLine.length().toString() : "null"));
    return result;
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
    log:printDebug("Starting getAddressLineForDbtrOrCdtr with address1: " + address1.toString() +
                ", address2: " + address2.toString() +
                ", country: " + country.toString());

    swiftmt:AdrsLine[] finalAddress = [];
    string[] addressLine = [];
    boolean isOptionF = false;

    if address1 is swiftmt:AdrsLine[] {
        finalAddress = address1;
        isOptionF = true;
        log:printDebug("Using address1 with " + address1.length().toString() + " lines, isOptionF=true");
    } else if address2 is swiftmt:AdrsLine[] {
        finalAddress = address2;
        log:printDebug("Using address2 with " + address2.length().toString() + " lines, isOptionF=false");
    } else {
        log:printDebug("No address lines found, returning null");
        return ();
    }

    if isOptionF {
        log:printDebug("Processing address lines with Option F format");

        foreach swiftmt:AdrsLine address in finalAddress {
            addressLine.push("2/" + address.content);
            log:printDebug("Added Option F address line: 2/" + address.content);
        }

        if country is swiftmt:CntyNTw[] {
            addressLine.push("3/" + country[0].content);
            log:printDebug("Added Option F country line: 3/" + country[0].content);
        }

        log:printDebug("Returning " + addressLine.length().toString() + " Option F address lines");
        return addressLine;
    }

    log:printDebug("Processing address lines with standard format");
    string[] result = from swiftmt:AdrsLine adrsLine in finalAddress
        select adrsLine.content;

    log:printDebug("Returning " + result.length().toString() + " standard address lines");
    return result;
}

isolated function getChargesAmount(string narration) returns camtIsoRecord:ChargesBreakdown1[]|error {
    log:printDebug("Starting getChargesAmount with narration: " + narration);

    string amount = "";
    string currency = "";
    string code = "";
    boolean isAmount = false;

    log:printDebug("Parsing narration character by character");
    foreach int i in 1 ... narration.length() - 1 {
        if isAmount && (narration.substring(i, i + 1).matches(re `^[0-9]$`) || narration.substring(i, i + 1) == ",") {
            amount += narration.substring(i, i + 1);
            log:printDebug("Added digit to amount: " + narration.substring(i, i + 1) + ", current amount: " + amount);
            continue;
        }
        if narration.substring(i, i + 1) == "/" {
            log:printDebug("Found '/' character at position " + i.toString());

            if isAmount {
                log:printDebug("Already found amount, breaking loop");
                break;
            }

            if narration.length() - 1 >= i + 3 {
                currency = narration.substring(i + 1, i + 4);
                log:printDebug("Extracted currency: " + currency);
            }

            code = narration.substring(1, i);
            log:printDebug("Extracted code: " + code);
            isAmount = true;
        }
    }

    log:printDebug("Parsing complete, raw amount: " + amount);

    if amount.endsWith(",") {
        amount = amount.substring(0, amount.length() - 1);
        log:printDebug("Removed trailing comma, amount: " + amount);
    } else {
        amount = regexp:replace(re `\\,`, amount, ".");
        log:printDebug("Replaced commas with decimal points, amount: " + amount);
    }

    decimal decimalAmount = check decimal:fromString(amount);
    log:printDebug("Converted to decimal: " + decimalAmount.toString());

    camtIsoRecord:ChargesBreakdown1[] result = [
        {
            Amt: {content: decimalAmount, Ccy: currency},
            Tp: {Cd: code},
            CdtDbtInd: "DBIT"
        }
    ];

    log:printDebug("Returning charges breakdown with amount: " + decimalAmount.toString() +
                ", currency: " + currency +
                ", code: " + code);

    return result;
}

isolated function get103REJTSndRcvrInfoForPacs004(swiftmt:MT72? sndRcvInfo) returns
    [string?, string?, pacsIsoRecord:StatusReasonInformation14[]]|error {
    log:printDebug("Starting get103REJTSndRcvrInfoForPacs004 with sndRcvInfo: " + sndRcvInfo.toString());

    if sndRcvInfo is swiftmt:MT72 {
        string[] infoArray = getCodeAndAddtnlInfo(sndRcvInfo.Cd.content);
        log:printDebug("Parsed info array from sender-to-receiver information: " + infoArray.toString());

        int index = 0;
        pacsIsoRecord:PaymentReturnReason7[] statusReasonArray = [];
        [string?, string?] [instructionId, endToEndId] = [];

        foreach int i in 0 ... infoArray.length() - 1 {
            log:printDebug("Processing infoArray[" + i.toString() + "]: " + infoArray[i]);

            if index == i {
                log:printDebug("Skipping already processed index");
                continue;
            }

            if i + 1 <= infoArray.length() - 1 && !(infoArray[i + 1].matches(re `^[A-Z]{2,8}$`)) {
                index = i + 1;

                if infoArray[i].equalsIgnoreCaseAscii("MREF") {
                    instructionId = infoArray[i + 1];
                    log:printDebug("Found MREF, setting instructionId: " + instructionId.toString());
                } else if infoArray[i].equalsIgnoreCaseAscii("TREF") {
                    endToEndId = infoArray[i + 1];
                    log:printDebug("Found TREF, setting endToEndId: " + endToEndId.toString());
                } else if infoArray[i].equalsIgnoreCaseAscii("TEXT") {
                    log:printDebug("Found TEXT, adding additional info: " + infoArray[i + 1]);
                    statusReasonArray.push({
                        AddtlInf: [infoArray[i + 1]]
                    });
                } else if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}`) {
                    log:printDebug("Found reason code pattern: " + infoArray[i] + ", with additional info: " + infoArray[i + 1]);
                    statusReasonArray.push({
                        Rsn: {Cd: infoArray[i]},
                        AddtlInf: [infoArray[i + 1]]
                    });
                }
                continue;
            }

            if infoArray[i].matches(re `[A-Z]{2}[0-9]{2}$`) {
                log:printDebug("Found standalone reason code: " + infoArray[i]);
                statusReasonArray.push({
                    Rsn: {Cd: infoArray[i]}
                });
            }
        }

        log:printDebug("Returning parsed information - instructionId: " + instructionId.toString() +
                    ", endToEndId: " + endToEndId.toString() +
                    ", statusReasons: " + statusReasonArray.length().toString());

        return [instructionId, endToEndId, statusReasonArray];
    }

    log:printDebug("No sender-to-receiver information provided, returning empty result");
    return [];
}

isolated function getOrgnlUETR(string? narration) returns string? {
    log:printDebug("Starting getOrgnlUETR with narration: " + narration.toString());

    if narration is string && narration.startsWith("/UETR/") && narration.length() > 6 {
        log:printDebug("Found UETR pattern in narration");

        string narrative = "";
        foreach int i in 6 ... narration.length() - 1 {
            if narration.substring(i, i + 1) == "/" {
                log:printDebug("Skipping '/' character at position " + i.toString());
                continue;
            }

            narrative += narration.substring(i, i + 1);
            log:printDebug("Building narrative, current: " + narrative);
        }

        if narrative != "" {
            log:printDebug("Returning UETR: " + narrative);
            return narrative;
        }
    }

    log:printDebug("No valid UETR found, returning null");
    return ();
}

isolated function getChrgRqstrAndInstrFrAgt(string? narration) returns [string?, string?, string?] {
    log:printDebug("Starting getChrgRqstrAndInstrFrAgt with narration: " + narration.toString());

    if narration is string {
        string[] infoArray = getCodeAndAddtnlInfo(narration);
        log:printDebug("Parsed info array from narration: " + infoArray.toString());

        [string?, string?, string?] [chrgRqstr, instr, info] = [];

        foreach int i in 0 ... infoArray.length() - 1 {
            log:printDebug("Processing infoArray[" + i.toString() + "]: " + infoArray[i]);

            if infoArray[i].equalsIgnoreCaseAscii("CHRQ") {
                chrgRqstr = infoArray.length() > i + 1 ? infoArray[i + 1] : ();
                log:printDebug("Found CHRQ, setting charge requester: " + chrgRqstr.toString());
                continue;
            }

            if infoArray[i].length() == 4 {
                instr = infoArray[i];
                info = infoArray.length() > i + 1 && !infoArray[i + 1].equalsIgnoreCaseAscii("CHRQ") ?
                    infoArray[i + 1] : ();

                log:printDebug("Found instruction code: " + instr.toString() + ", info: " + info.toString());
            }
        }

        log:printDebug("Returning charge requester: " + chrgRqstr.toString() +
                    ", instruction: " + instr.toString() +
                    ", info: " + info.toString());

        return [chrgRqstr, instr, info];
    }

    log:printDebug("No narration provided, returning empty result");
    return [];
}

isolated function getOriginalMsgNameAndId(swiftmt:Nrtv[]? narrativeArray) returns [string?, string?] {
    log:printDebug("Starting getOriginalMsgNameAndId with narrativeArray: " + narrativeArray.toString());

    if narrativeArray is () {
        log:printDebug("No narrative array provided, returning null values");
        return [];
    }

    [string?, string?] [originalMsgName, originalMsgId] = [];

    foreach swiftmt:Nrtv narration in narrativeArray {
        log:printDebug("Processing narration: " + narration.content);

        if narration.content.startsWith("/MSGTYPE/") && narration.content.length() > 9 {
            originalMsgName = narration.content.substring(9);
            log:printDebug("Found original message type: " + originalMsgName.toString());
        }

        if narration.content.startsWith("/MSGID/") && narration.content.length() > 7 {
            originalMsgId = narration.content.substring(7);
            log:printDebug("Found original message ID: " + originalMsgId.toString());
        }
    }

    log:printDebug("Returning originalMsgName: " + originalMsgName.toString() +
                ", originalMsgId: " + originalMsgId.toString());
    return [originalMsgName, originalMsgId];
}

isolated function extractStatusReason(swiftmt:Nrtv[]? narrativeArray) returns [string?, string[]?, string?] {
    log:printDebug("Starting extractStatusReason with narrativeArray: " + narrativeArray.toString());

    if narrativeArray is () {
        log:printDebug("No narrative array provided, returning null values");
        return [];
    }

    [string?, string[]?, string?] [reason, additionalInformation, statusId] = [];
    string[] addInfo = [];

    foreach swiftmt:Nrtv narration in narrativeArray {
        log:printDebug("Processing narration: " + narration.content);

        if narration.content.startsWith("/STAT/") && narration.content.length() > 6 {
            statusId = narration.content.substring(6);
            log:printDebug("Found status ID: " + statusId.toString());
        }

        if narration.content.startsWith("/RJCT/") && narration.content.length() > 6 {
            reason = narration.content.substring(6, 10);
            log:printDebug("Found rejection reason code: " + reason.toString());

            if narration.content.length() > 10 {
                addInfo.push(narration.content.substring(11));
                log:printDebug("Added additional info: " + narration.content.substring(11));
            }
        }

        if narration.content.startsWith("/ADDINFO/") && narration.content.length() > 9 {
            addInfo.push(narration.content.substring(9));
            log:printDebug("Added additional info from ADDINFO: " + narration.content.substring(9));
        }
    }

    additionalInformation = addInfo.length() > 0 ? addInfo : ();

    log:printDebug("Returning reason: " + reason.toString() +
                ", additionalInformation: " + additionalInformation.toString() +
                ", statusId: " + statusId.toString());
    return [reason, additionalInformation, statusId];
}

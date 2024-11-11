// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
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
import ballerinax/financial.iso20022.cash_management as isorecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms an MT104 message to its corresponding ISO 20022 message format in XML.
# The function checks the instruction code (MT23E) within the message to determine the
# appropriate ISO 20022 message type (Direct Debit or Request for Debit Transfer).
#
# + message - The MT104 SWIFT message to be transformed.
# + return - Returns the transformed XML message or an error if transformation fails.
isolated function getMT104TransformFunction(swiftmt:MT104Message message) returns xml|error {
    if message.block4.MT23E?.InstrnCd?.content is () {
        return error("Instruction code is required to identify ISO 20022 message type.");
    }
    if (check message.block4.MT23E?.InstrnCd?.content.ensureType(string)).equalsIgnoreCaseAscii("AUTH")
        || (check message.block4.MT23E?.InstrnCd?.content.ensureType(string)).equalsIgnoreCaseAscii("NAUT")
        || (check message.block4.MT23E?.InstrnCd?.content.ensureType(string)).equalsIgnoreCaseAscii("OTHR") {
        return xmldata:toXml(check transformMT104DrctDbt(message));
    }
    if (check message.block4.MT23E?.InstrnCd?.content.ensureType(string)).equalsIgnoreCaseAscii("RFDD") {
        return xmldata:toXml(check transformMT104ReqDbtTrf(message));
    }
    return error("Return direct debit transfer message is not supported.");
}

# Converts the given `Amnt` or `Rt` content to a `decimal` value, handling the conversion from a string representation
# that may include commas as decimal separators.
#
# + value - The optional `Amnt` or `Rt` content containing the string value to be converted to a decimal.
# + return - Returns the converted decimal value or `null` in case of an error.
isolated function convertToDecimal(swiftmt:Amnt?|swiftmt:Rt? value) returns decimal|error? {
    do {
        if value is swiftmt:Rt|swiftmt:Amnt {
            if check (value.content.lastIndexOf(",")).ensureType(int) == value.content.length() - 1 {
                return check decimal:fromString(value.content.substring(0, check (value.content.lastIndexOf(",")).ensureType(int)).concat(".").concat("00"));
            }
            return check decimal:fromString(value.content.substring(0, check (value.content.lastIndexOf(",")).ensureType(int)).concat(".").concat(value.content.substring(check (value.content.lastIndexOf(",")).ensureType(int) + 1)));
        }
        return ();
    } on fail {
        return error("Provide decimal value in string for exchange rate and transaction amounts.");
    }
}

# Converts the given `Amnt` or `Rt` content to a `decimal` value, handling the conversion from a string representation
# that may include commas as decimal separators.
#
# + value - The optional `Amnt` or `Rt` content containing the string value to be converted to a decimal.
# + return - Returns the converted decimal value.
isolated function convertToDecimalMandatory(swiftmt:Amnt?|swiftmt:Rt? value) returns decimal|error {
    do {
        if value is swiftmt:Rt|swiftmt:Amnt {
            if check (value.content.lastIndexOf(",")).ensureType(int) == value.content.length() - 1 {
                return check decimal:fromString(value.content.substring(0, check (value.content.lastIndexOf(",")).ensureType(int)).concat(".").concat("00"));
            }
            return check decimal:fromString(value.content.substring(0, check (value.content.lastIndexOf(",")).ensureType(int)).concat(".").concat(value.content.substring(check (value.content.lastIndexOf(",")).ensureType(int) + 1)));
        }
        return 0;
    } on fail {
        return error("Provide decimal value in string for exchange rate and transaction amounts.");
    }
}

# Extracts and returns the remittance information from the provided `MT70` message.
# Depending on the remmitance information code, it returns the remmitance information or an empty string.
#
# + remmitanceInfo - The optional `MT70` object containing remittance information.
# + return - Returns remmitance information as a string or an empty string if no remmitance information was found.
isolated function getRemmitanceInformation(string? remmitanceInfo) returns string {
    if remmitanceInfo is string {
        if remmitanceInfo.substring(1, 4).equalsIgnoreCaseAscii("ROC") {
            return "";
        }
        return remmitanceInfo;
    }
    return "";
}

# Extracts and returns the content of the provided field if it is of type string.
# If the content is not a string, it returns an empty string.
#
# + content - The optional field that may be of type string.
# + return - Returns the string content if the content is a string; otherwise, returns an empty string.
isolated function getMandatoryFields(string? content) returns string {
    if content is string {
        return content;
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
# + return - Returns an array of strings representing the address lines if any address lines are found;
# otherwise, returns `null`.
isolated function getAddressLine(swiftmt:AdrsLine[]? address1, swiftmt:AdrsLine[]? address2 = ()) returns string[]? {
    swiftmt:AdrsLine[] finalAddress;
    if address1 is swiftmt:AdrsLine[] {
        finalAddress = address1;
    } else if address2 is swiftmt:AdrsLine[] {
        finalAddress = address2;
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
    if code is swiftmt:Cd {
        foreach string[] line in chargesCodeArray {
            if line[0].equalsIgnoreCaseAscii(code.content) {
                return line[1];
            }
        }
        return error("Details of charges code is invalid.");
    }
    return error("Details of charges code is madatory.");
}

# Extracts and returns regulatory reporting details from the provided `MT77B` object.
# The function parses the `Nrtv` content of the `MT77B` object to determine the regulatory reporting details
# based on specific content patterns. It returns an array of `RgltryRptg` objects with the extracted details.
#
# + rgltyRptg - An optional `MT77B` object that contains the regulatory reporting information.
# + return - Returns an array of `RgltryRptg` objects with the extracted regulatory reporting details.
# The details are based on the content of the `Nrtv` field within the `MT77B` object.
isolated function getRegulatoryReporting(string? rgltyRptg) returns isorecord:RegulatoryReporting3[]? {
    if rgltyRptg is string {
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
    return ();
}

# Extracts and returns different parts of a party identifier based on its format.
# The function handles different formats of the party identifier and returns a tuple with specific substrings
# or `null` values depending on the conditions.
#
# + prtyIdnOrAcc - An optional `PrtyIdn` object containing the party identifier information.
# + return - Returns a tuple of strings and/or null values based on the party identifier content and the `fields` 
# parameter.
isolated function getPartyIdentifierOrAccount(swiftmt:PrtyIdn? prtyIdnOrAcc) returns [string?, string?, string?, string?, string?] {
    if prtyIdnOrAcc is swiftmt:PrtyIdn && prtyIdnOrAcc.content.length() > 1 {
        if prtyIdnOrAcc.content.substring(0, 1).equalsIgnoreCaseAscii("/") {
            return [(), ...validateAccountNumber(prtyIdn = prtyIdnOrAcc), (), ()];
        }
        if prtyIdnOrAcc.content.startsWith("CUST") || prtyIdnOrAcc.content.startsWith("DRLC")
            || prtyIdnOrAcc.content.startsWith("EMPL") {
            int count = 0;
            foreach int i in 0 ... prtyIdnOrAcc.content.length() - 1 {
                if prtyIdnOrAcc.content.substring(i, i + 1).equalsIgnoreCaseAscii("/") {
                    count += 1;
                }
                if count == 3 {
                    return [
                        prtyIdnOrAcc.content.substring(i + 1),
                        (),
                        (),
                        prtyIdnOrAcc.content.substring(0, 4),
                        prtyIdnOrAcc.content.substring(8, i)
                    ];
                }
            }
            return [prtyIdnOrAcc.content.substring(8), (), (), prtyIdnOrAcc.content.substring(0, 4), ()];
        }
        return [prtyIdnOrAcc.content.toString().substring(8), (), (), prtyIdnOrAcc.content.toString().substring(0, 4), ()];
    }
    return [(), (), (), (), ()];
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
# + return - Returns a tuple of strings and/or null values based on the party identifier content.
isolated function getPartyIdentifierOrAccount2(swiftmt:PrtyIdn? prtyIdn1, swiftmt:PrtyIdn? prtyIdn2 = (), swiftmt:PrtyIdn? prtyIdn3 = ()) returns [string?, string?, string?] {
    if prtyIdn1 is swiftmt:PrtyIdn && prtyIdn1.content.length() > 1 &&
        !(prtyIdn1.content.substring(0, 1).equalsIgnoreCaseAscii("/")) {
        return [prtyIdn1.content, (), ()];
    }
    if prtyIdn2 is swiftmt:PrtyIdn && prtyIdn2.content.length() > 1 &&
        !(prtyIdn2.content.substring(0, 1).equalsIgnoreCaseAscii("/")) {
        return [prtyIdn2.content, (), ()];
    }
    if prtyIdn3 is swiftmt:PrtyIdn && prtyIdn3.content.length() > 1 &&
        !(prtyIdn3.content.substring(0, 1).equalsIgnoreCaseAscii("/")) {
        return [prtyIdn3.content, (), ()];
    }
    if prtyIdn1 is swiftmt:PrtyIdn && prtyIdn1.content.length() > 1 &&
        prtyIdn1.content.substring(0, 1).equalsIgnoreCaseAscii("/") {
        return [(), ...validateAccountNumber(prtyIdn = prtyIdn1)];
    }
    if prtyIdn2 is swiftmt:PrtyIdn && prtyIdn2.content.length() > 1 &&
        prtyIdn2.content.substring(0, 1).equalsIgnoreCaseAscii("/") {
        return [(), ...validateAccountNumber(prtyIdn = prtyIdn2)];
    }
    if prtyIdn3 is swiftmt:PrtyIdn && prtyIdn3.content.length() > 1 &&
        prtyIdn3.content.substring(0, 1).equalsIgnoreCaseAscii("/") {
        return [(), ...validateAccountNumber(prtyIdn = prtyIdn3)];
    }
    return [(), (), ()];
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
    [string?, string?] cntyNTwArray = [];
    if cntyNTw is swiftmt:CntyNTw[] {
        cntyNTwArray[0] = cntyNTw[0].content.substring(0, 2);
        if cntyNTw[0].content.length() > 3 {
            cntyNTwArray[1] = cntyNTw[0].content.substring(3);
            return cntyNTwArray;
        }
        cntyNTwArray[1] = ();
        return cntyNTwArray;
    }
    return [(), ()];
}

# Validates an account number based on the regex pattern.
#
# + acc1 - Optional account number inputs to consider.
# + acc2 - Optional account number inputs to consider.
# + acc3 - Optional account number inputs to consider.
# + prtyIdn - Optional party identifier that may contain an account number.
# + return - Returns a tuple where the first element is the valid IBAN account number or `null`, 
# and the second element is the invalid IBAN account number or `null`.
isolated function validateAccountNumber(swiftmt:Acc? acc1 = (), swiftmt:PrtyIdn? prtyIdn = (), swiftmt:Acc? acc2 = (), swiftmt:Acc? acc3 = ()) returns [string?, string?] {
    string finalAccount = "";
    if acc1 is swiftmt:Acc {
        finalAccount = acc1.content;
    } else if acc2 is swiftmt:Acc {
        finalAccount = acc2.content;
    } else if acc3 is swiftmt:Acc {
        finalAccount = acc3.content;
    } else if prtyIdn is swiftmt:PrtyIdn && prtyIdn.content.length() > 1 {
        finalAccount = prtyIdn.content.substring(1);
    } else {
        return [(), ()];
    }

    if finalAccount.matches(re `^[A-Z]{2}[0-9]{2}[a-zA-Z0-9]{1,30}`) {
        return [finalAccount, ()];
    }
    return [(), finalAccount];
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
isolated function getPartyIdentifier(swiftmt:PrtyIdn? identifier1, swiftmt:PrtyIdn? identifier2 = (), swiftmt:PrtyIdn? identifier3 = (), swiftmt:PrtyIdn? identifier4 = ()) returns string? {
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
isolated function getInstructedAmount(swiftmt:MT32B? transAmnt = (), swiftmt:MT33B? instrdAmnt = (), swiftmt:MT32A? stlmntAmnt = ()) returns decimal|error {
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
isolated function getTotalInterBankSettlementAmount(swiftmt:MT19? sumAmnt = (), swiftmt:MT32A?|swiftmt:MT32B? stlmntAmnt = ()) returns decimal|error {
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
# + return - Returns "BBAN" if any valid account number or party identifier is found, otherwise returns null.
isolated function getSchemaCode(swiftmt:Acc? account1 = (), swiftmt:Acc? account2 = (), swiftmt:Acc? account3 = (), swiftmt:PrtyIdn? prtyIdn1 = (), swiftmt:PrtyIdn? prtyIdn2 = (), swiftmt:PrtyIdn? prtyIdn3 = ()) returns string? {
    if !(validateAccountNumber(account1)[1] is ()) || !(validateAccountNumber(account2)[1] is ())
        || !(validateAccountNumber(account3)[1] is ()) || !(getPartyIdentifierOrAccount(prtyIdn1)[2] is ())
        || !(getPartyIdentifierOrAccount(prtyIdn2)[2] is ()) || !(getPartyIdentifierOrAccount(prtyIdn3)[2] is ()) {
        return "BBAN";
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

# Returns an array of `isorecord:Charges16` objects that contains charges information based on the provided `MT71F` 
# and `MT71G` SWIFT message records.
#
# + sndsChrgs - An optional `swiftmt:MT71F` object that contains information about sender's charges.
# + rcvsChrgs - An optional `swiftmt:MT71G` object that contains information about receiver's charges.
# + return - An array of `isorecord:Charges16` containing two entries:
# - The first entry includes the sender's charges amount and currency, with a charge type of "CRED".
# - The second entry includes the receiver's charges amount and currency, with a charge type of "DEBT".
#
# The function uses helper methods `convertToDecimalMandatory` to convert the amount and `getMandatoryFields` to fetch the currency.
isolated function getChargesInformation(swiftmt:MT71F? sndsChrgs, swiftmt:MT71G? rcvsChrgs) returns isorecord:Charges16[]?|error {
    isorecord:Charges16[] chrgsInf = [];
    if sndsChrgs is swiftmt:MT71F {
        chrgsInf.push({
            Amt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(sndsChrgs?.Amnt),
                    Ccy: getMandatoryFields(sndsChrgs?.Ccy.content)
                }
            },
            Agt: {
                FinInstnId: {}
            },
            Tp: {
                Cd: "CRED"
            }
        });
    }
    if rcvsChrgs is swiftmt:MT71G {
        chrgsInf.push({
            Amt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(rcvsChrgs?.Amnt),
                    Ccy: getMandatoryFields(rcvsChrgs?.Ccy.content)
                }
            },
            Agt: {
                FinInstnId: {}
            },
            Tp: {
                Cd: "DEBT"
            }
        });
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
                return [tmInd.Tm.content.substring(0, 2) + ":" + tmInd.Tm.content.substring(2) + ":00", (), ()];
            }
            "RNCTIME" => {
                return [(), tmInd.Tm.content.substring(0, 2) + ":" + tmInd.Tm.content.substring(2) + ":00", ()];
            }
            "SNDTIME" => {
                return [(), (), tmInd.Tm.content.substring(0, 2) + ":" + tmInd.Tm.content.substring(2) + ":00"];
            }
        }
    }
    return [(), (), ()];
}

# Extracts and returns specific sender-to-receiver information from the provided MT72 record.
#
# + sndRcvInfo - An optional `swiftmt:MT72` that contains the sender-to-receiver information.
# + return - Returns a tuple with extracted information based on the content of `sndRcvInfo`. 
# - If no conditions match, it returns a tuple of `null` values.
isolated function getMT1XXSenderToReceiverInformation(swiftmt:MT72? sndRcvInfo) returns [string?, string?, string?, string?, string?, string?] {
    if sndRcvInfo is swiftmt:MT72 {
        match (sndRcvInfo.Cd.content.substring(1, 4)) {
            "INT" => {
                return ["INT", sndRcvInfo.Cd.content.substring(5), (), (), (), ()];
            }
            "ACC" => {
                return [(), (), "ACC", sndRcvInfo.Cd.content.substring(5), (), ()];
            }
            "INS" => {
                if sndRcvInfo.Cd.content.substring(5, 11).matches(re `^[A-Z]+$`) && sndRcvInfo.Cd.content.substring(11).matches(re `^[A-Z2-9]+$`) && sndRcvInfo.Cd.content.substring(12).matches(re `^[A-NP-Z0-9]+$`) {
                    if sndRcvInfo.Cd.content.substring(5).length() == 11 && sndRcvInfo.Cd.content.substring(13).matches(re `^[A-Z0-9]+$`) {
                        return [(), (), (), (), sndRcvInfo.Cd.content.substring(5), ()];
                    }
                    if sndRcvInfo.Cd.content.substring(5).length() == 8 {
                        return [(), (), (), (), sndRcvInfo.Cd.content.substring(5), ()];
                    }
                    return [(), (), (), (), (), sndRcvInfo.Cd.content.substring(5)];
                }
            }
        }
        return [(), (), (), (), (), ()];
    }
    return [(), (), (), (), (), ()];
}

# Extracts the Sender to Receiver Information (MT72) from the given SWIFT MT2XX message.
#
# + sndRcvInfo - The SWIFT MT2XX `swiftmt:MT72` structure containing sender-to-receiver information.
# + return - A string tuple with specific values extracted based on the message content, or nulls 
# if no match.
isolated function getMT2XXSenderToReceiverInformation(swiftmt:MT72? sndRcvInfo) returns [string?, string?, string?, string?, string?, string?] {
    if sndRcvInfo is swiftmt:MT72 {
        match (sndRcvInfo.Cd.content.substring(1, 4)) {
            "INT" => {
                return ["INT", sndRcvInfo.Cd.content.substring(5), (), (), (), ()];
            }
            "ACC" => {
                return [(), (), "ACC", sndRcvInfo.Cd.content.substring(5), (), ()];
            }
        }
        match (sndRcvInfo.Cd.content.substring(1, 5)) {
            "PHON"|"TELE" => {
                return [sndRcvInfo.Cd.content.substring(1, 5), sndRcvInfo.Cd.content.substring(6), (), (), (), ()];
            }
        }
        match (sndRcvInfo.Cd.content.substring(1, 5)) {
            "PHONIBK"|"TELEIBK" => {
                return [(), (), sndRcvInfo.Cd.content.substring(1, 8), sndRcvInfo.Cd.content.substring(6), (), ()];
            }
        }
        return [(), (), (), (), (), ()];
    }
    return [(), (), (), (), (), ()];
}

# Determines the settlement method based on the input MT53A, MT53B, or MT53D record.
#
# + mt53A - An optional `swiftmt:MT53A` record. If provided, and MT53A or MT53D is valid, returns "COVE".
# + mt53B - An optional `swiftmt:MT53B` record. If provided, returns "INGA" for a party identification type "C" and 
# "INDA" for type "D".
# + mt53D - An optional `swiftmt:MT53D` record. If provided, and MT53A or MT53D is valid, returns "COVE".
# + return - Returns "INGA", "INDA", or "COVE" based on the provided inputs. If no conditions match, returns "INDA" 
# by default.
isolated function getSettlementMethod(swiftmt:MT53A? mt53A = (), swiftmt:MT53B? mt53B = (), swiftmt:MT53D? mt53D = ()) returns isorecord:SettlementMethod1Code {
    if mt53B is swiftmt:MT53B {
        match (mt53B.PrtyIdnTyp?.content) {
            "C" => {
                return isorecord:INGA;
            }
            "D" => {
                return isorecord:INDA;
            }
        }
    }
    if mt53A is swiftmt:MT53A || mt53D is swiftmt:MT53D {
        return isorecord:COVE;
    }
    return isorecord:INDA;
}

# Returns the instruction code and additional information based on the input Swift MT record and a specified category 
# number.
#
# + instnCd - An optional array of `swiftmt:MT23E` objects containing instruction codes and additional information.
# + num - An integer specifying the category of instruction code to retrieve:
# + return - Returns a tuple of up to 8 elements where the relevant instruction code and additional info are populated 
# based on the category number.
# If no match is found or `instnCd` is null, returns a tuple with all elements set to `null`.
isolated function getMT103InstructionCode(swiftmt:MT23E[]? instnCd, int num) returns [string?, string?] {
    if instnCd is swiftmt:MT23E[] {
        foreach swiftmt:MT23E instruction in instnCd {
            match (instruction.InstrnCd.content) {
                "REPA"|"PHON"|"TELE"|"PHOI"|"TELI" => {
                    if num == 1 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
                "CHQB"|"HOLD"|"PHOB"|"TELB" => {
                    if num == 2 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
                "SDVA" => {
                    if num == 3 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
                "INTC"|"CORT" => {
                    if num == 4 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
            }
        }
    }
    return [(), ()];
}

# Extracts and returns specific instruction codes and additional information from the provided `MT23E` array
# based on the given `num` parameter. The function checks the instruction codes and returns a tuple with values
# based on predefined patterns and the value of `num`. If no matching instruction code is found, it returns a default tuple.
#
# + instnCd - An optional array of `MT23E` objects that contain instruction codes and additional information.
# + num - An integer indicating which set of values to return based on the instruction code.
# + return - Returns a tuple of strings and/or null values corresponding to the instruction code and additional information.
# The structure of the tuple depends on the `num` parameter and the matched instruction code.
isolated function getMT101InstructionCode(swiftmt:MT23E[]? instnCd, int num) returns [string?, string?] {
    if instnCd is swiftmt:MT23E[] {
        foreach swiftmt:MT23E instruction in instnCd {
            match (instruction.InstrnCd.content) {
                "CMTO"|"CMSW"|"CMZB"|"REPA" => {
                    if num == 1 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
                "CHQB"|"PHON"|"EQUI" => {
                    if num == 2 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
                "URGP" => {
                    if num == 3 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
                "CORT"|"INTC" => {
                    if num == 4 {
                        return [instruction.InstrnCd.content, instruction.AddInfo?.content ?: ()];
                    }
                }
            }
        }
    }
    return [(), ()];
}

# Retrieves a specific MT101 repeating field from a given transaction set or message based on the `typeName` provided.
#
# + message - The `swiftmt:MT101Message` object representing the main message block.
# + content - An optional field of one of the types `MT50C`, `MT50F`, `MT50G`, `MT50H`, `MT50L`, `MT52A`, or `MT52C` 
# used as the return value if a match is found in the transaction set.
# + typeName - A string that specifies the type of field to retrieve (e.g., "50F", "50G").
# + return - Returns the `content` if a match is found in the transaction set; otherwise, returns the appropriate MT 
# field from the `message` object based on `typeName`.
isolated function getMT101RepeatingFields(swiftmt:MT101Message message, swiftmt:MT50C?|swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C? content, string typeName) returns swiftmt:MT50C?|swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C? {
    foreach swiftmt:MT101Transaction transaxion in message.block4.Transaction {
        foreach var item in transaxion {
            if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                return content;
            }
        }
    }
    match (typeName) {
        "50F" => {
            return message.block4.MT50F;
        }
        "50G" => {
            return message.block4.MT50G;
        }
        "50H" => {
            return message.block4.MT50H;
        }
        "52A" => {
            return message.block4.MT52A;
        }
        "52C" => {
            return message.block4.MT52C;
        }
    }
    return ();
}

# Converts a given date in SWIFT MT format to an ISO 20022 standard date format (YYYY-MM-DD).
#
# + date - A `swiftmt:Dt` object containing the date in the format YYMMDD.
# + return - Returns the date in ISO 20022 format (YYYY-MM-DD). 
isolated function convertToISOStandardDate(swiftmt:Dt date) returns string {
    return YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" + date.content.substring(4, 6);
}

# Converts a given date in SWIFT MT format to an ISO 20022 standard date format (YYYY-MM-DD).
#
# + date - A `swiftmt:Dt` object containing the date in the format YYMMDD.
# + return - Returns the date in ISO 20022 format (YYYY-MM-DD).
isolated function convertToISOStandardDateMandatory(swiftmt:Dt date) returns string {
    return YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" + date.content.substring(4, 6);
}

# Converts a SWIFT MT date and time to an ISO 20022 standard date-time format.
#
# + date - The date component of the SWIFT MT message in the format YYMMDD.
# + time - The time component of the SWIFT MT message in the format HHMM.
# + isCreationDateTime - The indicator to identify whether it is creation date and time.
# + return - A string containing the date-time in ISO 20022 format, or null if the input is not valid.
isolated function convertToISOStandardDateTime(swiftmt:Dt? date, swiftmt:Tm? time, boolean isCreationDateTime = false) returns string? {
    if date is swiftmt:Dt && time is swiftmt:Tm {
        return YEAR_PREFIX + date.content.substring(0, 2) + "-" + date.content.substring(2, 4) + "-" + date.content.substring(4, 6) + "T" + time.content.substring(0, 2) + ":" + time.content.substring(2, 4) + ":00";
    }
    if isCreationDateTime {
        return time:utcToString(time:utcNow());
    }
    return ();
}

# Retrieves a specific MT101 repeating field from a given transaction set or message based on the `typeName` provided.
#
# + message - The `swiftmt:MT101Message` object representing the main message block.
# + content - An optional field of one of the types `MT26T`, `MT36`, `MT50A`, `MT50F`, `MT50K`, `MT52A`, `MT52B`, 
# `MT52C`, `MT71A`, or `MT77B` used as the return value if a match is found in the transaction set.
# + typeName - A string that specifies the type of field to retrieve (e.g., "50F", "50G").
# + return - Returns the `content` if a match is found in the transaction set; otherwise, returns the appropriate MT 
# field from the `message` object based on `typeName`.
isolated function getMT102STPRepeatingFields(swiftmt:MT102STPMessage message, swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? content, string typeName) returns swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? {
    foreach swiftmt:MT102STPTransaction transaxion in message.block4.Transaction {
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
            return message.block4.MT26T;
        }
        "36" => {
            return message.block4.MT36;
        }
        "50F" => {
            return message.block4.MT50F;
        }
        "50A" => {
            return message.block4.MT50A;
        }
        "50K" => {
            return message.block4.MT50K;
        }
        "52A" => {
            return message.block4.MT52A;
        }
        "71A" => {
            return message.block4.MT71A;
        }
        "77B" => {
            return message.block4.MT77B;
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
# + message - The `swiftmt:MT102Message` object containing message blocks and fields.
# + content - The content related to the field type, which can be any of `swiftmt:MT26T`, `swiftmt:MT36`,
# `swiftmt:MT50F`, etc.
# + typeName - A string that specifies the field type name (e.g., "26T", "50A").
# + return - Returns the content of the matching type if found in the transaction set or message block. Returns `null`
# if no match is found.
isolated function getMT102RepeatingFields(swiftmt:MT102Message message, swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? content, string typeName) returns swiftmt:MT26T?|swiftmt:MT36?|swiftmt:MT50F?|swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT71A?|swiftmt:MT77B? {
    foreach swiftmt:MT102Transaction transaxion in message.block4.Transaction {
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
            return message.block4.MT26T;
        }
        "36" => {
            return message.block4.MT36;
        }
        "50F" => {
            return message.block4.MT50F;
        }
        "50A" => {
            return message.block4.MT50A;
        }
        "50K" => {
            return message.block4.MT50K;
        }
        "52A" => {
            return message.block4.MT52A;
        }
        "52B" => {
            return message.block4.MT52B;
        }
        "52C" => {
            return message.block4.MT52C;
        }
        "71A" => {
            return message.block4.MT71A;
        }
        "77B" => {
            return message.block4.MT77B;
        }
    }
    return ();
}

# Retrieves the specific field from a list of MT104 transactions based on the provided type name.
# If a matching type is found within the transaction set, the function returns the corresponding content.
#
# + message - The `swiftmt:MT104Message` object containing message blocks and fields.
# + content - The content related to the field type, which can be any of `swiftmt:MT26T`, `swiftmt:MT50C`, 
# `swiftmt:MT50K`, etc.
# + typeName - A string that specifies the field type name (e.g., "26T", "50A").
# + return - Returns the content of the matching type if found in the transaction set or message block. Returns `null` 
# if no match is found.
isolated function getMT104RepeatingFields(swiftmt:MT104Message message, swiftmt:MT26T?|swiftmt:MT50A?|swiftmt:MT50C?|swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|swiftmt:MT77B? content, string typeName) returns swiftmt:MT26T?|swiftmt:MT50A?|swiftmt:MT50C?|swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|swiftmt:MT77B? {
    foreach swiftmt:MT104Transaction transaxion in message.block4.Transaction {
        foreach var item in transaxion {
            if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                return content;
            }
        }
    }
    match (typeName) {
        "26T" => {
            return message.block4.MT26T;
        }
        "50A" => {
            return message.block4.MT50A;
        }
        "50C" => {
            return message.block4.MT50C;
        }
        "50K" => {
            return message.block4.MT50K;
        }
        "50L" => {
            return message.block4.MT50L;
        }
        "52A" => {
            return message.block4.MT52A;
        }
        "52C" => {
            return message.block4.MT52C;
        }
        "52D" => {
            return message.block4.MT52D;
        }
        "71A" => {
            return message.block4.MT71A;
        }
        "77B" => {
            return message.block4.MT77B;
        }
    }
    return ();
}

# Retrieves the specific field from a list of MT107 transactions based on the provided type name.
# If a matching type is found within the transaction set, the function returns the corresponding content.
#
# + message - The `swiftmt:MT107Message` object containing message blocks and fields.
# + content - The content related to the field type, which can be any of `swiftmt:MT26T`, `swiftmt:MT50C`, 
# `swiftmt:MT50K`, etc.
# + typeName - A string that specifies the field type name (e.g., "26T", "50A").
# + return - Returns the content of the matching type if found in the transaction set or message block. Returns `null` 
# if no match is found.
isolated function getMT107RepeatingFields(swiftmt:MT107Message message, swiftmt:MT26T?|swiftmt:MT50A?|swiftmt:MT50C?|swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|swiftmt:MT77B? content, string typeName) returns swiftmt:MT26T?|swiftmt:MT50A?|swiftmt:MT50C?|swiftmt:MT50K?|swiftmt:MT50L?|swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D?|swiftmt:MT71A?|swiftmt:MT77B? {
    foreach swiftmt:MT107Transaction transaxion in message.block4.Transaction {
        foreach var item in transaxion {
            if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                return content;
            }
        }
    }
    match (typeName) {
        "26T" => {
            return message.block4.MT26T;
        }
        "50A" => {
            return message.block4.MT50A;
        }
        "50C" => {
            return message.block4.MT50C;
        }
        "50K" => {
            return message.block4.MT50K;
        }
        "50L" => {
            return message.block4.MT50L;
        }
        "52A" => {
            return message.block4.MT52A;
        }
        "52C" => {
            return message.block4.MT52C;
        }
        "52D" => {
            return message.block4.MT52D;
        }
        "71A" => {
            return message.block4.MT71A;
        }
        "77B" => {
            return message.block4.MT77B;
        }
    }
    return ();
}

# Retrieves the specified repeating fields (MT72) from the transactions in an MT201 SWIFT message.
#
# + message - The MT201 message containing the transaction data.
# + content - An optional MT72 content object, which can be returned if the matching field is found.
# + typeName - A string representing the specific type code to match against in the transaction data.
# + return - Returns the provided `content` if a matching field is found, or the MT72 block from the message if not.
isolated function getMT201RepeatingFields(swiftmt:MT201Message message, swiftmt:MT72? content, string typeName) returns swiftmt:MT72? {
    foreach swiftmt:MT201Transaction transaxion in message.block4.Transaction {
        foreach var item in transaxion {
            if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                return content;
            }
        }
    }
    return message.block4.MT72;
}

# Retrieves the specified repeating fields (MT72) from the transactions in an MT203 SWIFT message.
#
# + message - The MT201 message containing the transaction data.
# + content - An optional MT72 content object, which can be returned if the matching field is found.
# + typeName - A string representing the specific type code to match against in the transaction data.
# + return - Returns the provided `content` if a matching field is found, or the MT72 block from the message if not.
isolated function getMT203RepeatingFields(swiftmt:MT203Message message, swiftmt:MT72? content, string typeName) returns swiftmt:MT72? {
    foreach swiftmt:MT203Transaction transaxion in message.block4.Transaction {
        foreach var item in transaxion {
            if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
                return content;
            }
        }
    }
    return message.block4.MT72;
}

# Extracts and converts floor limit data from the MT34F SWIFT message into ISO 20022 Limit2 format.
#
# + floorLimit - An optional array of MT34F objects, each representing a floor limit.
# + return - Returns an array of Limit2 objects for ISO 20022, or an error if conversion fails.
isolated function getFloorLimit(swiftmt:MT34F[]? floorLimit) returns isorecord:Limit2[]?|error {
    if floorLimit is swiftmt:MT34F[] {
        if floorLimit.length() > 1 {
            return [
                {
                    Amt: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                            ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(floorLimit[0].Amnt),
                            Ccy: floorLimit[0].Ccy.content
                        }
                    },
                    CdtDbtInd: getCdtDbtFloorLimitIndicator(floorLimit[0].Cd)
                },
                {
                    Amt: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                            ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(floorLimit[1].Amnt),
                            Ccy: floorLimit[1].Ccy.content
                        }
                    },
                    CdtDbtInd: getCdtDbtFloorLimitIndicator(floorLimit[1].Cd)
                }
            ];
        }
        return [
            {
                Amt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(floorLimit[0].Amnt),
                        Ccy: floorLimit[0].Ccy.content
                    }
                },
                CdtDbtInd: isorecord:BOTH
            }
        ];
    }
    return ();
}

# Determines the credit or debit indicator from the SWIFT MT field and maps it to the ISO 20022 `FloorLimitType1Code`.
#
# + code - The optional SWIFT MT Cd element containing the credit or debit indicator.
# + return - Returns the ISO 20022 `FloorLimitType1Code`, which can be either DEBT (debit) or CRED (credit).
isolated function getCdtDbtFloorLimitIndicator(swiftmt:Cd? code) returns isorecord:FloorLimitType1Code {
    if code is swiftmt:Cd {
        if code.content.equalsIgnoreCaseAscii("D") {
            return isorecord:DEBT;
        }
        return isorecord:CRED;
    }
    return isorecord:DEBT;
}

# Retrieves and converts the list of MT61 statement entries into ISO 20022 `ReportEntry14` objects.
#
# This function takes an array of SWIFT MT61 statement lines, extracts relevant data such as 
# reference, value date, amount, and transaction details, and maps them to the corresponding 
# ISO 20022 `ReportEntry14` structure.
#
# + statement - The optional array of SWIFT MT61 statement lines, containing details of account transactions.
# + return - Returns an array of `ReportEntry14` objects with mapped values, or an error if conversion fails.
isolated function getEntries(swiftmt:MT61[]? statement) returns isorecord:ReportEntry14[]|error {
    isorecord:ReportEntry14[] names = [];
    if statement is swiftmt:MT61[] {
        foreach swiftmt:MT61 stmtLine in statement {
            names.push({
                NtryRef: stmtLine.RefAccOwn.content,
                ValDt: {
                    Dt: convertToISOStandardDate(stmtLine.ValDt)
                },
                CdtDbtInd: convertDbtOrCrdToISOStandard(stmtLine),
                Amt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(stmtLine.Amnt),
                        Ccy: getMandatoryFields(stmtLine.FndCd?.content)
                    }
                },
                BkTxCd: {
                    Prtry: {
                        Cd: stmtLine.TranTyp.content
                    }
                },
                Sts: {
                    Cd: "BOOK"
                },
                AddtlNtryInf: stmtLine.SpmtDtls?.content
            });
        }
    }
    return names;
}

# Converts the credit/debit indicator from the SWIFT MT message into the ISO 20022 `CreditDebitCode`.
#
# + content - The SWIFT MT message content (MT60F, MT62F, MT65, MT64, MT60M, MT62M, or MT61) which contains 
# the credit or debit indicator.
# + return - Returns the ISO 20022 `CreditDebitCode`, either `CRDT` or `DBIT`.
isolated function convertDbtOrCrdToISOStandard(swiftmt:MT60F|swiftmt:MT62F|swiftmt:MT65|swiftmt:MT64|swiftmt:MT60M|swiftmt:MT62M|swiftmt:MT61 content) returns isorecord:CreditDebitCode {
    if content.Cd.content.equalsIgnoreCaseAscii("C") || content.Cd.content.equalsIgnoreCaseAscii("RD") {
        return isorecord:CRDT;
    }
    return isorecord:DBIT;

}

# Retrieves and converts the balance information from multiple SWIFT MT message types (MT60F, MT62F, MT64, MT60M, MT62M, and MT65) 
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
# + return - Returns an array of `CashBalance8` objects representing the balances in ISO 20022 format or an error if any conversion fails.
isolated function getBalance(swiftmt:MT60F? firstOpenBalance, swiftmt:MT62F? firstCloseBalance, swiftmt:MT64[]? closeAvailableBalance, swiftmt:MT60M[]? inmdOpenBalance = (), swiftmt:MT62M[]? inmdCloseBalance = (), swiftmt:MT65[]? forwardAvailableBalance = ()) returns isorecord:CashBalance8[]|error {
    isorecord:CashBalance8[] BalArray = [];
    if firstOpenBalance is swiftmt:MT60F {
        BalArray.push({
            Amt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(firstOpenBalance.Amnt),
                    Ccy: firstOpenBalance.Ccy.content
                }
            },
            Dt: {Dt: convertToISOStandardDate(firstOpenBalance.Dt)},
            CdtDbtInd: convertDbtOrCrdToISOStandard(firstOpenBalance),
            Tp: {
                CdOrPrtry: {
                    Cd: "PRCD"
                }
            }
        });
    }
    if inmdOpenBalance is swiftmt:MT60M[] {
        foreach swiftmt:MT60M inmdOpnBal in inmdOpenBalance {
            BalArray.push({
                Amt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(inmdOpnBal.Amnt),
                        Ccy: inmdOpnBal.Ccy.content
                    }
                },
                Dt: {Dt: convertToISOStandardDate(inmdOpnBal.Dt)},
                CdtDbtInd: convertDbtOrCrdToISOStandard(inmdOpnBal),
                Tp: {
                    CdOrPrtry: {
                        Cd: "ITBD"
                    }
                }
            });
        }
    }
    if firstCloseBalance is swiftmt:MT62F {
        BalArray.push({
            Amt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(firstCloseBalance.Amnt),
                    Ccy: firstCloseBalance.Ccy.content
                }
            },
            Dt: {Dt: convertToISOStandardDate(firstCloseBalance.Dt)},
            CdtDbtInd: convertDbtOrCrdToISOStandard(firstCloseBalance),
            Tp: {
                CdOrPrtry: {
                    Cd: "CLBD"
                }
            }
        });
    }
    if inmdCloseBalance is swiftmt:MT62M[] {
        foreach swiftmt:MT62M inmdClsBal in inmdCloseBalance {
            BalArray.push({
                Amt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(inmdClsBal.Amnt),
                        Ccy: inmdClsBal.Ccy.content
                    }
                },
                Dt: {Dt: convertToISOStandardDate(inmdClsBal.Dt)},
                CdtDbtInd: convertDbtOrCrdToISOStandard(inmdClsBal),
                Tp: {
                    CdOrPrtry: {
                        Cd: "ITBD"
                    }
                }
            });
        }
    }
    if closeAvailableBalance is swiftmt:MT64[] {
        foreach swiftmt:MT64 clsAvblBal in closeAvailableBalance {
            BalArray.push({
                Amt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(clsAvblBal.Amnt),
                        Ccy: clsAvblBal.Ccy.content
                    }
                },
                Dt: {Dt: convertToISOStandardDate(clsAvblBal.Dt)},
                CdtDbtInd: convertDbtOrCrdToISOStandard(clsAvblBal),
                Tp: {
                    CdOrPrtry: {
                        Cd: "CLAV"
                    }
                }
            });
        }
    }
    if forwardAvailableBalance is swiftmt:MT65[] {
        foreach swiftmt:MT65 fwdAvblBal in forwardAvailableBalance {
            BalArray.push({
                Amt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(fwdAvblBal.Amnt),
                        Ccy: fwdAvblBal.Ccy.content
                    }
                },
                Dt: {Dt: convertToISOStandardDate(fwdAvblBal.Dt)},
                CdtDbtInd: convertDbtOrCrdToISOStandard(fwdAvblBal),
                Tp: {
                    CdOrPrtry: {
                        Cd: "FWAV"
                    }
                }
            });
        }
    }
    return BalArray;
}

# Retrieves and concatenates additional information (MT86) from the `infoToAccOwnr` array into a single string.
#
# The function processes multiple MT86 blocks of additional information, combining them into a comma-separated string 
# and returning the final concatenated result. If there is no information, it returns null.
#
# + infoToAccOwnr - An optional array of MT86 additional information blocks.
# + return - Returns the concatenated additional information as a string or null if the input is not provided or empty.
isolated function getInfoToAccOwnr(swiftmt:MT86[]? infoToAccOwnr) returns string? {
    string finalInfo = "";
    if infoToAccOwnr is swiftmt:MT86[] {
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
    return ();
}

# Calculates the total number of credit and debit entries.
#
# The function takes in two optional `TtlNum` values representing the number of credit and debit entries 
# and returns the sum as a string or throws an error if the values are invalid.
#
# + creditEntryNum - Optional value representing the total number of credit entries.
# + debitEntryNum - Optional value representing the total number of debit entries.
# + return - Returns the total number of entries as a string, or an error if the values are not valid integers.
isolated function getTotalNumOfEntries(swiftmt:TtlNum? creditEntryNum, swiftmt:TtlNum? debitEntryNum) returns string|error {
    int total = 0;
    do {
        if creditEntryNum is swiftmt:TtlNum {
            total += check int:fromString(creditEntryNum.content);
        }
        if debitEntryNum is swiftmt:TtlNum {
            total += check int:fromString(debitEntryNum.content);
        }
    } on fail {
        return error("Provide integer for total number of credit and debit entries.");
    }
    return total.toString();
}

# Calculates the total sum of credit and debit entry amounts.
#
# The function takes two optional `Amnt` values (credit and debit amounts), converts them to decimals, 
# and returns the sum. If any conversion fails, an error is thrown.
#
# + creditEntryAmnt - Optional value representing the total credit entry amount.
# + debitEntryAmnt - Optional value representing the total debit entry amount.
# + return - Returns the total sum of entries as a decimal, or an error if the values are not valid decimals.
isolated function getTotalSumOfEntries(swiftmt:Amnt? creditEntryAmnt, swiftmt:Amnt? debitEntryAmnt) returns decimal|error {
    decimal total = 0;
    do {
        if creditEntryAmnt is swiftmt:Amnt {
            total += check decimal:fromString(creditEntryAmnt.content);
        }
        if debitEntryAmnt is swiftmt:Amnt {
            total += check decimal:fromString(debitEntryAmnt.content);
        }
    } on fail {
        return error("Provide decimal value for sum of credit and debit entries.");
    }
    return total;
}

# Retrieves the underlying customer transaction fields from a given MT202COV or MT205COV message
# based on the specified type name.
#
# This function checks if the provided `typeName` matches any underlying customer credit transfers.
# If a match is found, it returns null. Otherwise, it retrieves and returns the appropriate field 
# based on the specified `typeName`.
#
# + message - An MT202COV or MT205COV message containing underlying customer credit transactions.
# + typeName - The type of the transaction field to retrieve.
# + return - Returns the corresponding MT52A, MT52D, MT56A, MT56D, MT57A, MT57B, MT57D, MT72 fields, 
# or null if the transaction type does not match any criteria.
isolated function getUnderlyingCustomerTransactionFields(swiftmt:MT202COVMessage|swiftmt:MT205COVMessage message, string typeName) returns swiftmt:MT52A?|swiftmt:MT52D?|swiftmt:MT56A?|swiftmt:MT56D?|swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57D?|swiftmt:MT72? {
    foreach var item in message.block4.UndrlygCstmrCdtTrf {
        if item.toString().substring(9, 12).equalsIgnoreCaseAscii(typeName) {
            return ();
        } else if item.toString().substring(9, 11).equalsIgnoreCaseAscii(typeName) {
            return ();
        }
    }
    match (typeName) {
        "52A" => {
            return message.block4.MT52A;
        }
        "52D" => {
            return message.block4.MT52D;
        }
        "56A" => {
            return message.block4.MT56A;
        }
        "56D" => {
            return message.block4.MT56D;
        }
        "57A" => {
            return message.block4.MT57A;
        }
        "57B" => {
            return message.block4.MT57B;
        }
        "57D" => {
            return message.block4.MT57D;
        }
        "72" => {
            return message.block4.MT72;
        }
    }
    return ();
}

# Retrieves the intermediary agent identification information from the provided MT56A, MT56D, MT57A, MT57B, and MT57D 
# messages.
#
# This function checks for the presence of intermediary fields and constructs a BranchAndFinancialInstitutionIdentification8
# record containing relevant details such as BIC, LEI, name, and address.
#
# + inmd56A - Optional intermediary message of type MT56A.
# + inmd56D - Optional intermediary message of type MT56D.
# + inmd57A - Optional intermediary message of type MT57A.
# + inmd57B - Optional intermediary message of type MT57B.
# + inmd57D - Optional intermediary message of type MT57D.
# + return - Returns a BranchAndFinancialInstitutionIdentification8 record or null if no matching messages are found.
isolated function getIntermediaryAgent1(swiftmt:MT56A? inmd56A, swiftmt:MT56D? inmd56D, swiftmt:MT57A? inmd57A, swiftmt:MT57B? inmd57B, swiftmt:MT57D? inmd57D) returns isorecord:BranchAndFinancialInstitutionIdentification8? {
    if inmd56A is swiftmt:MT56A || inmd56D is swiftmt:MT56D {
        return {
            FinInstnId: {
                BICFI: inmd56A?.IdnCd?.content,
                LEI: getPartyIdentifier(inmd56A?.PrtyIdn, inmd56D?.PrtyIdn),
                Nm: getName(inmd56D?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(inmd56D?.AdrsLine)
                }
            }
        };
    }
    if inmd57A is swiftmt:MT57A || inmd57B is swiftmt:MT57B || inmd57D is swiftmt:MT57D {
        return {
            FinInstnId: {
                BICFI: inmd57A?.IdnCd?.content,
                LEI: getPartyIdentifier(inmd57A?.PrtyIdn, inmd57B?.PrtyIdn, inmd57D?.PrtyIdn),
                Nm: getName(inmd57D?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(inmd57D?.AdrsLine)
                }
            }
        };
    }
    return ();
}

# Retrieves the intermediary agent identification information from the provided MT56A, MT56D, MT57A, MT57B, and 
# MT57D messages.
#
# This function checks for the presence of intermediary fields in MT56 and MT57 messages and constructs a 
# BranchAndFinancialInstitutionIdentification8 record containing relevant details such as BIC, LEI, name, and address.
#
# + inmd56A - Optional intermediary message of type MT56A.
# + inmd56D - Optional intermediary message of type MT56D.
# + inmd57A - Optional intermediary message of type MT57A.
# + inmd57B - Optional intermediary message of type MT57B.
# + inmd57D - Optional intermediary message of type MT57D.
# + return - Returns a BranchAndFinancialInstitutionIdentification8 record or null if no matching messages are found.
isolated function getIntermediaryAgent2(swiftmt:MT56A? inmd56A, swiftmt:MT56D? inmd56D, swiftmt:MT57A? inmd57A, swiftmt:MT57B? inmd57B, swiftmt:MT57D? inmd57D) returns isorecord:BranchAndFinancialInstitutionIdentification8? {
    if inmd56A is swiftmt:MT56A || inmd56D is swiftmt:MT56D && (inmd57A is swiftmt:MT57A || inmd57B is swiftmt:MT57B || inmd57D is swiftmt:MT57D) {
        return {
            FinInstnId: {
                BICFI: inmd57A?.IdnCd?.content,
                LEI: getPartyIdentifier(inmd57A?.PrtyIdn, inmd57B?.PrtyIdn, inmd57D?.PrtyIdn),
                Nm: getName(inmd57D?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(inmd57D?.AdrsLine)
                }
            }
        };
    }
    return ();
}

# Retrieves sender to receiver information from an MT72 message.
#
# This function analyzes the `Cd` field of an MT72 message and returns relevant information based on its content.
#
# + sndRcvInfo - An optional MT72 message containing sender to receiver information.
# + return - Returns a tuple of strings or nulls based on the analyzed content of the `Cd` field.
isolated function getMT204SenderToReceiverInformation(swiftmt:MT72? sndRcvInfo) returns [string?, string?] {
    if sndRcvInfo is swiftmt:MT72 {
        if sndRcvInfo.Cd.content.substring(1, 4).equalsIgnoreCaseAscii("ACC") {
            return ["ACC", sndRcvInfo.Cd.content.substring(5)];
        }
        if sndRcvInfo.Cd.content.substring(1, 4).equalsIgnoreCaseAscii("BNF") {
            return [(), ()];
        }
        return [sndRcvInfo.Cd.content];
    }
    return [(), ()];
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
isolated function getEndToEndId(string? cstmRefNum = (), string? remmitanceInfo = (), string? transactionId = ()) returns string {
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

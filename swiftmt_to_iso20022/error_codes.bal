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

final readonly & map<string> swiftErrorMessages = {

    "T0000M": "Input content is not mapped to target message.",
    "T0000N": "Field content is not copied as it is incompatible.",
    "T0000R": "Illegal characters have been replaced.",
    "T0000L": "Illegal characters at the beginning of the line have been replaced.",
    "T0000S": "Leading or trailing spaces are trimmed.",
    "T0000T": "Field content has been truncated.",
    "T0000E": "Empty line is removed as it would create a validation error. " +
        "Empty lines are caused by leading or trailing spaces in the input data.",

    "T11001": "IF option B is present, PartyIdentifier is expected.",
    "T11002": "MT Clearing system code has no ISO equivalent clearing system code. MT Clearing system code is translated to Agent Name and Address Line 1.",
    "T11003": "Missing MT Clearing system code. Dummy values provided in Agent Name and Address Line 1.",
    "T11004": "The agent information in field 72 is not compatible with the translation template. Dummy value provided for Address.",
    "T11005": "As per SWIFT User Handbook, Message Reference Guides for Category 1 and Category 2, a Fedwire Routing Number in combination with a BIC (option A) must be used without the 9-digit code. As the Clearing channel has no impact on the agent or has a value different from \"RTGS\", translation to \"//FW\" might be misleading. So, the ClearingSystemMemberID is not translated.",
    "T11006": "As per SWIFT User Handbook, Message Reference Guides for Category 1 and Category 2, for some clearing systems the use of a clearing identification in combination with a BIC (MT option A) is not allowed: CHIPS Participant Identifier (\"CP\"), Russian Central Bank Identification Code (\"RU\"), Swiss Clearing Code (\"SW\"). For that reason, if the ClearingSystemMemberIdentifier is present, it is not translated to MT.",
    "T11007": "If the Clearing Channel is \"RTGS\" and BIC is present, then ClearingSystemMemberId, if present, is not translated. Only the Clearing Channel resulting in \"//RT\".",
    "T11008": "Debit indicator \"/D\" or Credit indicator \"/C\" is not translated.",
    "T11009": "The agent information in field 72 is not compatible with the translation template. Translation is skipped.",
    "T11010": "An agent earlier in the sequence has not been translated or is missing from the input. This is an illegal situation. Translation is skipped.",
    "T11011": "Country is mandatory, but it cannot be derived from either BIC or Party Identifier. Country is not set.",
    "T11012": "Country and town are mandatory, but it cannot be derived when option D is used as input. AddressLines are used instead.",
    "T11013": "Data \"//CH\" is not translated. An account number is expected to follow \"//CH\". Wrong usage.",
    "T11014": "PartyIdentifier starting with \"//\" is expected to be a ClearingSystemMemberID. But the ClearingSystemID has not ISO equivalent. Therefore, the PartyIdentifier is not translated from a MT format option A or D.",
    "T11015": "Option B or C Party Identifier formatted as an account, mapped to Agent/Name.",
    "T11016": "PartyIdentifier in format option A starting with \"//RT\" or \"//FW\" should not be followed by a ClearingSystemMemberID. Therefore, the PartyIdentifier is not translated from a MT format option A.",
    "T12001": "Not possible to create a valid FATF ID because the country of the issuer is missing. Dummy value is provided in subfield 1. Country from the address is used instead of country of issuer.",
    "T12002": "Not possible to create a valid FATF ID because the country of the issuer is missing. Dummy value is provided in subfield 1. Country of residence is used instead of country of issuer.",
    "T12003": "Not possible to create a valid FATF ID because PrivateIdentification/Other/SchemeName/Code is not in the ISO list.",
    "T12004": "Not possible to create a valid FATF ID. Dummy value provided in subfield 1.",
    "T12005": "Not possible to create a valid FATF ID for option F subfield 2 line 6/ or 7/. Information not translated from PrivateIdentification/Other.",
    "T12006": "Invalid pattern. A valid country code is expected. Information is missing from MT (Country and possibly TownName).",
    "T12007": "ClearingSystemMemberIdentification is translated to 50K/NameAndAddress or 50NoLetter.",
    "T12008": "ClearingSystemMemberIdentification is translated to 59/NameAndAddress.",
    "T12009": "Party's name is missing. Dummy value \"NOTPROVIDED\" is used.",
    "T12010": "Not possible to create a valid FATF ID because OrganisationIdentification/Other/SchemeName/Code is not a valid code.",
    "T13001": "The amount is not MT-compliant. It should consist out of 15 digits, including the comma.",
    "T13002": "The amount is not MX-compliant. It should consist out of maximum 18 digits, of which maximum 5 are fractional digits.",
    "T13003": "InstructedAmount is not present. InterbankSettlementAmount is copied in 33B to make a valid MT.",
    "T13004": "71G/Currency is not equal to 32A/Currency. This generates an invalid MT. 71G is not translated to the target message.",
    "T13005": "Length of total charges in ChargesInformation/Amount exceeds 14 digits. 71G is not translated to the target message.",
    "T13006": "Charges with different currencies. Sum of charges cannot be calculated.",
    "T13007": "ChargeBearer SLEV translated as SHA. SLEV appended to field 72.",
    "T13008": "Closing balance does not equal the sum of the opening balance and the entries' amounts.",
    "T13009": "71G/Amount cannot be equal to ZERO. This generates an invalid MT. Charge amount with Zero value is not translated.",
    "T14001": "Invalid data to fill MT Reference. Dummy value provided.",
    "T14002": "Invalid original payment identification (OriginalInstructionID OR OriginalMessageID) to fill MT Reference. Dummy value provided.",
    "T15001": "Information following the codeword /CHQB/ is not expected. It is not translated.",
    "T15002": "\"SDVA\" code in ServiceLevel and \"HOLD\" or \"CHQB\" code in InstructionForCreditorAgent generates an invalid MT. Code in conflict with \"SDVA\" (\"HOLD\" or \"CHQB\") is deleted and therefore missing in translated message.",
    "T15003": "\"INTC\" code or \"CORT\" code in CategoryPurpose and \"HOLD\" or \"CHQB\" code in InstructionForCreditorAgent generates an invalid MT. Code in conflict with \"INTC\" or \"CORT\" (\"HOLD\" or \"CHQB\") is deleted and therefore missing in translated message.",
    "T15004": "\"PHOB\" code and \"TELB\" code in InstructionForCreditorAgent generates an invalid MT. Code \"TELB\" is deleted and therefore missing in translated message.",
    "T15005": "\"HOLD\" code and \"CHQB\" code in InstructionForCreditorAgent generates an invalid MT. Code \"CHQB\" is deleted and therefore missing in translated message.",

    "T20001": "If 53B is present, SettlementMethod is 'INGA' or 'INDA', only a SettlementAccount is allowed. Field 53B not translated.",
    "T20002": "If 53B is present, SettlementMethod is 'INGA' or 'INDA', 54a is not expected. Field 54a not translated.",
    "T20003": "If 53B is present, SettlementMethod is 'INGA' or 'INDA', 55a is not expected. Field 55a not translated.",
    "T20004": "If 54B is present, PartyIdentifier is expected.",
    "T20005": "If 55B is present, PartyIdentifier is expected.",
    "T20006": "If 53B is present, PartyIdentifier Account is expected. Field 53B not translated except if 53B/Location is present and 54a and 55a are present.",
    "T20008": "55a is not expected in serial payment. Field 55a not translated.",
    "T20009": "53A is not expected. Field 53A not translated.",
    "T20010": "54A is not expected. Field 54A not translated.",
    "T20011": "53A is not expected. Field 53A IdentifierCode (BIC) not translated.",
    "T20012": "SettlementMethod is 'INGA' or 'INDA', only a SettlementAccount is allowed. Field53A PartyIdentifier not translated if present.",
    "T20013": "54A PartyIdentifier is not expected. Field54A PartyIdentifier not translated.",
    "T20014": "54B is not expected. Usage uncertain. Field 54B not translated.",
    "T20015": "54D is not expected. Usage uncertain. Field 54D not translated.",
    "T20016": "53A is not expected with sender's BIC. Field53A IdentifierCode (BIC) not translated.",
    "T20017": "53A is not expected with sender's BIC. Field53A not translated.",
    "T20018": "54A is not translated, inconsistent usage of 53A and 54A. Field 54A not translated.",
    "T20019": "55a is not translated, inconsistent usage of 53A and 54A. Field 55a not translated.",
    "T20020": "SettlementMethod is 'COVE' but not allowed in CBPR+ pacs.009. Dummy Value 'INDA' used.",
    "T20021": "53A BIC is translated to InstructionForNextAgent (codeword /FIN53/).",
    "T20022": "53D is not translated.",
    "T20023": "54a is not translated.",
    "T20024": "53a is not translated.",
    "T20027": "Invalid BIC in /FIN53/. Code /FIN53/ not translated.",
    "T20029": "Invalid Item/Identification to fill MT Reference. Dummy value provided.",
    "T20031": "Information following /INTA/ not compatible with the translation template. IntermediaryAgent2 or IntermediaryAgent3 not translated.",
    "T20032": "Not possible to create a valid meaningful Field 52 from information present in MX message.",
    "T20036": "54A/BIC should indicate where the MT103 receiver will claim the money. Not needed in returned payment. 54a not translated.",
    "T20038": "Entry Status is not 'booked'. Translation is not foreseen. STOP translation.",
    "T20043": "Missing information in MX message to create field 50a. Dummy value is provided.",
    "T20044": "ReturnedInstructedAmount not present in pacs.004. ReturnedInterbankSettlementAmount is copied in 33B to make a valid MT.",
    "T20045": "Field MT 71G cannot be calculated, different currencies in ChargeInformation/Amount[*]. Charge information Amount is missing.",
    "T20048": "Debtor/Agent is expected instead of Debtor/Party. STOP translation.",
    "T20049": "Creditor/Agent is expected instead of Creditor/Party. STOP translation.",
    "T20050": "MT Account length > 34 characters. Account identification is truncated.",
    "T20051": "Invalid MessageIdentification to fill MT Reference. Dummy value provided.",
    "T20052": "Invalid InstructionID to fill MT Reference. Dummy value provided.",
    "T20053": "Translation is not executed when more than 1 transaction in the message. STOP translation.",
    "T20054": "Commodities currencies {XAU, XAG, XPD, XPT} not allowed in Field 32A and 32B. STOP translation.",
    "T20055": "Invalid EndToEndID or Item/Identification to fill MT Reference. Dummy value provided.",
    "T20056": "Transaction Status is different from 'rejected'. Translation is not foreseen. STOP translation.",
    "T20061": "Translation is not executed when more than 1 occurrence of Notification/Item present in the message. STOP translation.",
    "T20062": "Expected Value Date is not present in MX message. Dummy value is provided to get a valid MT.",
    "T20063": "Translation of MT103 REJT, MT103 RETN, MT202 (COVE) REJT, MT202 (COVE) RETN is not performed. New payment is expected to be returned.",
    "T20064": "Not possible to translate 52a. 52a information is missing.",
    "T20065": "53A PartyIdentifier is not translated and, if present, 54A PartyIdentifier is not translated.",
    "T20066": "Total number of digits is greater than 14 digits in Amount.",
    "T20067": "MT202 has been selected as default value to translate pacs.004 to MT due to uncertainties.",
    "T20068": "53A PartyIdentifier is not translated.",
    "T20069": "53D/Name and Address is not translated.",
    "T20070": "53B/Location is not translated.",
    "T20071": "53A/BIC is not translated.",
    "T20072": "Missing OriginalInstructionID. Dummy value is provided to get a valid MT.",
    "T20078": "Notification/Entry/ValueDate IsAbsent AND Notification/Entry/EntryDetails/TransactionDetails/RelatedDates/InterbankSettlementDate IsAbsent. Not possible to create 32A/ValueDate.",
    "T20083": "Original Message Name Identification value is not expected. Dummy value '202' is translated.",
    "T20087": "UETR is missing in MT while mandatory in MX. STOP translation.",
    "T20088": "Field 32A is absent while OriginalInterbankSettlementAmount and OriginalInterbankSettlementDate are mandatory. STOP translation.",
    "T20089": "Unexpected MT type.",
    "T20092": "Target message is uncertain. Translation to Category 2 as default.",
    "T20093": "Cancellation status is mandatory in MX but missing in MT.",
    "T20094": "Usage of field 77A is uncertain. This field can contain the query in narrative form or could be the continuation of field 76. No translation to avoid misinterpretation.",
    "T20096": "ChargeBearer is missing in source message. 'SHAR' is used as dummy value in the target message.",
    "T20099": "Dummy ReturnedInstructedAmount to meet UG rules.",
    "T20136": "Date of Original Message not present. Default value '991231' mapped.",
    "T20149": "DebtorAgent is not translated as both 50a and 52a are not allowed in MT210.",
    "T20150": "Both LegalSequenceNumber and ElectronicSequenceNumber are absent or have more than 5 digits. Impossible to generate 28C.",
    "T20151": "Either the opening booked balance (OPBD) is missing or more than one occurrence of OPBD on the page.",
    "T20152": "Intermediate opening booked balance (OPBD/INTM) is not expected on the first page.",
    "T20153": "Balance SubType code INTM is missing to indicate it is an intermediate opening booked balance.",
    "T20154": "Either the closing booked balance (CLBD) is missing or more than one occurrence of CLBD on the page.",
    "T20155": "Intermediate closing booked balance (CLBD/INTM) is expected if LastPageIndicator is 'false'.",
    "T20156": "More than 1 occurrence of closing available balance is present on the page.",
    "T20157": "Number of Entries is over the maximum allowed to guarantee smooth translation to MT.",
    "T20158": "The first two characters of the three-character currency code in fields 60a, 62a, 64 and 65 must be the same for all occurrences of these fields. Source message is not compliant with the network validation rule defined on the target message.",
    "T20159": "MX Balance contains more than 14 digits.",
    "T20160": "MX Entry amount has more than 14 digits.",
    "T20161": "At least the following must be present: Report/Entry is present OR Report/TransactionsSummary/TotalCreditEntries/(NumberOfEntries AND SUM) is present OR Report/TransactionsSummary/TotalDebitEntries/(NumberOfEntries AND SUM) is present. Translation camt.052 to MT941 is out of scope (that is, no balance translation).",
    "T20163": "All entry amounts must be expressed in Account Currency.",
    "T20165": "Length (Number of Entries) exceeds 5 digits. No translation to field 90.",
    "T20166": "MX Sum of Credit or Debit Entries has more than 14 digits. No translation to field 90.",
    "T20167": "Either Number of entries or Sum of entries is missing. No translation to field 90D.",
    "T20168": "Either Number of entries or Sum of entries is missing. No translation to field 90C.",
    "T20171": "Intermediate closing booked balance (CLBD/INTM) is not expected if LastPageIndicator is 'true'.",
    "T20172": "A valid MX ClearingSystem is expected in 50K (MX to MT translation side effect). Translation to Name and Address instead.",
    "T20173": "A valid MX ClearingSystem is expected in 59 NoLetter (MX to MT translation side effect). Translation to Name and Address instead.",
    "T20197": "Not expected scenario. Investigation needed. Option B or C is not allowed to translate the ClearingSystemMemberID or Account in absence of BIC and Name and Address.",
    "T20200": "Dummy value provided for Account/Currency (from 32A/Currency).",
    "T20202": "In absence of DebtorAgent, Debtor/Agent is translated to field 52a.",
    "T20224": "ClearingChannel cannot be translated twice to two agents. It has been removed from the second agent.",
    "T20225": "ClearingChannel cannot be translated twice to two agents. Investigations needed especially for translation to option B or C (if only the ClearingChannel is available without data for the ClearingSystemMemberID).",
    "T20234": "Field 72 /CHGS/ is not translated because if ChargesInformation is present then ReturnedInstructedAmount is mandatory but absent in input message.",
    "T20246": "SWIFTGo service requests value '009' in field 111 (ServiceTypeIdentifier) in block 3 of the FIN header. STOP translation.",
    "T20278": "MT n92/3!n value is not expected. Target message is not in the scope of CBPR+ translation scope.",
    "T20279": "Translation is not executed when more than 1 item to be cancelled. STOP translation.",
    "T20287": "Translation is not executed when /AppHdr/BizSvc equals 'swift.cbprplus.mlp.01'.",
    "T20288": "Translation is not executed when more than 6 Charges Breakdowns in the message. STOP translation.",
    "T20289": "The amount is not MT-compliant. It should consist out of 13 digits, including the comma.",
    "T20302": "Please refer to the MX message for the Underlying Transaction Identification used. Dummy value is provided in Field 21.",
    "T20307": "ChargesAccountAgentAccount Identification is not translated if ChargesAccountAgent is not present. DebtorAgentAccount Identification is not translated if DebtorAgent is not present. This would prevent mixing the account of one agent with the Identification of the other agent.",
    "T22006": "53A BIC is NOT translated as there is no InstructionForNextAgent (codeword /FIN53/).",
    "T2S001": "Sender test BIC cannot be derived based on ISO message content. Translation is stopped.",
    "T2S002": "Receiver test BIC cannot be derived based on ISO message content. Translation is stopped.",
    "T2S003": "Runtime context parameter 'SN.SnFInputTime' is invalid. It's not used to set the input time and MIR.",
    "T2S004": "Runtime context parameter 'SN.SnFOutputTime' is invalid. It's not used to set the output date and time.",

    "T30001": "No BIC found in tag AppHdr/Fr (Business Application Header). Please specify the BIC in the Business Application Header (BAH). Dummy values are used instead.",
    "T30002": "No BIC found in tag AppHdr/To (Business Application Header). Please specify the BIC in the Business Application Header (BAH). Dummy values are used instead."
};

public enum ErrorCategory {
    WARNING,
    FAILURE,
    TRUNC_X,
    TRUNC_R
}

public type SwiftError record {
    ErrorCategory category;
    string code;
    string message;
};

isolated function buildException(string category, string code) returns SwiftError {
    return {category: <ErrorCategory>category, code: code, message: swiftErrorMessages[code] ?: ""};
}

isolated function getSwiftLogMessage(string category, string code) returns string {
    SwiftError exception = buildException(category, code);
    return exception.category + "." + exception.code + "/" + exception.message;
}

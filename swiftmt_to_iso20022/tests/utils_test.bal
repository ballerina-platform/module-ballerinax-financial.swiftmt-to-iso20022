import ballerina/test;
import ballerinax/financial.swift.mt as swiftmt;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;

@test:Config {
    groups: ["getMT104TransformFunction"]
}

isolated function testGetMT104TransformFunction() returns error? {
    swiftmt:MT104Message message = {
        block2: {messageType: "104"}, 
        block4: {
            MT20: {msgId: {content: "ABC/123"}}, 
            MT30: {Dt: {content: "221024"}}, 
            MT32B: {Ccy: {content: "USD"}, Amnt: {content: "1000,"}}, 
            MT23E: {InstrnCd: {content: "AUTH"}},
            MT71A: {Cd: {content: "BEN"}},
            Transaction: [{
                MT21: {Ref: {content: "REF100"}}, 
                MT32B: {Ccy: {content: "USD"}, Amnt: {content: "1000,"}},
                MT59: {Acc: {content: "BE62510007547061"}, Nm: [{content: "JOHANN WILLEMS"}], AdrsLine: [{content: "RUE JOSEPH II, 19"},{content: "1040 BRUSSELS"}]}
            }]
        }
    };
    xml expected = xml `<Pacs003Document><FIToFICstmrDrctDbt><GrpHdr></GrpHdr><DrctDbtTxInf><PmtId><InstrId>${
""}ABC/123</InstrId><EndToEndId>REF100</EndToEndId><TxId>REF100</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>AUTH</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="USD"><ActiveCurrencyAndAmount_SimpleType>${
""}1000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2022-10-24</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>${
""}CRED</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId/></IntrmyAgt1><Dbtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}BE62510007547061</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></FIToFICstmrDrctDbt></Pacs003Document>`;
    xml actual = check getMT104TransformFunction(message);
    boolean messageCondition = false;
    boolean dateTimeCondition = false;
    if ((actual/**/<GrpHdr>/<MsgId>).data().matches(re `^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{11}$`)) {
        messageCondition = true;
    }
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual, expected, msg = "testGetMT104TransformFunction result incorrect");
    test:assertTrue(messageCondition);
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["convertToDecimal"]
}
isolated function testConvertToDecimal() returns error? {
    swiftmt:Amnt amount = {content: "1000,"};
    swiftmt:Rt? rate = null;
    decimal expected1 = 1000.00;
    decimal? expected2 = null;
    decimal? actual1 = check convertToDecimal(amount);
    decimal? actual2 = check convertToDecimal(rate);
    
    test:assertEquals(actual1, expected1, msg = "testConvertToDecimal result incorrect");
    test:assertEquals(actual2, expected2, msg = "testConvertToDecimal result incorrect");
}

@test:Config {
    groups: ["convertToDecimalMandatory"]
}
isolated function testConvertToDecimalMandatory() returns error? {
    swiftmt:Amnt amount = {content: "1000,"};
    swiftmt:Rt? rate = null;
    decimal expected1 = 1000.00;
    decimal expected2 = 0;
    decimal actual1 = check convertToDecimalMandatory(amount);
    decimal actual2 = check convertToDecimalMandatory(rate);
    
    test:assertEquals(actual1, expected1, msg = "testConvertToDecimal result incorrect");
    test:assertEquals(actual2, expected2, msg = "testConvertToDecimal result incorrect");
}

@test:Config {
    groups: ["convertToDecimalMandatory"]
}
isolated function testGetRemmitanceInformation() returns error? {
    swiftmt:MT70 remmitanceInfo = {Nrtv: {content: "/RFB/BET072"}};
    string expected = "/RFB/BET072";
    string actual = getRemmitanceInformation(remmitanceInfo.Nrtv.content);
    
    test:assertEquals(actual, expected, msg = "testGetRemmitanceInformation result incorrect");
}

@test:Config {
    groups: ["getMandatoryFields"]
}
isolated function testGetMandatoryFields() returns error? {
    string expected = "";
    string actual = getMandatoryFields(());
    
    test:assertEquals(actual, expected, msg = "testGetMandatoryFields result incorrect");
}

@test:Config {
    groups: ["getAddressLine"]
}
isolated function testGetAddressLine() returns error? {
    swiftmt:AdrsLine[] address = [{content: "RUE JOSEPH II, 19"}, {content: "1040 BRUSSELS"}, {content: "Brazil"}];
    string[] expected = ["RUE JOSEPH II, 19", "1040 BRUSSELS", "Brazil"];
    string[]? actual = getAddressLine((), address);
    
    test:assertEquals(actual, expected, msg = "testGetAddressLine result incorrect");
}

@test:Config {
    groups: ["getDetailsChargesCd"]
}
isolated function testGetDetailsChargesCd() returns error? {
    swiftmt:Cd code = {content: "OUR"};
    string expected = "DEBT";
    string actual = check getDetailsChargesCd(code);
    
    test:assertEquals(actual, expected, msg = "testGetDetailsChargesCd result incorrect");
}

@test:Config {
    groups: ["getRegulatoryReporting"]
}
isolated function testGetRegulatoryReporting() returns error? {
    swiftmt:MT77B rgltryRptg = {Nrtv: {content: "/ORDERRES/BE//MEILAAN 1, 9000 GENT"}};
    camtIsoRecord:RegulatoryReporting3[] expected = [{Dtls: [{Cd:"ORDERRES", Ctry: "BE", Inf: ["MEILAAN 1, 9000 GENT"]}]}];
    camtIsoRecord:RegulatoryReporting3[]? actual = getRegulatoryReporting(rgltryRptg.Nrtv.content);
    test:assertEquals(actual, expected, msg = "testGetRegulatoryReporting result incorrect");
}

@test:Config {
    groups: ["getName"]
}
isolated function testGetName() returns error? {
    swiftmt:Nm[] name = [{content: "JOHN"}, {content: "HENRY"}];
    string expected = "JOHN HENRY";
    string? actual = getName(name);
    
    test:assertEquals(actual, expected, msg = "testGetName result incorrect");
}

@test:Config {
    groups: ["getCountryAndTown"]
}
isolated function testGetCountryAndTown() returns error? {
    swiftmt:CntyNTw[] cntryNdTwn = [{content: "SL/COLOMBO"}];
    string[] expected = ["SL", "COLOMBO"];
    string?[] actual = getCountryAndTown(cntryNdTwn);
    
    test:assertEquals(actual, expected, msg = "testGetCountryAndTown result incorrect");
}

@test:Config {
    groups: ["getPartyIdentifierOrAccount"]
}
isolated function testGetPartyIdentifierOrAccount() returns error? {
    swiftmt:PrtyIdn partyIdentifier = {content: "NIDN/DE/121231234342"};
    string?[] expected = ["121231234342", null, null, "NIDN", null];
    string?[] actual = getPartyIdentifierOrAccount(partyIdentifier);
    
    test:assertEquals(actual, expected, msg = "testGetPartyIdentifierOrAccount result incorrect");
}

@test:Config {
    groups: ["getPartyIdentifierOrAccount2"]
}
isolated function testGetPartyIdentifierOrAccount2() returns error? {
    swiftmt:PrtyIdn? partyIdentifier = {content: "/12453423454"};
    string?[] expected = [null, null, "12453423454"];
    string?[] actual = getPartyIdentifierOrAccount2(partyIdentifier);
    
    test:assertEquals(actual, expected, msg = "testGetPartyIdentifierOrAccount2 result incorrect");
}

@test:Config {
    groups: ["validateAccountNumber"]
}
isolated function testValidateAccountNumber() returns error? {
    swiftmt:Acc accountNum = {content: "BE30001216371411"};
    string?[] expected = ["BE30001216371411", null];
    string?[] actual = validateAccountNumber(accountNum);
    
    test:assertEquals(actual, expected, msg = "testValidateAccountNumber result incorrect");
}

@test:Config {
    groups: ["getPartyIdentifier"]
}
isolated function testGetPartyIdentifier() returns error? {
    swiftmt:PrtyIdn partyIdentifier = {content: "12453423454"};
    string? expected = "12453423454";
    string? actual = getPartyIdentifier(partyIdentifier);
    
    test:assertEquals(actual, expected, msg = "testGetPartyIdentifier result incorrect");
}

@test:Config {
    groups: ["getInstructedAmount"]
}
isolated function testGetInstructedAmount() returns error? {
    swiftmt:MT33B instrdAmnt = {Ccy: {content: "USD"}, Amnt: {content: "1000,"}};
    swiftmt:MT32B transAmnt = {Ccy: {content: "USD"}, Amnt: {content: "975,"}};
    decimal expected = 1000.00;
    decimal actual = check getInstructedAmount(transAmnt, instrdAmnt);
    
    test:assertEquals(actual, expected, msg = "testGetInstructedAmount result incorrect");
}

@test:Config {
    groups: ["getTotalInterBankSettlementAmount"]
}
isolated function testGetTotalInterBankSettlementAmount() returns error? {
    swiftmt:MT19 sumAmnt = {Amnt: {content: "1000,"}};
    swiftmt:MT32A stlmntAmnt = {Ccy: {content: "USD"}, Amnt: {content: "975,"},Dt: {content: ""}};
    decimal expected = 1000.00;
    decimal actual = check getTotalInterBankSettlementAmount(sumAmnt, stlmntAmnt);
    
    test:assertEquals(actual, expected, msg = "testGetTotalInterBankSettlementAmount result incorrect");
}

@test:Config {
    groups: ["getSchemaCode"]
}
isolated function testGetSchemaCode() returns error? {
    swiftmt:Acc sumAmnt = {content: "30001216371411"};
    string expected = "BBAN";
    string? actual = getSchemaCode(sumAmnt);
    
    test:assertEquals(actual, expected, msg = "testGetSchemaCode result incorrect");
}

@test:Config {
    groups: ["getChargesInformation"]
}
isolated function testGetChargesInformation() returns error? {
    swiftmt:MT71F sndChrgs = {Ccy: {content: "USD"}, Amnt: {content: "1000,"}};
    swiftmt:MT71G? rcvsChrgs = ();
    camtIsoRecord:Charges16[] expected = [{
        Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 1000.00, 
        Ccy: "USD"}}, 
        Agt: {FinInstnId: {}}, 
        Tp: {Cd: "CRED"}}];
    camtIsoRecord:Charges16[]? actual = check getChargesInformation(sndChrgs, rcvsChrgs);
    
    test:assertEquals(actual, expected, msg = "testGetChargesInformation result incorrect");
}

@test:Config {
    groups: ["getSettlementMethod"]
}
isolated function testGetSettlementMethod() returns error? {
    swiftmt:MT53B correspondent1 = {PrtyIdnTyp: {content: "D"}};
    swiftmt:MT53B correspondent2 = {PrtyIdnTyp: {content: "C"}};
    swiftmt:MT53A correspondent3 = {PrtyIdnTyp: {content: "D"},IdnCd: {content: ""}};
    
    camtIsoRecord:SettlementMethod1Code actual = getSettlementMethod(mt53B = correspondent1);
    test:assertEquals(actual, camtIsoRecord:INDA, msg = "testGetSettlementMethod result incorrect");

    camtIsoRecord:SettlementMethod1Code actual2 = getSettlementMethod(mt53B = correspondent2);
    test:assertEquals(actual2, camtIsoRecord:INGA, msg = "testGetSettlementMethod result incorrect");

    camtIsoRecord:SettlementMethod1Code actual3 = getSettlementMethod(mt53A = correspondent3);
    test:assertEquals(actual3, camtIsoRecord:COVE, msg = "testGetSettlementMethod result incorrect");
}

@test:Config {
    groups: ["getFloorLimit"]
}
isolated function testGetFloorLimit() returns error? {
    swiftmt:MT34F[] floorLimit1 = [{Ccy: {content: "USD"}, Amnt: {content: "1000,"}}, 
        {Ccy: {content: "USD"}, Amnt: {content: "900,"}, Cd: {content: "C"}}];

    swiftmt:MT34F[] floorLimit2 = [{Ccy: {content: "USD"}, Amnt: {content: "1000,"}}];
    
    camtIsoRecord:Limit2[] expected = [{
        Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 1000.00, Ccy: "USD"}}, 
        CdtDbtInd: "DEBT"}, {Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: {
        ActiveOrHistoricCurrencyAndAmount_SimpleType: 900.00, Ccy: "USD"}}, CdtDbtInd: "CRED"}];
    camtIsoRecord:Limit2[]? actual = check getFloorLimit(floorLimit1);
    test:assertEquals(actual, expected, msg = "testGetFloorLimit result incorrect");

    camtIsoRecord:Limit2[] expected2 = [{
        Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 1000.00, Ccy: "USD"}}, 
        CdtDbtInd: "BOTH"}];
    camtIsoRecord:Limit2[]? actual2 = check getFloorLimit(floorLimit2);
    test:assertEquals(actual2, expected2, msg = "testGetFloorLimit result incorrect");
}

@test:Config {
    groups: ["getEntries"]
}
isolated function testGetEntries() returns error? {
    swiftmt:MT61[] statementLine = [{Cd: {content: "D"}, RefAccOwn: {content: "304955"}, IdnCd: {content: "BNK"}, 
        ValDt: {content: "241106"}, Amnt: {content: "1000,"}, TranTyp: {content: "F"}}];
    
    camtIsoRecord:ReportEntry14[] expected = [{Sts: {Cd: "BOOK"}, BkTxCd: {Prtry: {Cd: "F"}}, Amt: {
        ActiveOrHistoricCurrencyAndAmount_SimpleType: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 1000.00, Ccy: ""}},
        CdtDbtInd: "DBIT", ValDt: {Dt: "2024-11-06"}, NtryRef: "304955"}];
    camtIsoRecord:ReportEntry14[] actual = check getEntries(statementLine);
    test:assertEquals(actual, expected, msg = "testGetEntries result incorrect");
}

@test:Config {
    groups: ["getBalance"]
}
isolated function testGetBalance() returns error? {
    swiftmt:MT60F firstOpenBalance = {Dt: {content: "241107"}, Cd: {content: "D"}, Ccy: {content: "USD"}, 
        Amnt: {content: "900,10"}};
    swiftmt:MT62F firstCloseBalance = {Dt: {content: "241107"}, Cd: {content: "C"}, Ccy: {content: "USD"}, 
        Amnt: {content: "1100,"}};
    swiftmt:MT64[] closeAvailableBalance = [{Dt: {content: "241107"}, Cd: {content: "C"}, Ccy: {content: "USD"}, 
        Amnt: {content: "1100,"}}];
    swiftmt:MT65[] forwardAvailableBalance = [{Dt: {content: "241107"}, Cd: {content: "D"}, Ccy: {content: "USD"}, 
        Amnt: {content: "900,"}}];

    camtIsoRecord:CashBalance8[] expected = [{Dt: {Dt: "2024-11-07"}, Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 
        {ActiveOrHistoricCurrencyAndAmount_SimpleType: 900.10, Ccy: "USD"}}, CdtDbtInd: "DBIT", 
        Tp: {CdOrPrtry: {Cd: "PRCD"}}}, {Dt: {Dt: "2024-11-07"}, Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 
        {ActiveOrHistoricCurrencyAndAmount_SimpleType: 1100.00, Ccy: "USD"}}, CdtDbtInd: "CRDT", 
        Tp: {CdOrPrtry: {Cd: "CLBD"}}}, {Dt: {Dt: "2024-11-07"}, Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 
        {ActiveOrHistoricCurrencyAndAmount_SimpleType: 1100.00, Ccy: "USD"}}, CdtDbtInd: "CRDT", 
        Tp: {CdOrPrtry: {Cd: "CLAV"}}}, {Dt: {Dt: "2024-11-07"}, Amt: {ActiveOrHistoricCurrencyAndAmount_SimpleType: 
        {ActiveOrHistoricCurrencyAndAmount_SimpleType: 900.00, Ccy: "USD"}}, CdtDbtInd: "DBIT", 
        Tp: {CdOrPrtry: {Cd: "FWAV"}}}];

    camtIsoRecord:CashBalance8[] actual = check getBalance(firstOpenBalance, firstCloseBalance, closeAvailableBalance, forwardAvailableBalance = forwardAvailableBalance);
    test:assertEquals(actual, expected, msg = "testGetBalance result incorrect");
}

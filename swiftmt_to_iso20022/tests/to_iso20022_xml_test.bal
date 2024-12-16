import ballerina/test;

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt101ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01UXXXFIHHAXXX0000000000}
{2:I101CHXXUS33XXXXN}
{4:
:20:11FF99RR
:28D:1/1
:30:090327
:21:REF501
:21F:UKNOWIT1234
:32B:USD90000,
:50F:/9020123100
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
6/FI/HELSINKI
:57C://CP9999
:59F:/756-857489-21
1/SOFTEASE PC GRAPHICS
2/34 BRENTWOOD ROAD
3/US/SEAFORD, NEW YORK, 11246
:70:/INV/19S95
:77B:/BENEFRES/US
//34 BRENTWOOD ROAD
//SEAFORD, NEW YORK 11246
:33B:EUR100000,
:71A:SHA
:25A:/9101000123
:36:0,90
:21:REF502
:21F:UKNOWIT1234
:23E:CHQB
:32B:USD1800,
:50F:/9020123100
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
3/FI/HELSINKI
:59F:/TONY BALONEY
1/MYRTLE AVENUE 3159
2/US/BROOKLYN, NEW YORK 11245
:70:09-02 PENSION PAYMENT
:33B:EUR2000,
:71A:OUR
:25A:/9101000123
:36:0,9
:21:REF503
:23E:CMZB
:23E:INTC
:32B:USD0,
:50F:/9102099999
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
3/FI/HELSINKI
:52A:CHXXUS33BBB
:59F:/9020123100
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
3/FI/HELSINKI
:71A:SHA
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.12"><CstmrCdtTrfInitn><GrpHdr></GrpHdr><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><PmtTpInf/><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgBr>SHAR</ChrgBr><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF501</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>100000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf><XchgRate>0.90</XchgRate></XchgRateInf><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId><Cd>/CP9999</Cd></ClrSysId><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>SOFTEASE PC GRAPHICS</Nm><PstlAdr><TwnNm>SEAFORD, NEW YORK, 11246</TwnNm><Ctry>US</Ctry><AdrLine>34 BRENTWOOD ROAD</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>756-857489-21</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><RgltryRptg><Dtls><Ctry>US</Ctry><Cd>BENEFRES</Cd><Inf>34 BRENTWOOD ROAD SEAFORD, NEW YORK 11246</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>/INV/19S95</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><PmtTpInf/><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgBr>DEBT</ChrgBr><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF502</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf><XchgRate>0.9</XchgRate></XchgRateInf><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>MYRTLE AVENUE 3159</Nm><PstlAdr><AdrLine>US/BROOKLYN, NEW YORK 11245</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>TONY BALONEY</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt><Cd>CHQB</Cd></InstrForCdtrAgt><RmtInf><Ustrd>09-02 PENSION PAYMENT</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><PmtTpInf><CtgyPurp><Cd>INTC</Cd></CtgyPurp></PmtTpInf><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>9102099999</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>CHXXUS33BBB</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgBr>SHAR</ChrgBr><ChrgsAcct><Id><Othr><SchmeNm/></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF503</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>0</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf/><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForDbtrAgt><Cd>CMZB</Cd></InstrForDbtrAgt><RmtInf><Ustrd/></RmtInf></CdtTrfTxInf></PmtInf></CstmrCdtTrfInitn></Document>`;
    
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt102StpToIso20022Xml() returns error? {
    string finMessage = string `{1:F01BNKACHZZXXXX0000000000}
{2:I102BNKBBEBBXXXXN}
{3:
{121:4ea37e81-98ec-4014-b7a4-1ff4611b3fca}
{119:STP}
}
{4:
:20:5362/MPB
:23:CREDIT
:50K:/AL47212110090000000235698741
CONSORTIA PENSION SCHEME
FRIEDRICHSTRASSE, 27
8022-ZURICH
:53A:/
BNPAFRPP
:71A:OUR
:36:1,6
:21:ABC/123
:32B:EUR1250,
:59:/001161685134
JOHANN WILLEMS
RUE JOSEPH II, 19
1040 BRUSSELS
:70:PENSION PAYMENT SEPTEMBER 2009
:33B:CHF2000,
:71G:EUR5,
:21:ABC/124
:32B:EUR1875,
:59:/510007547061
JOAN MILLS
AVENUE LOUISE 213
1050 BRUSSELS
:70:PENSION PAYMENT SEPTEMBER 2003
:33B:CHF3000,
:71G:EUR5,
:32A:090828EUR3135,
:19:3125,
:71G:EUR10,
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="CHF"><ActiveOrHistoricCurrencyAndAmount_SimpleType>2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="CHF"><ActiveOrHistoricCurrencyAndAmount_SimpleType>3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt102ToIso20022Xml4() returns error? {
    string finMessage = string `{1:F01BNKACHZZXXXX0000000000}
{2:I102BNKBBEBBXXXXN}
{4:
:20:5362/MPB
:23:CREDIT
:50K:/AL47212110090000000235698741
CONSORTIA PENSION SCHEME
FRIEDRICHSTRASSE, 27
8022-ZURICH
:53A:/
BNPAFRPP
:71A:OUR
:36:1,6
:21:ABC/123
:32B:EUR1250,
:59:/001161685134
JOHANN WILLEMS
RUE JOSEPH II, 19
1040 BRUSSELS
:70:PENSION PAYMENT SEPTEMBER 2009
:33B:CHF2000,
:71G:EUR5,
:21:ABC/124
:26T:ABC
:32B:EUR1875,
:59:/510007547061
JOAN MILLS
AVENUE LOUISE 213
1050 BRUSSELS
:70:PENSION PAYMENT SEPTEMBER 2003
:33B:CHF3000,
:71G:EUR5,
:32A:090828EUR3135,
:19:3125,
:71G:EUR10,
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="CHF"><ActiveOrHistoricCurrencyAndAmount_SimpleType>2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/124</EndToEndId><TxId>ABC/124</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="CHF"><ActiveOrHistoricCurrencyAndAmount_SimpleType>3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry>ABC</Prtry></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;

    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }

    xml:Element groupHeader = check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt103RemitToIso20022Xml() returns error? {
    string finMessage = string `{1:F01BKAUATWWAXXX0000000000}
{2:O1030000091231RABOBE22XXXX00000000009912310000N}
{3:{119:REMIT}}
{4:
:20:494931/DEV
:23B:CRED
:32A:090828EUR1958,47
:33B:EUR1958,47
:50F:/942267890
1/FRANZ HOLZAPFEL GMBH
2/GELBSTRASSE, 13
3/AT/VIENNA
:59F:/502664959
1/H.F. JANSSEN
2/LEDEBOERSTRAAT 27
3/NL/AMSTERDAM
:71A:SHA
:77T:/NARR/UNH+123A5+FINPAY:D:98A:UN'DOC+...
-}
{5:{CHK:XXXX}}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>494931/DEV</InstrId><EndToEndId/></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1958.47</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>1958.47</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>FRANZ HOLZAPFEL GMBH</Nm><PstlAdr><TwnNm>VIENNA</TwnNm><Ctry>AT</Ctry><AdrLine>GELBSTRASSE, 13</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>942267890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>H.F. JANSSEN</Nm><PstlAdr><TwnNm>AMSTERDAM</TwnNm><Ctry>NL</Ctry><AdrLine>LEDEBOERSTRAAT 27</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>502664959</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd/></RmtInf><SplmtryData><Envlp><Nrtv>UNH+123A5+FINPAY:D:98A:UN'DOC+...</Nrtv></Envlp></SplmtryData></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);

    string dateTimeExpected = "2009-12-31T00:00:00";
    string dateTimeActual = (actual/**/<GrpHdr>/<CreDtTm>).data();

    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");

    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertEquals(dateTimeActual, dateTimeExpected, msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt103StpToIso20022Xml6() returns error? {
    string finMessage = string `{1:F01BKAUATWWXXXX0000000000}
{2:I103OCBCSGSGXXXXN}
{3:{119:STP}}
{4:
:20:494938/DEV
:23B:CRED
:32A:090828USD850,
:50F:/942267890
1/FRANZ HOLZAPFEL GMBH
2/GELBSTRASSE, 13
3/AT/VIENNA
:52A:BKAUATWWEIS
:57A:OCBCSGSG
:59F:/729615-941
1/C.WON
2/PARK AVENUE 1
3/SG
:70:/RFB/EXPENSES 7/2009
:71A:SHA
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>494938/DEV</InstrId><EndToEndId/></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="USD"><ActiveCurrencyAndAmount_SimpleType>850.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>850.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>FRANZ HOLZAPFEL GMBH</Nm><PstlAdr><TwnNm>VIENNA</TwnNm><Ctry>AT</Ctry><AdrLine>GELBSTRASSE, 13</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>942267890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>BKAUATWWEIS</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><BICFI>OCBCSGSG</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>C.WON</Nm><PstlAdr><Ctry>SG</Ctry><AdrLine>PARK AVENUE 1</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>729615-941</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>/RFB/EXPENSES 7/2009</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;

    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt103ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01CITIUS33AXXX0000000000}
{2:I103OCBCSGSGXXXXN}
{3:{121:31df8b48-8845-4fc6-86cd-5586df980e97}}
{4:
:20:MSPSDRS/123
:13C:/CLSTIME/0915+0100
:23B:CRED
:23E:TELI/3226553478
:26T:K90
:32A:090828USD840,
:33B:USD850,
:36:0,9236
:50K:/NE58NE0380100100130305000268
JOHN DOE
123 MAIN STREET
US/NEW YORK
APARTMENT 456
:51A:/D/1234567890123456
DEUTDEFFXXX
:52A:/D/1234567890123456
DEUTDEFFXXX
:53B:/D/1234567890
NEW YORK BRANCH
:54D:/D/1234567890
FINANZBANK AG
EISENSTADT
MARKTPLATZ 5
AT
:55D:/D/1234567890
FINANZBANK AG
EISENSTADT
MARKTPLATZ 5
AT
:56C:/9876543210
:57D:/D/8765432109876543
CITIBANK N.A.
399 PARK AVENUE
NEW YORK
US
:59F:/12345678
1/DEPT OF PROMOTION OF SPICY FISH
1/CENTER FOR INTERNATIONALISATION
3/CN
:70:/TSU/00000089963-0820-01/ABC-15/256
214,
:71A:SHA
:71F:USD10,
:71G:EUR5,50
:72:/INS/ABNANL2A
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
-}{5:{CHK:XXXXXXXXXXXX}}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>MSPSDRS/123</InstrId><EndToEndId/><UETR>31df8b48-8845-4fc6-86cd-5586df980e97</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="USD"><ActiveCurrencyAndAmount_SimpleType>840.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq><CLSTm>09:15:00+01:00</CLSTm></SttlmTmReq><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>850.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>0.9236</XchgRate><ChrgBr>SHAR</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>10.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>CRED</Cd></Tp></ChrgsInf><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>5.50</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></PrvsInstgAgt1><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>JOHN DOE</Nm><PstlAdr><AdrLine>123 MAIN STREET</AdrLine><AdrLine>US/NEW YORK</AdrLine><AdrLine>APARTMENT 456</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>NE58NE0380100100130305000268</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>DEUTDEFFXXX</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><Id>234567890123456</Id><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>CITIBANK N.A.</Nm><PstlAdr><AdrLine>399 PARK AVENUE</AdrLine><AdrLine>NEW YORK</AdrLine><AdrLine>US</AdrLine></PstlAdr></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>DEPT OF PROMOTION OF SPICY FISH CENTER FOR INTERNATIONALISATION</Nm><PstlAdr><Ctry>CN</Ctry></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>12345678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForNxtAgt><Cd>TELI</Cd><InstrInf>3226553478</InstrInf></InstrForNxtAgt><Purp><Prtry>K90</Prtry></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>/TSU/00000089963-0820-01/ABC-15/256
214,</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt104ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01BANKBEBBAXXX0000000000}{2:I104BANKDEFFXXXXN}{4:
:20:REFERENCE12345
:23E:OTHR
:30:090921
:21:REF12444
:32B:EUR1875,
:50F:/12345678
1/SMITH JOHN
2/299, PARK AVENUE
3/US/NEW YORK, NY 10017
:59F:/12345678
1/DEPT OF PROMOTION OF SPICY FISH
1/CENTER FOR INTERNATIONALISATION
3/CN
:71A:OUR
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
:21:REF12345
:32B:EUR1875,
:50F:/12345678
1/SMITH JOHN
2/299, PARK AVENUE
3/US/NEW YORK, NY 10017
:59F:/12345678
1/DEPT OF PROMOTION OF SPICY FISH
1/CENTER FOR INTERNATIONALISATION
3/CN
:71A:OUR
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
:32B:EUR1875,
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.11"><FIToFICstmrDrctDbt><GrpHdr></GrpHdr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12444</EndToEndId><TxId>REF12444</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId><TxId>REF12345</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></FIToFICstmrDrctDbt></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;

    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt104ToIso20022Xml2() returns error? {
    string finMessage = string `{1:F01BANKBEBBAXXX0000000000}{2:I104BANKDEFFXXXXN}{4:
:20:REFERENCE12345
:23E:RFDD
:30:090921
:21:REF12444
:32B:EUR1875,
:50F:/12345678
1/SMITH JOHN
2/299, PARK AVENUE
3/US/NEW YORK, NY 10017
:59F:/12345678
1/DEPT OF PROMOTION OF SPICY FISH
1/CENTER FOR INTERNATIONALISATION
3/CN
:71A:OUR
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
:21:REF12345
:32B:EUR1875,
:50F:/12345678
1/SMITH JOHN
2/299, PARK AVENUE
3/US/NEW YORK, NY 10017
:59F:/12345678
1/DEPT OF PROMOTION OF SPICY FISH
1/CENTER FOR INTERNATIONALISATION
3/CN
:71A:OUR
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
:32B:EUR1875,
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.11"><CstmrDrctDbtInitn><GrpHdr></GrpHdr><PmtInf><PmtInfId>REF12444</PmtInfId><PmtMtd>DD</PmtMtd><PmtTpInf><CtgyPurp><Cd>RFDD</Cd></CtgyPurp></PmtTpInf><ReqdColltnDt>2009-09-21</ReqdColltnDt><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><ChrgBr>DEBT</ChrgBr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12444</EndToEndId></PmtId><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><DrctDbtTx><MndtRltdInf/></DrctDbtTx><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Purp><Prtry/></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></PmtInf><PmtInf><PmtInfId>REF12345</PmtInfId><PmtMtd>DD</PmtMtd><PmtTpInf><CtgyPurp><Cd>RFDD</Cd></CtgyPurp></PmtTpInf><ReqdColltnDt>2009-09-21</ReqdColltnDt><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><ChrgBr>DEBT</ChrgBr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId></PmtId><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><DrctDbtTx><MndtRltdInf/></DrctDbtTx><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Purp><Prtry/></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></PmtInf></CstmrDrctDbtInitn></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt200ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01BKAUATWWXXXX0000000000}
{2:I200CHASUS33XXXXN}
{4:
:20:39857579
:32A:090525USD1000000,
:53B:/34554-3049
:56A:CITIUS33
:57A:CITIUS33MIA
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>39857579</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="USD"><ActiveCurrencyAndAmount_SimpleType>1000000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-25</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><Id>4554-3049</Id><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>CITIUS33MIA</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt201ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01UBSWCHZH80AXXX0000000000}
{2:I201ABNANL2AXXXXN}
{4:
:19:61000,
:30:090528
:20:1234/22
:32B:EUR5000,
:57A:INGBNL2A
:20:1235/22
:32B:EUR7500,
:57A:BBSPNL2A
:20:1227/23
:32B:EUR12500,
:57B:ROTTERDAM
:20:1248/32
:32B:EUR6000,
:57A:CRLYFRPP
:20:1295/22
:32B:EUR30000,
:56A:INGBNL2A
:57A:DEUTDEFF
:72:/TELE/
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>1234/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>5000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1235/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>7500.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>BBSPNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1227/23</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>12500.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr><AdrLine>ROTTERDAM</AdrLine></PstlAdr></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1248/32</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>6000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>CRLYFRPP</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1295/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>30000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>DEUTDEFF</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><InstrForNxtAgt><Cd>TELE</Cd></InstrForNxtAgt></CdtTrfTxInf></FICdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt202ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01BANKGB2LXXXX0000000000}
{2:I202BANKJPJTXXXXN}
{4:
:20:JPYNOSTRO170105
:21:CLSINSTR170105
:13C:/CLSTIME/0700+0100
:32A:170105JPY5000000,
:57A:BOJPJPJT
:58A:CLSBUS33
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>JPYNOSTRO170105</InstrId><EndToEndId>CLSINSTR170105</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="JPY"><ActiveCurrencyAndAmount_SimpleType>5000000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2017-01-05</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq><CLSTm>07:00:00+01:00</CLSTm></SttlmTmReq><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>BOJPJPJT</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>CLSBUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt202CovToIso20022Xml() returns error? {
    string finMessage = string `{1:F01AAAABEBBXXXX0000000000}
{2:I202CCCCUS33XXXX}
{3:{119:COV}}
{4:
:20:090525/124COV
:21:090525/123COV
:32A:090527USD10500,00
:56A:ABFDUS33
:57A:DDDDUS33
:58A:BBBBGB22
:50F:/123564982101
1/MR. BIG
2/HIGH STREET 3
3/BE/BRUSSELS
:59F:/987654321
1/MR. SMALL
2/LOW STREET 15
3/GB/LONDON
:70:/INV/1234
:33B:USD10500,00
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>090525/124COV</InstrId><EndToEndId>090525/123COV</EndToEndId><TxId>090525/123COV</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="USD"><ActiveCurrencyAndAmount_SimpleType>10500.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-27</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><IntrmyAgt1><FinInstnId><BICFI>ABFDUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>DDDDUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>BBBBGB22</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><UndrlygCstmrCdtTrf><Dbtr><Nm>MR. BIG</Nm><PstlAdr><TwnNm>BRUSSELS</TwnNm><Ctry>BE</Ctry><AdrLine>HIGH STREET 3</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>123564982101</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><BICFI>BBBBGB22</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>MR. SMALL</Nm><PstlAdr><TwnNm>LONDON</TwnNm><Ctry>GB</Ctry><AdrLine>LOW STREET 15</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>987654321</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><RmtInf><Ustrd>/INV/1234</Ustrd></RmtInf><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>10500.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></UndrlygCstmrCdtTrf></CdtTrfTxInf></FICdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt203ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01UBSWCHZH80A0000000000}
{2:I203ABNANL2AXXXX}
{4:
:19:5000000,
:30:090528
:20:2345
:21:789022
:32B:EUR500000,
:57A:INGBNL2A
:58A:MGTCUS33
:20:2346
:21:ABX2270
:32B:EUR1500000,
:57A:BBSPNL2A
:58A:MELNGB2X
:20:2347
:21:CO 2750/26
:32B:EUR1000000,
:57A:CITINL2X
:58A:CITIUS33
:20:2348
:21:DRESFF2344BKAUWW
:32B:EUR2000000,
:58A:DRESDEFF
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr></GrpHdr><CdtTrfTxInf><PmtId><InstrId>2345</InstrId><EndToEndId>789022</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>500000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>MGTCUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2346</InstrId><EndToEndId>ABX2270</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1500000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>BBSPNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>MELNGB2X</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2347</InstrId><EndToEndId>CO 2750/26</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1000000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>CITINL2X</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2348</InstrId><EndToEndId>DRESFF2344BKAUWW</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>2000000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>DRESDEFF</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt204ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01XCMEUS4CXXXX0000000000}
{2:I204CNORUS44XXXXN}
{4:
:20:XCME REF1
:19:50000,
:30:090921
:57A:FNBCUS44
:20:XCME REF2
:21:MANDATEREF1
:32B:USD50000,
:53A:MLNYUS33
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.010.001.06"><FIDrctDbt><GrpHdr></GrpHdr><CdtInstr><CdtId>XCME REF1</CdtId><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><CdtrAgt><FinInstnId><BICFI>FNBCUS44</BICFI><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><DrctDbtTxInf><PmtId><InstrId>XCME REF2</InstrId><EndToEndId>MANDATEREF1</EndToEndId></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="USD"><ActiveCurrencyAndAmount_SimpleType>50000.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><Dbtr><FinInstnId><BICFI>MLNYUS33</BICFI><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct></DrctDbtTxInf></CdtInstr></FIDrctDbt></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

@test:Config {
    groups: ["toIso20022Xml"]
}
isolated function testMt210ToIso20022Xml() returns error? {
    string finMessage = string `{1:F01BEBEDEBBXXXX0000000000}
{2:I210CHASUS33XXXXN}
{4:
:20:318393
:30:100222
:21:BEBEBB0023CRESZZ
:32B:USD230000,
:52A:CRESCHZZ
:56A:CITIUS33
-}`; 

    xml expected = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.057.001.08"><NtfctnToRcv><GrpHdr></GrpHdr><Ntfctn><Id>318393</Id><Itm><Id>BEBEBB0023CRESZZ</Id><EndToEndId>BEBEBB0023CRESZZ</EndToEndId><Acct><Id><Othr><SchmeNm/></Othr></Id></Acct><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>230000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><XpctdValDt>100222</XpctdValDt><Dbtr><Pty><PstlAdr/><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Pty></Dbtr><DbtrAgt><FinInstnId><BICFI>CRESCHZZ</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><IntrmyAgt><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt></Itm></Ntfctn></NtfctnToRcv></Document>`;
    xml actual = check toIso20022Xml(finMessage);
    boolean dateTimeCondition = false;
    
    if ((actual/**/<GrpHdr>/<CreDtTm>).data().matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,9}Z`)) {
        dateTimeCondition = true;
    }
    xml:Element groupHeader= check (actual/**/<GrpHdr>).ensureType();
    groupHeader.setChildren("");
    test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
    test:assertTrue(dateTimeCondition);
}

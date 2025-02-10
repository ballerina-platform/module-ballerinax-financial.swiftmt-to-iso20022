// // Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
// //
// // WSO2 LLC. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// //    http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied. See the License for the
// // specific language governing permissions and limitations
// // under the License.

// import ballerina/test;

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt101ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01UXXXFIHHAXXX0000000000}
// {2:I101CHXXUS33XXXXN}
// {4:
// :20:11FF99RR
// :28D:1/1
// :30:090327
// :21:REF501
// :21F:UKNOWIT1234
// :32B:USD90000,
// :50F:/9020123100
// 1/FINPETROL INC.
// 2/ANDRELAE SPINKATU 7
// 6/FI/HELSINKI
// :57C://CP9999
// :59F:/756-857489-21
// 1/SOFTEASE PC GRAPHICS
// 2/34 BRENTWOOD ROAD
// 3/US/SEAFORD, NEW YORK, 11246
// :70:/INV/19S95
// :77B:/BENEFRES/US
// //34 BRENTWOOD ROAD
// //SEAFORD, NEW YORK 11246
// :33B:EUR100000,
// :71A:SHA
// :25A:/9101000123
// :36:0,90
// :21:REF502
// :21F:UKNOWIT1234
// :23E:CHQB
// :32B:USD1800,
// :50F:/9020123100
// 1/FINPETROL INC.
// 2/ANDRELAE SPINKATU 7
// 3/FI/HELSINKI
// :59F:/TONY BALONEY
// 1/MYRTLE AVENUE 3159
// 2/US/BROOKLYN, NEW YORK 11245
// :70:09-02 PENSION PAYMENT
// :33B:EUR2000,
// :71A:OUR
// :25A:/9101000123
// :36:0,9
// :21:REF503
// :23E:CMZB
// :23E:INTC
// :32B:USD0,
// :50F:/9102099999
// 1/FINPETROL INC.
// 2/ANDRELAE SPINKATU 7
// 3/FI/HELSINKI
// :52A:CHXXUS33BBB
// :59F:/9020123100
// 1/FINPETROL INC.
// 2/ANDRELAE SPINKATU 7
// 3/FI/HELSINKI
// :71A:SHA
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>UXXXFIHH</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>CHXXUS33</BICFI></FinInstnId></FIId></To><BizMsgIdr>11FF99RR</BizMsgIdr><MsgDefIdr>pain.001.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.12"><CstmrCdtTrfInitn><GrpHdr><MsgId>11FF99RR</MsgId><NbOfTxs>3</NbOfTxs><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><FwdgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></FwdgAgt></GrpHdr><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF501</EndToEndId></PmtId><PmtTpInf/><Amt><InstdAmt Ccy="EUR">100000.00</InstdAmt></Amt><XchgRateInf><XchgRate>0.90</XchgRate></XchgRateInf><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId><Cd>CP9999</Cd></ClrSysId><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>SOFTEASE PC GRAPHICS</Nm><PstlAdr><TwnNm>SEAFORD, NEW YORK, 11246</TwnNm><Ctry>US</Ctry><AdrLine>34 BRENTWOOD ROAD</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>756-857489-21</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><RgltryRptg><Dtls><Ctry>US</Ctry><Cd>BENEFRES</Cd><Inf>34 BRENTWOOD ROAD SEAFORD, NEW YORK 11246</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>/INV/19S95</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF502</EndToEndId></PmtId><PmtTpInf/><Amt><InstdAmt Ccy="EUR">2000.00</InstdAmt></Amt><XchgRateInf><XchgRate>0.9</XchgRate></XchgRateInf><ChrgBr>DEBT</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>MYRTLE AVENUE 3159</Nm><PstlAdr><AdrLine>US/BROOKLYN, NEW YORK 11245</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>TONY BALONEY</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt><Cd>CHQB</Cd></InstrForCdtrAgt><RmtInf><Ustrd>09-02 PENSION PAYMENT</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>9102099999</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>CHXXUS33BBB</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgsAcct><Id><Othr><SchmeNm/></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF503</EndToEndId></PmtId><PmtTpInf><CtgyPurp><Cd>INTC</Cd></CtgyPurp></PmtTpInf><Amt><InstdAmt Ccy="USD">0</InstdAmt></Amt><XchgRateInf/><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForDbtrAgt><Cd>CMZB</Cd></InstrForDbtrAgt><RmtInf><Ustrd/></RmtInf></CdtTrfTxInf></PmtInf></CstmrCdtTrfInitn></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt102StpToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01BNKACHZZXXXX0000000000}
// {2:I102BNKBBEBBXXXXN}
// {3:
// {121:4ea37e81-98ec-4014-b7a4-1ff4611b3fca}
// {119:STP}
// }
// {4:
// :20:5362/MPB
// :23:CREDIT
// :50K:/AL47212110090000000235698741
// CONSORTIA PENSION SCHEME
// FRIEDRICHSTRASSE, 27
// 8022-ZURICH
// :53A:/
// BNPAFRPP
// :71A:OUR
// :36:1,6
// :21:ABC/123
// :32B:EUR1250,
// :59:/001161685134
// JOHANN WILLEMS
// RUE JOSEPH II, 19
// 1040 BRUSSELS
// :70:PENSION PAYMENT SEPTEMBER 2009
// :33B:CHF2000,
// :71G:EUR5,
// :21:ABC/124
// :32B:EUR1875,
// :59:/510007547061
// JOAN MILLS
// AVENUE LOUISE 213
// 1050 BRUSSELS
// :70:PENSION PAYMENT SEPTEMBER 2003
// :33B:CHF3000,
// :71G:EUR5,
// :32A:090828EUR3135,
// :19:3125,
// :71G:EUR10,
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BNKACHZZ</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>BNKBBEBB</BICFI></FinInstnId></FIId></To><BizMsgIdr>5362/MPB</BizMsgIdr><MsgDefIdr>pacs.008.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>5362/MPB</MsgId><NbOfTxs>2</NbOfTxs><CtrlSum>3125.00</CtrlSum><TtlIntrBkSttlmAmt Ccy="EUR">3135.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>COVE</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><BICFI>BNPAFRPP</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>BNKACHZZ</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BNKBBEBB</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1250.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="CHF">2000.00</InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt Ccy="EUR">5.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1875.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="CHF">3000.00</InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt Ccy="EUR">5.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt102ToIso20022Xml4() returns error? {
//     string finMessage = string `{1:F01BNKACHZZXXXX0000000000}
// {2:I102BNKBBEBBXXXXN}
// {4:
// :20:5362/MPB
// :23:CREDIT
// :50K:/AL47212110090000000235698741
// CONSORTIA PENSION SCHEME
// FRIEDRICHSTRASSE, 27
// 8022-ZURICH
// :53A:/
// BNPAFRPP
// :71A:OUR
// :36:1,6
// :21:ABC/123
// :32B:EUR1250,
// :59:/001161685134
// JOHANN WILLEMS
// RUE JOSEPH II, 19
// 1040 BRUSSELS
// :70:PENSION PAYMENT SEPTEMBER 2009
// :33B:CHF2000,
// :71G:EUR5,
// :21:ABC/124
// :26T:ABC
// :32B:EUR1875,
// :59:/510007547061
// JOAN MILLS
// AVENUE LOUISE 213
// 1050 BRUSSELS
// :70:PENSION PAYMENT SEPTEMBER 2003
// :33B:CHF3000,
// :71G:EUR5,
// :32A:090828EUR3135,
// :19:3125,
// :71G:EUR10,
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BNKACHZZ</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>BNKBBEBB</BICFI></FinInstnId></FIId></To><BizMsgIdr>5362/MPB</BizMsgIdr><MsgDefIdr>pacs.008.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>5362/MPB</MsgId><NbOfTxs>2</NbOfTxs><TtlIntrBkSttlmAmt Ccy="EUR">3125.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>COVE</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><BICFI>BNPAFRPP</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BNKBBEBB</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1250.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="CHF">2000.00</InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt Ccy="EUR">5.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/124</EndToEndId><TxId>ABC/124</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1875.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="CHF">3000.00</InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt Ccy="EUR">5.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry>ABC</Prtry></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt103RemitToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01BKAUATWWAXXX0000000000}
// {2:O1030000091231RABOBE22XXXX00000000009912310000N}
// {3:{119:REMIT}}
// {4:
// :20:494931/DEV
// :23B:CRED
// :32A:090828EUR1958,47
// :33B:EUR1958,47
// :50F:/942267890
// 1/FRANZ HOLZAPFEL GMBH
// 2/GELBSTRASSE, 13
// 3/AT/VIENNA
// :59F:/502664959
// 1/H.F. JANSSEN
// 2/LEDEBOERSTRAAT 27
// 3/NL/AMSTERDAM
// :71A:SHA
// :77T:/NARR/UNH+123A5+FINPAY:D:98A:UN'DOC+...
// -}
// {5:{CHK:XXXX}}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>RABOBE22</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></FIId></To><BizMsgIdr>494931/DEV</BizMsgIdr><MsgDefIdr>pacs.008.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>494931/DEV</MsgId><NbOfTxs>1</NbOfTxs><TtlIntrBkSttlmAmt Ccy="EUR">1958.47</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct><ThrdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></ThrdRmbrsmntAgt><ThrdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></ThrdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>494931/DEV</InstrId><EndToEndId/></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1958.47</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="EUR">1958.47</InstdAmt><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>FRANZ HOLZAPFEL GMBH</Nm><PstlAdr><TwnNm>VIENNA</TwnNm><Ctry>AT</Ctry><AdrLine>GELBSTRASSE, 13</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>942267890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>H.F. JANSSEN</Nm><PstlAdr><TwnNm>AMSTERDAM</TwnNm><Ctry>NL</Ctry><AdrLine>LEDEBOERSTRAAT 27</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>502664959</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd/></RmtInf><SplmtryData><Envlp><Nrtv>UNH+123A5+FINPAY:D:98A:UN'DOC+...</Nrtv></Envlp></SplmtryData></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt103StpToIso20022Xml6() returns error? {
//     string finMessage = string `{1:F01BKAUATWWXXXX0000000000}
// {2:I103OCBCSGSGXXXXN}
// {3:{119:STP}}
// {4:
// :20:494938/DEV
// :23B:CRED
// :32A:090828USD850,
// :50F:/942267890
// 1/FRANZ HOLZAPFEL GMBH
// 2/GELBSTRASSE, 13
// 3/AT/VIENNA
// :52A:BKAUATWWEIS
// :57A:OCBCSGSG
// :59F:/729615-941
// 1/C.WON
// 2/PARK AVENUE 1
// 3/SG
// :70:/RFB/EXPENSES 7/2009
// :71A:SHA
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>OCBCSGSG</BICFI></FinInstnId></FIId></To><BizMsgIdr>494938/DEV</BizMsgIdr><MsgDefIdr>pacs.008.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>494938/DEV</MsgId><NbOfTxs>1</NbOfTxs><TtlIntrBkSttlmAmt Ccy="USD">850.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct><ThrdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></ThrdRmbrsmntAgt><ThrdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></ThrdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>OCBCSGSG</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>494938/DEV</InstrId><EndToEndId/></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="USD">850.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="USD">850.00</InstdAmt><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>FRANZ HOLZAPFEL GMBH</Nm><PstlAdr><TwnNm>VIENNA</TwnNm><Ctry>AT</Ctry><AdrLine>GELBSTRASSE, 13</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>942267890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>BKAUATWWEIS</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><BICFI>OCBCSGSG</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>C.WON</Nm><PstlAdr><Ctry>SG</Ctry><AdrLine>PARK AVENUE 1</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>729615-941</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>/RFB/EXPENSES 7/2009</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt103ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01CITIUS33AXXX0000000000}
// {2:I103OCBCSGSGXXXXN}
// {3:{121:31df8b48-8845-4fc6-86cd-5586df980e97}}
// {4:
// :20:MSPSDRS/123
// :13C:/CLSTIME/0915+0100
// :23B:CRED
// :23E:TELI/3226553478
// :26T:K90
// :32A:090828USD840,
// :33B:USD850,
// :36:0,9236
// :50K:/NE58NE0380100100130305000268
// JOHN DOE
// 123 MAIN STREET
// US/NEW YORK
// APARTMENT 456
// :51A:/D/1234567890123456
// DEUTDEFFXXX
// :52A:/D/1234567890123456
// DEUTDEFFXXX
// :53B:/D/1234567890
// NEW YORK BRANCH
// :54D:/D/1234567890
// FINANZBANK AG
// EISENSTADT
// MARKTPLATZ 5
// AT
// :55D:/D/1234567890
// FINANZBANK AG
// EISENSTADT
// MARKTPLATZ 5
// AT
// :56C:/9876543210
// :57D:/D/8765432109876543
// CITIBANK N.A.
// 399 PARK AVENUE
// NEW YORK
// US
// :59F:/12345678
// 1/DEPT OF PROMOTION OF SPICY FISH
// 1/CENTER FOR INTERNATIONALISATION
// 3/CN
// :70:/TSU/00000089963-0820-01/ABC-15/256
// 214,
// :71A:SHA
// :71F:USD10,
// :71G:EUR5,50
// :72:/INS/ABNANL2A
// :77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
// -}{5:{CHK:XXXXXXXXXXXX}}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>CITIUS33</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>OCBCSGSG</BICFI></FinInstnId></FIId></To><BizMsgIdr>MSPSDRS/123</BizMsgIdr><MsgDefIdr>pacs.008.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>MSPSDRS/123</MsgId><NbOfTxs>1</NbOfTxs><TtlIntrBkSttlmAmt Ccy="USD">840.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr><AdrLine>NEW YORK BRANCH</AdrLine></PstlAdr></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><Id>1234567890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>FINANZBANK AG</Nm><PstlAdr><AdrLine>EISENSTADT</AdrLine><AdrLine>MARKTPLATZ 5</AdrLine><AdrLine>AT</AdrLine></PstlAdr></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><Id>1234567890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></InstdRmbrsmntAgtAcct><ThrdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>FINANZBANK AG</Nm><PstlAdr><AdrLine>EISENSTADT</AdrLine><AdrLine>MARKTPLATZ 5</AdrLine><AdrLine>AT</AdrLine></PstlAdr></FinInstnId></ThrdRmbrsmntAgt><ThrdRmbrsmntAgtAcct><Id><Othr><Id>1234567890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ThrdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>DEUTDEFFXXX</BICFI><ClrSysMmbId><ClrSysId><Cd>1234567890123456</Cd></ClrSysId><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>OCBCSGSG</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>MSPSDRS/123</InstrId><EndToEndId/><UETR>31df8b48-8845-4fc6-86cd-5586df980e97</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="USD">840.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq><CLSTm>09:15:00+01:00</CLSTm></SttlmTmReq><InstdAmt Ccy="USD">850.00</InstdAmt><XchgRate>0.9236</XchgRate><ChrgBr>SHAR</ChrgBr><ChrgsInf><Amt Ccy="USD">10.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>CRED</Cd></Tp></ChrgsInf><ChrgsInf><Amt Ccy="EUR">5.50</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></PrvsInstgAgt1><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>JOHN DOE</Nm><PstlAdr><AdrLine>123 MAIN STREET</AdrLine><AdrLine>US/NEW YORK</AdrLine><AdrLine>APARTMENT 456</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>NE58NE0380100100130305000268</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>DEUTDEFFXXX</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><Id>1234567890123456</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>CITIBANK N.A.</Nm><PstlAdr><AdrLine>399 PARK AVENUE</AdrLine><AdrLine>NEW YORK</AdrLine><AdrLine>US</AdrLine></PstlAdr></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>DEPT OF PROMOTION OF SPICY FISH CENTER FOR INTERNATIONALISATION</Nm><PstlAdr><Ctry>CN</Ctry></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>12345678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForNxtAgt><Cd>TELI</Cd><InstrInf>3226553478</InstrInf></InstrForNxtAgt><Purp><Prtry>K90</Prtry></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>/TSU/00000089963-0820-01/ABC-15/256
// 214,</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt104ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01BANKBEBBAXXX0000000000}{2:I104BANKDEFFXXXXN}{4:
// :20:REFERENCE12345
// :23E:OTHR
// :30:090921
// :21:REF12444
// :32B:EUR1875,
// :50F:/12345678
// 1/SMITH JOHN
// 2/299, PARK AVENUE
// 3/US/NEW YORK, NY 10017
// :59F:/12345678
// 1/DEPT OF PROMOTION OF SPICY FISH
// 1/CENTER FOR INTERNATIONALISATION
// 3/CN
// :71A:OUR
// :77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
// :21:REF12345
// :32B:EUR1875,
// :50F:/12345678
// 1/SMITH JOHN
// 2/299, PARK AVENUE
// 3/US/NEW YORK, NY 10017
// :59F:/12345678
// 1/DEPT OF PROMOTION OF SPICY FISH
// 1/CENTER FOR INTERNATIONALISATION
// 3/CN
// :71A:OUR
// :77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
// :32B:EUR1875,
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BANKBEBB</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>BANKDEFF</BICFI></FinInstnId></FIId></To><BizMsgIdr>REFERENCE12345</BizMsgIdr><MsgDefIdr>pacs.003.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.11"><FIToFICstmrDrctDbt><GrpHdr><MsgId>REFERENCE12345</MsgId><NbOfTxs>2</NbOfTxs><TtlIntrBkSttlmAmt Ccy="EUR"><content>1875.00</content></TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf><InstgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BANKDEFF</BICFI></FinInstnId></InstdAgt></GrpHdr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12444</EndToEndId><TxId>REF12444</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt Ccy="EUR"><content>1875.00</content></IntrBkSttlmAmt><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><InstdAmt Ccy="EUR"><content>1875.00</content></InstdAmt><ChrgBr>DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId><TxId>REF12345</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt Ccy="EUR"><content>1875.00</content></IntrBkSttlmAmt><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><InstdAmt Ccy="EUR"><content>1875.00</content></InstdAmt><ChrgBr>DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></FIToFICstmrDrctDbt></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt104ToIso20022Xml2() returns error? {
//     string finMessage = string `{1:F01BANKBEBBAXXX0000000000}{2:I104BANKDEFFXXXXN}{4:
// :20:REFERENCE12345
// :23E:RFDD
// :30:090921
// :21:REF12444
// :32B:EUR1875,
// :50F:/12345678
// 1/SMITH JOHN
// 2/299, PARK AVENUE
// 3/US/NEW YORK, NY 10017
// :59F:/12345678
// 1/DEPT OF PROMOTION OF SPICY FISH
// 1/CENTER FOR INTERNATIONALISATION
// 3/CN
// :71A:OUR
// :77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
// :21:REF12345
// :32B:EUR1875,
// :50F:/12345678
// 1/SMITH JOHN
// 2/299, PARK AVENUE
// 3/US/NEW YORK, NY 10017
// :59F:/12345678
// 1/DEPT OF PROMOTION OF SPICY FISH
// 1/CENTER FOR INTERNATIONALISATION
// 3/CN
// :71A:OUR
// :77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
// :32B:EUR1875,
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BANKBEBB</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>BANKDEFF</BICFI></FinInstnId></FIId></To><BizMsgIdr>REFERENCE12345</BizMsgIdr><MsgDefIdr>pain.008.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.11"><CstmrDrctDbtInitn><GrpHdr><MsgId>REFERENCE12345</MsgId><NbOfTxs>2</NbOfTxs><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><FwdgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></FwdgAgt></GrpHdr><PmtInf><PmtInfId>REF12444</PmtInfId><PmtMtd>DD</PmtMtd><PmtTpInf><CtgyPurp><Cd>RFDD</Cd></CtgyPurp></PmtTpInf><ReqdColltnDt>2009-09-21</ReqdColltnDt><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><ChrgBr>DEBT</ChrgBr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12444</EndToEndId></PmtId><InstdAmt Ccy="EUR"><content>1875.00</content></InstdAmt><DrctDbtTx><MndtRltdInf/></DrctDbtTx><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Purp><Prtry/></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></PmtInf><PmtInf><PmtInfId>REF12345</PmtInfId><PmtMtd>DD</PmtMtd><PmtTpInf><CtgyPurp><Cd>RFDD</Cd></CtgyPurp></PmtTpInf><ReqdColltnDt>2009-09-21</ReqdColltnDt><Cdtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><ChrgBr>DEBT</ChrgBr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId></PmtId><InstdAmt Ccy="EUR"><content>1875.00</content></InstdAmt><DrctDbtTx><MndtRltdInf/></DrctDbtTx><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><Dbtr><PstlAdr/><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Purp><Prtry/></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></PmtInf></CstmrDrctDbtInitn></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt200ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01BKAUATWWXXXX0000000000}
// {2:I200CHASUS33XXXXN}
// {4:
// :20:39857579
// :32A:090525USD1000000,
// :53B:/34554-3049
// :56A:CITIUS33
// :57A:CITIUS33MIA
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>CHASUS33</BICFI></FinInstnId></FIId></To><BizMsgIdr>39857579</BizMsgIdr><MsgDefIdr>pacs.009.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>39857579</MsgId><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>CHASUS33</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>39857579</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="USD">1000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-25</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><Id>34554-3049</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>CITIUS33MIA</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt201ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01UBSWCHZH80AXXX0000000000}
// {2:I201ABNANL2AXXXXN}
// {4:
// :19:61000,
// :30:090528
// :20:1234/22
// :32B:EUR5000,
// :57A:INGBNL2A
// :20:1235/22
// :32B:EUR7500,
// :57A:BBSPNL2A
// :20:1227/23
// :32B:EUR12500,
// :57B:ROTTERDAM
// :20:1248/32
// :32B:EUR6000,
// :57A:CRLYFRPP
// :20:1295/22
// :32B:EUR30000,
// :56A:INGBNL2A
// :57A:DEUTDEFF
// :72:/TELE/
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></FIId></To><MsgDefIdr>pacs.009.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><NbOfTxs>5</NbOfTxs><CtrlSum>61000.00</CtrlSum><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>1234/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">5000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1235/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">7500.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>BBSPNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1227/23</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">12500.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr><AdrLine>ROTTERDAM</AdrLine></PstlAdr></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1248/32</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">6000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>CRLYFRPP</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1295/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">30000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>DEUTDEFF</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><InstrForNxtAgt><Cd>TELE</Cd></InstrForNxtAgt></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage), false);
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt202ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01BANKGB2LXXXX0000000000}
// {2:I202BANKJPJTXXXXN}
// {4:
// :20:JPYNOSTRO170105
// :21:CLSINSTR170105
// :13C:/CLSTIME/0700+0100
// :32A:170105JPY5000000,
// :57A:BOJPJPJT
// :58A:CLSBUS33
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BANKGB2L</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>BANKJPJT</BICFI></FinInstnId></FIId></To><BizMsgIdr>JPYNOSTRO170105</BizMsgIdr><MsgDefIdr>pacs.009.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>JPYNOSTRO170105</MsgId><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>BANKGB2L</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BANKJPJT</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>JPYNOSTRO170105</InstrId><EndToEndId>CLSINSTR170105</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="JPY">5000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2017-01-05</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq><CLSTm>07:00:00+01:00</CLSTm></SttlmTmReq><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>BOJPJPJT</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>CLSBUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt202CovToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01AAAABEBBXXXX0000000000}
// {2:I202CCCCUS33XXXX}
// {3:{119:COV}}
// {4:
// :20:090525/124COV
// :21:090525/123COV
// :32A:090527USD10500,00
// :56A:ABFDUS33
// :57A:DDDDUS33
// :58A:BBBBGB22
// :50F:/123564982101
// 1/MR. BIG
// 2/HIGH STREET 3
// 3/BE/BRUSSELS
// :59F:/987654321
// 1/MR. SMALL
// 2/LOW STREET 15
// 3/GB/LONDON
// :70:/INV/1234
// :33B:USD10500,00
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>AAAABEBB</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>CCCCUS33</BICFI></FinInstnId></FIId></To><BizMsgIdr>090525/124COV</BizMsgIdr><MsgDefIdr>pacs.009.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>090525/124COV</MsgId><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>AAAABEBB</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>CCCCUS33</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>090525/124COV</InstrId><EndToEndId>090525/123COV</EndToEndId><TxId>090525/123COV</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="USD">10500.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-27</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><IntrmyAgt1><FinInstnId><BICFI>ABFDUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>DDDDUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>BBBBGB22</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><UndrlygCstmrCdtTrf><Dbtr><Nm>MR. BIG</Nm><PstlAdr><TwnNm>BRUSSELS</TwnNm><Ctry>BE</Ctry><AdrLine>HIGH STREET 3</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>123564982101</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><BICFI>BBBBGB22</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>MR. SMALL</Nm><PstlAdr><TwnNm>LONDON</TwnNm><Ctry>GB</Ctry><AdrLine>LOW STREET 15</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>987654321</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><RmtInf><Ustrd>/INV/1234</Ustrd></RmtInf><InstdAmt Ccy="USD">10500.00</InstdAmt></UndrlygCstmrCdtTrf></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt203ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01UBSWCHZH80A0000000000}
// {2:I203ABNANL2AXXXX}
// {4:
// :19:5000000,
// :30:090528
// :20:2345
// :21:789022
// :32B:EUR500000,
// :57A:INGBNL2A
// :58A:MGTCUS33
// :20:2346
// :21:ABX2270
// :32B:EUR1500000,
// :57A:BBSPNL2A
// :58A:MELNGB2X
// :20:2347
// :21:CO 2750/26
// :32B:EUR1000000,
// :57A:CITINL2X
// :58A:CITIUS33
// :20:2348
// :21:DRESFF2344BKAUWW
// :32B:EUR2000000,
// :58A:DRESDEFF
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></FIId></To><MsgDefIdr>pacs.009.001.11</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><NbOfTxs>4</NbOfTxs><CtrlSum>5000000.00</CtrlSum><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>2345</InstrId><EndToEndId>789022</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">500000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>MGTCUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2346</InstrId><EndToEndId>ABX2270</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1500000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>BBSPNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>MELNGB2X</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2347</InstrId><EndToEndId>CO 2750/26</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>CITINL2X</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2348</InstrId><EndToEndId>DRESFF2344BKAUWW</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">2000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>DRESDEFF</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage), false);
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt204ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01XCMEUS4CXXXX0000000000}
// {2:I204CNORUS44XXXXN}
// {4:
// :20:XCME REF1
// :19:50000,
// :30:090921
// :57A:FNBCUS44
// :20:XCME REF2
// :21:MANDATEREF1
// :32B:USD50000,
// :53A:MLNYUS33
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>XCMEUS4C</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>CNORUS44</BICFI></FinInstnId></FIId></To><BizMsgIdr>XCME REF1</BizMsgIdr><MsgDefIdr>pacs.010.001.06</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.010.001.06"><FIDrctDbt><GrpHdr><MsgId>XCME REF1</MsgId><NbOfTxs>1</NbOfTxs><CtrlSum>50000.00</CtrlSum><InstgAgt><FinInstnId><BICFI>XCMEUS4C</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>CNORUS44</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtInstr><CdtId>XCME REF1</CdtId><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><CdtrAgt><FinInstnId><BICFI>FNBCUS44</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><DrctDbtTxInf><PmtId><InstrId>XCME REF2</InstrId><EndToEndId>MANDATEREF1</EndToEndId></PmtId><IntrBkSttlmAmt Ccy="USD">50000.00</IntrBkSttlmAmt><Dbtr><FinInstnId><BICFI>MLNYUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct></DrctDbtTxInf></CdtInstr></FIDrctDbt></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt210ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01BEBEDEBBXXXX0000000000}
// {2:I210CHASUS33XXXXN}
// {4:
// :20:318393
// :30:100222
// :21:BEBEBB0023CRESZZ
// :32B:USD230000,
// :52A:CRESCHZZ
// :56A:CITIUS33
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>BEBEDEBB</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>CHASUS33</BICFI></FinInstnId></FIId></To><BizMsgIdr>318393</BizMsgIdr><MsgDefIdr>camt.057.001.08</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.057.001.08"><NtfctnToRcv><GrpHdr><MsgId>318393</MsgId></GrpHdr><Ntfctn><Id>318393</Id><Itm><Id>BEBEBB0023CRESZZ</Id><EndToEndId>BEBEBB0023CRESZZ</EndToEndId><Acct><Id><Othr><SchmeNm/></Othr></Id></Acct><Amt Ccy="USD">230000.00</Amt><XpctdValDt>2010-02-22</XpctdValDt><Dbtr><Pty><PstlAdr/><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Pty></Dbtr><DbtrAgt><FinInstnId><BICFI>CRESCHZZ</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><IntrmyAgt><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt></Itm></Ntfctn></NtfctnToRcv></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt900ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01CHASUS33AXXX0000000000}
// {2:I900CRESCHZZXXXXN}
// {4:
// :20:C11126A1378
// :21:5482ABC
// :25:9-9876543
// :32A:090123USD233530,
// :52A://090123543554
// CRESCHZZ
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>CHASUS33</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>CRESCHZZ</BICFI></FinInstnId></FIId></To><BizMsgIdr>C11126A1378</BizMsgIdr><MsgDefIdr>camt054.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.054.001.12"><BkToCstmrDbtCdtNtfctn><GrpHdr><MsgId>C11126A1378</MsgId></GrpHdr><Ntfctn><Id>C11126A1378</Id><Acct><Id><Othr><Id>9-9876543</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id><Ownr><Id><OrgId/></Id></Ownr></Acct><Ntry><Amt Ccy="USD">233530.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts/><BookgDt/><ValDt><Dt>2009-01-23</Dt></ValDt><BkTxCd/><NtryDtls><TxDtls><Refs><InstrId>5482ABC</InstrId><EndToEndId>5482ABC</EndToEndId></Refs><Amt Ccy="USD">233530.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><RltdPties><Dbtr><Agt><FinInstnId><BICFI>CRESCHZZ</BICFI><ClrSysMmbId><ClrSysId><Cd>090123543554</Cd></ClrSysId><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Agt></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct></RltdPties><RltdDts><IntrBkSttlmDt>2009-01-23</IntrBkSttlmDt></RltdDts></TxDtls></NtryDtls></Ntry></Ntfctn></BkToCstmrDbtCdtNtfctn></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt910ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01CHASUS33AXXX0000000000}
// {2:I910ABNANL2AXXXXN}
// {4:
// :20:C11126C9224
// :21:494936/DEV
// :25:6-9412771
// :13D:1401231426+0100
// :32A:140123USD500000,
// :52A:BKAUATWW
// :56A:BKTRUS33
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>CHASUS33</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></FIId></To><BizMsgIdr>C11126C9224</BizMsgIdr><MsgDefIdr>camt054.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.054.001.12"><BkToCstmrDbtCdtNtfctn><GrpHdr><MsgId>C11126C9224</MsgId></GrpHdr><Ntfctn><Id>C11126C9224</Id><Acct><Id><Othr><Id>6-9412771</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id><Ownr><Id><OrgId/></Id></Ownr></Acct><Ntry><Amt Ccy="USD">500000.00</Amt><CdtDbtInd>CRDT</CdtDbtInd><Sts/><BookgDt><DtTm>2014-01-23T14:26:00+01:00</DtTm></BookgDt><ValDt><Dt>2014-01-23</Dt></ValDt><BkTxCd/><NtryDtls><TxDtls><Refs><InstrId>494936/DEV</InstrId><EndToEndId>494936/DEV</EndToEndId></Refs><Amt Ccy="USD">500000.00</Amt><CdtDbtInd>CRDT</CdtDbtInd><RltdPties><Dbtr><Agt><FinInstnId><BICFI>BKAUATWW</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Agt></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct></RltdPties><RltdAgts><IntrmyAgt1><FinInstnId><BICFI>BKTRUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1></RltdAgts><RltdDts><IntrBkSttlmDt>2014-01-23</IntrBkSttlmDt></RltdDts></TxDtls></NtryDtls></Ntry></Ntfctn></BkToCstmrDbtCdtNtfctn></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt920ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01MIDLGB22AXXX0000000000}
// {2:I920UBSWCHZH80AXXXXN}
// {4:
// :20:3948
// :12:942
// :25:123-45678
// :34F:CHFD1000000,
// :34F:CHFC100000,
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>MIDLGB22</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></FIId></To><BizMsgIdr>3948</BizMsgIdr><MsgDefIdr>camt060.001.07</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.060.001.07"><AcctRptgReq><GrpHdr><MsgId>3948</MsgId></GrpHdr><RptgReq><Id>3948</Id><ReqdMsgNmId>942</ReqdMsgNmId><Acct><Id><Othr><Id>123-45678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></Acct><AcctOwnr/><ReqdTxTp><Sts/><CdtDbtInd>DBIT</CdtDbtInd><FlrLmt><Amt Ccy="CHF">1000000.00</Amt><CdtDbtInd>DEBT</CdtDbtInd></FlrLmt><FlrLmt><Amt Ccy="CHF">100000.00</Amt><CdtDbtInd>CRED</CdtDbtInd></FlrLmt></ReqdTxTp></RptgReq></AcctRptgReq></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt940ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01AAAAUS33XXXX0000000000}
// {2:I940PLATUS33XXXXN}
// {4:
// :20:654321
// :25:1234567891
// :28C:851/1
// :60F:C170928USD28000,00
// :61:170929D546232,05S101PLTOL101-56//C11126A1378
// :61:170929C500000,S103987009//8951234
// :86:/ORDP/COMPUTERSYS INC.
// /REMI//INV/78541
// :61:170929D100000,NFEXAAAAUS0369PLATUS//8954321
// :61:170929C200000,NDIVNONREF//8846543
// :86:DIVIDEND LORAL CORP
// PREFERRED STOCK 3TH QUARTER 2017
// :62F:C170929USD81767,95
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>AAAAUS33</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>PLATUS33</BICFI></FinInstnId></FIId></To><BizMsgIdr>654321</BizMsgIdr><MsgDefIdr>camt053.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.12"><BkToCstmrStmt><GrpHdr><MsgId>654321</MsgId></GrpHdr><Stmt><Id>654321</Id><ElctrncSeqNb>1</ElctrncSeqNb><LglSeqNb>851</LglSeqNb><Acct><Id><Othr/></Id><Ownr><Id><OrgId/></Id></Ownr></Acct><Bal><Tp><CdOrPrtry><Cd>OPBD</Cd></CdOrPrtry></Tp><Amt Ccy="USD">28000.00</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2017-09-28</Dt></Dt></Bal><Bal><Tp><CdOrPrtry><Cd>CLBD</Cd></CdOrPrtry></Tp><Amt Ccy="USD">81767.95</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2017-09-29</Dt></Dt></Bal><Ntry><Amt Ccy="">546232.05</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2017-09-29</Dt></ValDt><AcctSvcrRef>C11126A1378</AcctSvcrRef><BkTxCd><Prtry><Cd>S</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>PLTOL101-56</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">500000.00</Amt><CdtDbtInd>CRDT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2017-09-29</Dt></ValDt><AcctSvcrRef>8951234</AcctSvcrRef><BkTxCd><Prtry><Cd>S</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>987009</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">100000.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2017-09-29</Dt></ValDt><AcctSvcrRef>8954321</AcctSvcrRef><BkTxCd><Prtry><Cd>N</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>AAAAUS0369PLATUS</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">200000.00</Amt><CdtDbtInd>CRDT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2017-09-29</Dt></ValDt><AcctSvcrRef>8846543</AcctSvcrRef><BkTxCd><Prtry><Cd>N</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>NONREF</EndToEndId></Refs></TxDtls></NtryDtls></Ntry></Stmt></BkToCstmrStmt></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt941ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01ABNANL2AXXXX0000000000}
// {2:I941UBSWCHZH80AXXXXN}
// {4:
// :20:234567
// :21:765432
// :25:6894-77381
// :28:212
// :13D:0906041515+0200
// :60F:C090604EUR595771,95
// :90D:72EUR385920,
// :90C:44EUR450000,
// :62F:C090604EUR659851,95
// :64:C090604EUR480525,87
// :65:C090605EUR530691,95
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></FIId></To><BizMsgIdr>234567</BizMsgIdr><MsgDefIdr>camt052.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.052.001.12"><BkToCstmrAcctRpt><GrpHdr><MsgId>234567</MsgId></GrpHdr><Rpt><Id>234567</Id><LglSeqNb>212</LglSeqNb><CreDtTm>2009-06-04T15:15:00</CreDtTm><Acct><Id><Othr><Id>6894-77381</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></Acct><Bal><Tp><CdOrPrtry><Cd>OPBD</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">595771.95</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2009-06-04</Dt></Dt></Bal><Bal><Tp><CdOrPrtry><Cd>CLBD</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">659851.95</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2009-06-04</Dt></Dt></Bal><Bal><Tp><CdOrPrtry><Cd>CLAV</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">480525.87</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2009-06-04</Dt></Dt></Bal><Bal><Tp><CdOrPrtry><Cd>FWAV</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">530691.95</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2009-06-05</Dt></Dt></Bal><TxsSummry><TtlNtries/><TtlCdtNtries><NbOfNtries>44</NbOfNtries><Sum>450000.00</Sum></TtlCdtNtries><TtlDbtNtries><NbOfNtries>72</NbOfNtries><Sum>385920.00</Sum></TtlDbtNtries></TxsSummry></Rpt></BkToCstmrAcctRpt></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

// @test:Config {
//     groups: ["toIso20022Xml"]
// }
// isolated function testMt950ToIso20022Xml() returns error? {
//     string finMessage = string `{1:F01ABNANL2AXXXX0000000000}{2:I950UBSWCHZH80AXXXXN}{4:
// :20:123456
// :25:123-456789
// :28C:102
// :60F:C090528EUR3723495,
// :61:090528D1,2FCHG494935/DEV//67914
// :61:090528D30,2NCHK78911//123464
// :61:090528D250,NCHK67822//123460
// :61:090528D450,S103494933/DEV//PO64118
//  FAVOUR K. DESMID
// :61:090528D500,NCHK45633//123456
// :61:090528D1058,47S103494931//3841188 FAVOUR H.F. JANSSEN
// :61:090528D2500,NCHK56728//123457
// :61:090528D3840,S103494935//3841189
//  FAVOUR H.F. JANSSEN
// :61:090528D5000,S20023/200516//47829
//  ORDER ROTTERDAM
// :62F:C090528EUR3709865,13
// -}`; 

//     xml expected = xml `<Envelope><AppHdr xmlns="urn:iso:std:iso:20022:tech:xsd:head.001.001.04"><Fr><FIId><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></FIId></Fr><To><FIId><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></FIId></To><BizMsgIdr>123456</BizMsgIdr><MsgDefIdr>camt053.001.12</MsgDefIdr></AppHdr><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.12"><BkToCstmrStmt><GrpHdr><MsgId>123456</MsgId></GrpHdr><Stmt><Id>123456</Id><LglSeqNb>102</LglSeqNb><Acct><Id><Othr><Id>123-456789</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></Acct><Bal><Tp><CdOrPrtry><Cd>OPBD</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">3723495.00</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2009-05-28</Dt></Dt></Bal><Bal><Tp><CdOrPrtry><Cd>CLBD</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">3709865.13</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2009-05-28</Dt></Dt></Bal><Ntry><Amt Ccy="">1.2</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>67914</AcctSvcrRef><BkTxCd><Prtry><Cd>F</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>494935/DEV</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">30.2</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>123464</AcctSvcrRef><BkTxCd><Prtry><Cd>N</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>78911</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">250.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>123460</AcctSvcrRef><BkTxCd><Prtry><Cd>N</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>67822</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">450.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>PO64118</AcctSvcrRef><BkTxCd><Prtry><Cd>S</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>494933/DEV</EndToEndId></Refs><AddtlTxInf> FAVOUR K. DESMID</AddtlTxInf></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">500.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>123456</AcctSvcrRef><BkTxCd><Prtry><Cd>N</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>45633</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">1058.47</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>3841188 FAVOUR H.F. JANSSEN</AcctSvcrRef><BkTxCd><Prtry><Cd>S</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>494931</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">2500.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>123457</AcctSvcrRef><BkTxCd><Prtry><Cd>N</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>56728</EndToEndId></Refs></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">3840.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>3841189</AcctSvcrRef><BkTxCd><Prtry><Cd>S</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>494935</EndToEndId></Refs><AddtlTxInf> FAVOUR H.F. JANSSEN</AddtlTxInf></TxDtls></NtryDtls></Ntry><Ntry><Amt Ccy="">5000.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><ValDt><Dt>2009-05-28</Dt></ValDt><AcctSvcrRef>47829</AcctSvcrRef><BkTxCd><Prtry><Cd>S</Cd></Prtry></BkTxCd><NtryDtls><TxDtls><Refs><EndToEndId>23/200516</EndToEndId></Refs><AddtlTxInf> ORDER ROTTERDAM</AddtlTxInf></TxDtls></NtryDtls></Ntry></Stmt></BkToCstmrStmt></Document></Envelope>`;
//     xml actual = removeTagsForTest(check toIso20022Xml(finMessage));
//     test:assertEquals(actual.toString(), expected.toString(), msg = "testToIso20022Xml result incorrect");
// }

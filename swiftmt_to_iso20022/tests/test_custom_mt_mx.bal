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

import ballerina/io;
import ballerina/lang.regexp;
import ballerina/test;
import ballerina/time;
import ballerina/xmldata;

@test:Config {
    groups: ["mt_mx"],
    dataProvider: dataProvider_custom
}
isolated function testCustom(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);

    string time = time:utcToString(time:utcNow()).substring(0, 19) + "+00:00";
    json dateFormattedJson = check regexp:replaceAll(re `CURRENT_TIME`, expectedResult.toString(), time).fromJsonString();

    test:assertEquals(actualResult, dateFormattedJson, string `Invalid transformation of MT to MX ${time}`);
}

function dataProvider_custom() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "205_pacs004_with_dummy_ChrgBr": [finMessage_205RETN_pacs004, check io:fileReadXml("./tests/custom/mt205_pacs_004_1.xml")],
        "205_pacs004_with_CHGS_and_reason": [finMessage_205RETN_pacs004_2, check io:fileReadXml("./tests/custom/mt205_pacs_004_2.xml")],
        "205_pacs004_with_CHGS_after_code": [finMessage_205RETN_pacs004_3, check io:fileReadXml("./tests/custom/mt205_pacs_004_3.xml")],
        "205_pacs004_with_CHGS": [finMessage_205RETN_pacs004_4, check io:fileReadXml("./tests/custom/mt205_pacs_004_4.xml")],
        "camt106_muliple1": [finMessage_camt106_multiple_1, check io:fileReadXml("./tests/custom/camt106_multiple1.xml")],
        "205_pacscamt106_muliple2": [finMessage_camt106_multiple_2, check io:fileReadXml("./tests/custom/camt106_multiple2.xml")],
        "103_pacs008_test_pmtTpInf": [finMessage_pacs008_test_pmtTpInf, check io:fileReadXml("./tests/custom/mt103_pacs008.xml")],
        "custom_a_2014": [a_2014, check io:fileReadXml("./tests/custom/mt103_a_2014.xml")],
        "custom_a_2015": [a_2015, check io:fileReadXml("./tests/custom/mt103_a_2015.xml")],
        "custom_a_2016": [a_2016, check io:fileReadXml("./tests/custom/mt103_a_2016.xml")],
        "custom_fin1": [fin1, check io:fileReadXml("./tests/custom/mt103_fin1.xml")],
        "custom_fin2": [fin2, check io:fileReadXml("./tests/custom/mt103_fin2.xml")]
    };
    return dataSet;
}

string finMessage_205RETN_pacs004 = "{1:F01CHASUS33XXXX0000000000}{2:O2050653210511ANBTUS44XXXX00000000002105110653N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4C2B-005\r\n" +
    ":21:E2E040445062713+\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":52A:ANBTUS44XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/B2C0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_205RETN_pacs004_2 = "{1:F01CHASUS33XXXX0000000000}{2:O2050653210511ANBTUS44XXXX00000000002105110653N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4C2B-005\r\n" +
    ":21:E2E040445062713+\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":52A:ANBTUS44XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/RETN/99\r\n" +
    "/CHGS/reason\r\n" +
    "/AC04/\r\n" +
    "/MREF/B2C0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_205RETN_pacs004_3 = "{1:F01CHASUS33XXXX0000000000}{2:O2050653210511ANBTUS44XXXX00000000002105110653N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4C2B-005\r\n" +
    ":21:E2E040445062713+\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":52A:ANBTUS44XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/sd\r\n" +
    "/CHGS/reason\r\n" +
    "/MREF/B2C0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_205RETN_pacs004_4 = "{1:F01CHASUS33XXXX0000000000}{2:O2050653210511ANBTUS44XXXX00000000002105110653N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4C2B-005\r\n" +
    ":21:E2E040445062713+\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":52A:ANBTUS44XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/RETN/99\r\n" +
    "/CHGS/\r\n" +
    "/AC04/sd\r\n" +
    "/MREF/B2C0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_camt106_multiple_1 = "{1:F01CBRLGB2LXXXX0000000000}{2:O1910000991231RBOSGBCHXXXX00000000009912310000N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":32B:GBP30,\r\n" +
    ":52A:CBRLGB2L\r\n" +
    ":71B:/OURC/GBP15,/D\r\n" +
    "/OURC/GBP15,/D\r\n" +
    ":72:/CHRQ/RBOSGBCHXXX\r\n" +
    "-}{5:{CHK:F4A951119A8F}}";

string finMessage_camt106_multiple_2 = "{1:F01CBRLGB2LXXXX0000000000}{2:O1910000991231RBOSGBCHXXXX00000000009912310000N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":32B:RON40,\r\n" +
    ":52A:CBRLGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    "/OURC/RON25,/D\r\n" +
    ":72:/CHRQ/RBOSGBCHXXX\r\n" +
    "-}{5:{CHK:F4A951119A8F}}";

string finMessage_pacs008_test_pmtTpInf = "{1:F01ABCDLKL0XXXX0000000000}{2:I103HANYUS33XXXXN}{3:{111:001}{121:8403c004-66b2-40fc-acba-9f11d1a4ad84}}{4:\r\n" +
    ":20:990OTT250827000\r\n" +
    ":23B:CRED\r\n" +
    ":23E:SDVA\r\n" +
    ":23E:CORT\r\n" +
    ":23E:INTC\r\n" +
    ":32A:250827USD7138,40\r\n" +
    ":33B:USD7138,40\r\n" +
    ":50K:/100811000148\r\n" +
    "RASA ENGINEERING SERVICES (PVT) L\r\n" +
    "NO 852-60\r\n" +
    "SHARUK PURA\r\n" +
    "SRI LANKA\r\n" +
    ":52A:/NAGODA BRANCH\r\n" +
    "ABCDLKLXXXX\r\n" +
    ":57A:SMBCTHBKXXX\r\n" +
    ":59:/2110144802\r\n" +
    "KATAYAMA CHAIN THAILAND\r\n" +
    "CO LTD\r\n" +
    ":70:IMPORT OF ROLLER CHAINS\r\n" +
    "INV NIO : SO2508107SRI\r\n" +
    "INV DATE : 26.08.2025\r\n" +
    ":71A:BEN\r\n" +
    ":72:/SVCLVL/SDVAa\r\n" +
    "/LOCINS/0090\r\n" +
    "-}}";

string a_2014 = "{1:F01ABCDLKLXAXXX0000000000}{2:I103MHCBJPJTXXXXN}{3:{121:09797101-a670-4e81-98ed-34b409736402}}{4:\r\n" +
    ":20:990OTT250922014\r\n" +
    ":23B:CRED\r\n" +
    ":32A:250922JPY100,\r\n" +
    ":33B:JPY100,\r\n" +
    ":50K:/100811000148\r\n" +
    "RASA ENGINEERING SERVICES (PVT) L\r\n" +
    "NO 852-60\r\n" +
    "SHARUK PURA\r\n" +
    "SRI LANKA\r\n" +
    ":52A:/CGC BRANHC\r\n" +
    "ABCDLKLXXXX\r\n" +
    ":57A:ICBKCNBJZJP\r\n" +
    ":59:/2563529\r\n" +
    "SHASHU LANXI SHANYE\r\n" +
    "MACHINERY CO LTD\r\n" +
    "MACHINERY CO LTD\r\n" +
    ":70:IMPORT OF GOOD\r\n" +
    "INV NO : 1526395\r\n" +
    "INV DATE : 10.10.2025\r\n" +
    "LKMIOP\r\n" +
    ":71A:BEN\r\n" +
    ":72:/INS/JKKILKOKSIKF\r\n" +
    "-}";

string a_2015 = "{1:F01AABSLKLXAXXX0000000000}{2:I103HANYUS33XXXXN}{3:{121:09797101-a670-4e81-98ed-34b409736400}}{4:\r\n" +
    ":20:990OTT250922015\r\n" +
    ":23B:CRED\r\n" +
    ":32A:250922USD100,\r\n" +
    ":33B:USD100,\r\n" +
    ":50K:/100811000148\r\n" +
    "RASA ENGINEERING SERVICES (PVT) L\r\n" +
    "NO 852-60\r\n" +
    "SHARUK PURA\r\n" +
    "SRI LANKA\r\n" +
    ":52A:/NAGODA BRANCH\r\n" +
    "AABSLKLXXXX\r\n" +
    ":57A:ICBKCNBJZJP\r\n" +
    ":59:/15236859635\r\n" +
    "ZHEJIANG LANXI SHANYE\r\n" +
    "ZHEJIANG LANXI SHANYE\r\n" +
    "ZHEJIANG LANXI SHANYE\r\n" +
    ":70:IMPORT OF GOOD\r\n" +
    "INV NO :14255639\r\n" +
    "INV DATE : 24225236589\r\n" +
    "PURPOSE CODE : GDI\r\n" +
    ":71A:OUR\r\n" +
    ":72:/INS/NHMJKIIIIJMKIOLLPOUJI\r\n" +
    "/INS/NHMJKIIIIJMKIOLLPOUJI\r\n" +
    "/INS/NHMJKIIIIJMKIOLLPOUJI\r\n" +
    "-}";

string a_2016 = "{1:F01AABSLKLXAXXX0000000000}{2:I103HANYUS33XXXXN}{3:{121:09797101-a670-4e81-98ed-34b409736401}}{4:\r\n" +
    ":20:990OTT250922016\r\n" +
    ":23B:CRED\r\n" +
    ":32A:250922USD100,\r\n" +
    ":33B:USD100,\r\n" +
    ":50K:/100811000148\r\n" +
    "UNITED ENGINEERING SERVICES (PVT) L\r\n" +
    "NO 852-60\r\n" +
    "SUSITHA PURA\r\n" +
    "SRI LANKA\r\n" +
    ":52A:/CGC BRANHC\r\n" +
    "AABSLKLXXXX\r\n" +
    ":57A:ICBKCNBJZJP\r\n" +
    ":59:/256352896\r\n" +
    "XZHEJIANG LANXI SHANYE\r\n" +
    "XZHEJIANG LANXI SHANYE\r\n" +
    "XZHEJIANG LANXI SHANYE\r\n" +
    ":70:IMPORT OF GOOD\r\n" +
    "INV NO : 1523659\r\n" +
    "INV DATE : 10.10.2025\r\n" +
    "GDI PURPOSE\r\n" +
    ":71A:OUR\r\n" +
    ":72:/INS/HUJIKKOLOOOIWHUJDI\r\n" +
    "-}";

string fin1 = "{1:ABCDLKLXXXXX0000000000}{2:I202BCEYIN5MXXXXN}{3:{121:09797101-a670-4e81-98ed-34b409736510}}{4:\r\n" +
    ":20:IBPPAB049250002\r\n" +
    ":21:C-123-456\r\n" +
    ":32A:250924USD100,\r\n" +
    ":56A:/123\r\n" +
    "BOTKJPJT\r\n" +
    ":57A:CITIUS33XXX\r\n" +
    ":58D:/MUFG LTD/\r\n" +
    "INTERNATIONAL BANKING DEPARTME\r\n" +
    "FEDERAL TOWERS MARINE DRIVE\r\n" +
    "ERNAKULAM 682031\r\n" +
    ":72:/INS/BILL PROCEEDS\r\n" +
    "-}";

string fin2 = "{1:F01AABSLKLXAXXX0000000000}{2:I103HANYUS33XXXXN}{3:{121:09797101-a670-4e81-98ed-34b409736305}}{4:\r\n" +
    ":20:925OTT250922015\r\n" +
    ":23B:CRED\r\n" +
    ":32A:250922USD700,\r\n" +
    ":33B:USD700,\r\n" +
    ":50K:/100611002421\r\n" +
    "OPTIMA TECHNOLOGIES (PVT) LTD\r\n" +
    "NO 740 COTTA ROAD\r\n" +
    "SRI LANKA\r\n" +
    ":52A:/KOL BRANCH\r\n" +
    "AABSLKLXXXX\r\n" +
    ":56A:/123456\r\n" +
    "CITIUS33XXX\r\n" +
    ":57D:/KOL BRANCH\r\n" +
    "COMMERCIAL BANK\r\n" +
    "GALLE RD COLOMBO 03\r\n" +
    ":59:/LK123456\r\n" +
    "LNM\r\n" +
    "NO450\r\n" +
    "GALLE RD COLOMBO 03 SL\r\n" +
    "123456\r\n" +
    ":70:TEST\r\n" +
    "123\r\n" +
    "456\r\n" +
    "789\r\n" +
    ":71A:OUR\r\n" +
    ":72:/INS/FUL PAY\r\n" +
    "/INS/CHGS\r\n" +
    "/INS/PAY\r\n" +
    "-}";

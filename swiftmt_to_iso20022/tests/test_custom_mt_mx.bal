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
import ballerina/test;
import ballerina/xmldata;

@test:Config {
    groups: ["mt_mx"],
    dataProvider: dataProvider_custom
}
isolated function testCustom(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_custom() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "205_pacs004_with_dummy_ChrgBr": [finMessage_205RETN_pacs004, check io:fileReadXml("./tests/custom/mt205_pacs_004_1.xml")],
        "205_pacs004_with_CHGS_and_reason": [finMessage_205RETN_pacs004_2, check io:fileReadXml("./tests/custom/mt205_pacs_004_2.xml")],
        "205_pacs004_with_CHGS_after_code": [finMessage_205RETN_pacs004_3, check io:fileReadXml("./tests/custom/mt205_pacs_004_3.xml")],
        "205_pacs004_with_CHGS": [finMessage_205RETN_pacs004_4, check io:fileReadXml("./tests/custom/mt205_pacs_004_4.xml")],
        "camt106_muliple1": [finMessage_camt106_multiple_1, check io:fileReadXml("./tests/custom/camt106_multiple1.xml")],
        "205_pacscamt106_muliple2": [finMessage_camt106_multiple_2, check io:fileReadXml("./tests/custom/camt106_multiple2.xml")]
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

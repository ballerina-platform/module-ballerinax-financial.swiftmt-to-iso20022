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
    dataProvider: dataProvider_mt204
}
isolated function testMt204ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt204() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "pc_10_1_1_pacs010_A_B_111": [finMessage_01011_mt204_A_B, check io:fileReadXml("./tests/pc_10_1_1/mt204_pacs_010_A_B.xml")],
        "pc_10_1_1_pacs010_C_D_111": [finMessage_01011_mt204_C_D, check io:fileReadXml("./tests/pc_10_1_1/mt204_pacs_010_C_D.xml")],
        "pc_10_1_1_pacs010_E_F_111": [finMessage_01011_mt204_E_F, check io:fileReadXml("./tests/pc_10_1_1/mt204_pacs_010_E_F.xml")]
    };
    return dataSet;
}

string finMessage_01011_mt204_A_B = "{1:F01RBOSGB2LXXXX0000000000}{2:O2040815221020NDEAFIHHXXXX00000000002210200815N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:XCME REF1\r\n" +
    ":19:50000,\r\n" +
    ":30:090921\r\n" +
    ":58A:/1234-ABC\r\n" +
    "XCMEUS4C\r\n" +
    ":20:XCME REF2\r\n" +
    ":21:MANDATEREF1\r\n" +
    ":32B:USD50000,\r\n" +
    ":53A:MLNYUS33\r\n" +
    "-}";

string finMessage_01011_mt204_C_D = "{1:F01RBOSGB2LXXXX0000000000}{2:O2040815221020NDEAFIHHXXXX00000000002210200815N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:XCME REF1\r\n" +
    ":19:50000,\r\n" +
    ":30:090921\r\n" +
    ":57A:FNBCUS44\r\n" +
    ":20:XCME REF2\r\n" +
    ":21:MANDATEREF1\r\n" +
    ":32B:USD50000,\r\n" +
    ":53A:MLNYUS33\r\n" +
    "-}";

string finMessage_01011_mt204_E_F = "{1:F01BOFSGB2LXXXX0000000000}{2:O2040825221020NDEADKK2XXXX00000000002210200825N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:CDT-101\r\n" +
    ":19:350000,\r\n" +
    ":30:221020\r\n" +
    ":57A:BANODKKK\r\n" +
    ":58A:/65479512\r\n" +
    "NDEADKK2XXX\r\n" +
    ":20:pcs010bizmsgidr1\r\n" +
    ":21:MANDATE123456\r\n" +
    ":32B:DKK350000,\r\n" +
    ":53A:/25698745\r\n" +
    "CLYDGB2S\r\n" +
    "-}";

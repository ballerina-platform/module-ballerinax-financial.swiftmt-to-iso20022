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
    dataProvider: dataProvider_p231a
}
isolated function testP231a(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p231a() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "202_pasc004": [finMessage_p_2_3_1_a_B_A, check io:fileReadXml("./tests/p_2_3_1_a/mt202_pacs_004_B_A.xml")],
        "103_pasc008": [finMessage_p_2_3_1_a_A_D, check io:fileReadXml("./tests/p_2_3_1_a/mt103_pacs_008_A_D.xml")]
    };
    return dataSet;
};

string finMessage_p_2_3_1_a_B_A = "{1:F01CLYDGB2SXXXX0000000000}{2:O2020820221020BOFSGB2LXXXX00000000002210200820N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs004bizmsgid+\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CAIXESBB\r\n" +
    ":57A:BOFSGB2L\r\n" +
    ":58A:CLYDGB2S\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr01\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "-}";

string finMessage_p_2_3_1_a_A_D = "{1:F01CAIXESBBXXXX0000000000}{2:O1030925221020CLYDGB2SXXXX00000000002210200925N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pcs008bzmsgidr-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":33B:EUR65784,32\r\n" +
    ":50F:/25698745\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":53A:BOFSGB2L\r\n" +
    ":54A:BSCHESMM\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":59F:/65479512\r\n" +
    "1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

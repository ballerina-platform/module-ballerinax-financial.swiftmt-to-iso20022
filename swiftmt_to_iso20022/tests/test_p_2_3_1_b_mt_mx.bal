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
    dataProvider: dataProvider_p231b
}
isolated function testP231b(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p231b() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "202_pasc004": [finMessage_p_2_3_1_b_C_B, check io:fileReadXml("./tests/p_2_3_1_b/mt202_pacs004_C_B.xml")],
        "103_pasc008": [finMessage_p_2_3_1_b_A_D, check io:fileReadXml("./tests/p_2_3_1_b/mt103_pacs_008_A_D.xml")],
        "202_pasc009cov": [finMessage_p_2_3_1_b_A_B, check io:fileReadXml("./tests/p_2_3_1_b/mt202_pacs_009COV_A_B.xml")]
    };
    return dataSet;
};

string finMessage_p_2_3_1_b_C_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O2020920221020BSCHESMMXXXX00000000002210200920N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CAIXESBB\r\n" +
    ":57A:BOFSGB2L\r\n" +
    ":58A:CLYDGB2S\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr02\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "-}";

string finMessage_p_2_3_1_b_A_D = "{1:F01BSCHGB2LXXXX0000000000}{2:O1030925221020CLYDGB2SXXXX00000000002210200925N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pcs008bzmsgidr-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020DKK591636,\r\n" +
    ":33B:DKK591636,\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping London\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":53A:BOFSGB2L\r\n" +
    ":54A:BSCHESMM\r\n" +
    ":57A:BSCHGB2L\r\n" +
    ":59F:1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";
    
string finMessage_p_2_3_1_b_A_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O2020925221020CLYDGB2SXXXX00000000002210200925N}{3:{119:COV}{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020DKK591636,\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping London\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHGB2L\r\n" +
    ":59F:1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";

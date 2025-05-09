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
    dataProvider: dataProvider_p321b
}
isolated function testP321b(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p321b() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "299_pasc002": [finMessage_p_3_2_1_b_D_A, check io:fileReadXml("./tests/p_3_2_1_b/mt199_pacs_002_D_A.xml")]
    };
    return dataSet;
};

string finMessage_p_3_2_1_b_D_A = "{1:F01CLYDGB2SXXXX0000000000}{2:O1990835221020BSCHGB2LXXXX00000000002210200835N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":79:/REJT/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pcs008bzmsgidr-1\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "/TEXT//UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    "-}";

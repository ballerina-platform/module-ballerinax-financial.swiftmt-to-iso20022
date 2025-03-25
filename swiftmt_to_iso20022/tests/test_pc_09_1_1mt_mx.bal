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
    dataProvider: dataProvider_mt200
}
isolated function testMt200ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt200() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "pc_09_1_1_pacs009_A_B_111": [finMessage_00911_mt200_A_B, check io:fileReadXml("./tests/pc_09_1_1/mt200_pacs_009_A_B.xml")],
        "pc_09_1_1_pacs009_C_D_111": [finMessage_00911_mt200_C_D, check io:fileReadXml("./tests/pc_09_1_1/mt200_pacs_009_C_D.xml")]
    };
    return dataSet;
}

string finMessage_00911_mt200_A_B = "{1:F01RBOSGB2LXXXX0000000000}{2:O2000815221020NDEAFIHHXXXX00000000002210200815N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:23/200516DEV\r\n" +
    ":32A:090525EUR1000000,\r\n" +
    ":57A:INGBNL2A\r\n" +
    "-}";

string finMessage_00911_mt200_C_D = "{1:F01RBOSGB2LXXXX0000000000}{2:O2000815221020NDEAFIHHXXXX00000000002210200815N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:39857579\r\n" +
    ":32A:090525USD1000000,\r\n" +
    ":53B:/34554-3049\r\n" +
    ":56A:CITIUS33\r\n" +
    ":57A:CITIUS33MIA\r\n" +
    "-}";

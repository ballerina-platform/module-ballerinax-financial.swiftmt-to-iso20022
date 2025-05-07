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
    dataProvider: dataProvider_mt107
}
isolated function testMt107ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt107() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "pc_03_1_1_pacs003_A_B_111": [finMessage_00311_mt107_A_B, check io:fileReadXml("./tests/pc_03_1_1/mt107_pacs_003_A_B.xml")]
    };
    return dataSet;
}

string finMessage_00311_mt107_A_B = "{1:F01RBOSGB2LXXXX0000000000}{2:O1070815221020NDEAFIHHXXXX00000000002210200815N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pc003bzmsgidr01\r\n" +
    ":23E:AUTH\r\n" +
    ":30:221025\r\n" +
    ":50K:/65479512\r\n" +
    "OP Corporate Bank\r\n" +
    "Aleksanterinkatu 19\r\n" +
    "FI/Helsinki\r\n" +
    ":52A:NDEAFIHH\r\n" +
    ":71A:OUR\r\n" +
    ":21:pain008EndToEnd+\r\n" +
    ":21C:MNDTE258963\r\n" +
    ":32B:EUR45250,\r\n" +
    ":57A:RBOSGB2L\r\n" +
    ":59:/25698745\r\n" +
    "NT Asset Management\r\n" +
    "50 Bank Street\r\n" +
    "GB/London\r\n" +
    ":33B:EUR45250,\r\n" +
    ":32B:EUR45250,\r\n" +
    "-}";

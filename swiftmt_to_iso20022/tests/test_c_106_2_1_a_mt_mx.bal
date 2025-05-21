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
    dataProvider: dataProvider_C10621a
}
isolated function testC10621a(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_C10621a() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "mt202_pacs009": [finMessage_10621a_B_A, check io:fileReadXml("./tests/c_106_2_1_a/mt202_pacs_009_B_A.xml")]
    };
    return dataSet;
}

string finMessage_10621a_B_A = "{1:F01RZBRROBUXXXX0000000000}{2:O2020945221020INGBROBUXXXX00000000002210200945N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f002}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:camt106chrgid1\r\n" +
    ":32A:221020RON15,\r\n" +
    ":52A:INGBROBUXXX\r\n" +
    ":58A:RZBRROBUXXX\r\n" +
    "-}";

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
    dataProvider: dataProvider_p912b
}
isolated function testP912b(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p912b() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "202_pacs009adv": [finMessage_p_9_1_2_b, check io:fileReadXml("./tests/p_9_1_2_b/mt202_pacs_009ADV.xml")]
    };
    return dataSet;
};

string finMessage_p_9_1_2_b = "{1:F01DEUTDEFFXXXX0000000000}{2:O2021400210427TDOMUS33XXXX00000000002104271400N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs009EndToEnd+\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52A:CWBKCA61\r\n" +
    ":53A:TDOMCATT\r\n" +
    ":54A:DEUTCATT\r\n" +
    ":57A:DEUTDEFF\r\n" +
    ":58A:DEUTITMM\r\n" +
    ":72:/INS/TDOMUS33\r\n" +
    "-}";

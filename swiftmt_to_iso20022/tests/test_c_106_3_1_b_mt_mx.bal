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
    dataProvider: dataProvider_c10631b
}
isolated function testc10631b(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_c10631b() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_106_3_1_b_camt106_C_B_191": [finMessage_c10631b_C_B, check io:fileReadXml("./tests/c_106_3_1_b/mt191_camt_106_C_B.xml")]
    };
    return dataSet;
}

string finMessage_c10631b_C_B = "{1:F01INGBROBUXXXX0000000000}{2:O1911020221020RZBRROBUXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pcs008bzmsgid-2\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/GEBABEBBXXX\r\n" +
    "-}";

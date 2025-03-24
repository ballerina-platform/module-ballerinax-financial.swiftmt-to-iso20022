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
    dataProvider: dataProvider_mt900
}
isolated function testMt900ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt900() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_54_1_1_camt054_A_B_900": [finMessage_5411_mt900_A_B, check io:fileReadXml("./tests/c_54_1_1/mt900_camt_054_A_B.xml")],
        "c_54_1_1_camt054_C_D_910": [finMessage_5411_mt910_C_D, check io:fileReadXml("./tests/c_54_1_1/mt910_camt_054_C_D.xml")]};
    return dataSet;
}

string finMessage_5411_mt900_A_B = "{1:F01YOURBANKXXXX0000000000}{2:O9000725221020INGBROBUXXXX00000000002210200725N}{4:\r\n" +
":20:C11126A1378\r\n" +
":21:5482ABC\r\n" +
":25:9-9876543\r\n" +
":32A:090123USD233530,\r\n" +
"-}";

string finMessage_5411_mt910_C_D = "{1:F01YOURBANKXXXX0000000000}{2:O9100725221020INGBROBUXXXX00000000002210200725N}{4:\r\n" +
":20:C11126C9224\r\n" +
":21:494936/DEV\r\n" +
":25:6-9412771\r\n" +
":13D:1401231426+0100\r\n" +
":32A:140123USD500000,\r\n" +
":52A:BKAUATWW\r\n" +
":56A:BKTRUS33\r\n" +
"-}";

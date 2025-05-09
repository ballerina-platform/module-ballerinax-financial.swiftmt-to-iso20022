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
    dataProvider: dataProvider_C5811
}
isolated function testC5811(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_C5811() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "mt210_camt057": [finMessage_5811_A_B, check io:fileReadXml("./tests/c_58_1_1/mt210_camt_057_A_B.xml")]
    };
    return dataSet;
}

string finMessage_5811_A_B = "{1:F01NDEAFIHHXXXX0000000000}{2:O2100925221020OKOYFIHHXXXX00000000002210200925N}{4:\r\n" +
    ":20:cmt057bizmsgidr\r\n" +
    ":25:25698745\r\n" +
    ":30:221025\r\n" +
    ":21:ITM-021\r\n" +
    ":32B:EUR125650,\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/NT Asset Management\r\n" +
    "2/50 Bank Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:CITIGB2L\r\n" +
    "-}";
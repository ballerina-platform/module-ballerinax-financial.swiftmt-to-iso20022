// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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
    dataProvider: dataProvider_mt111
}
isolated function testMt111ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}


function dataProvider_mt111() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_108_1_1_camt108_A_B_111" : [finMessage_10811_mt111_A_B, check io:fileReadXml("./tests/c_108_1_1/mt111_camt_108_A_B.xml")]
    };
    return dataSet;
}

string finMessage_10811_mt111_A_B = "{1:F01RBSSGBKCXXXX0000000000}{2:O1111005221020MYMBGB2LXXXX00000000002210201005N}{4:\r\n" +
    ":20:camt108bzmsgidr1\r\n" +
    ":21:102145\r\n" +
    ":30:221020\r\n" +
    ":32B:GBP25250,\r\n" +
    ":59:1/Ardent Finance\r\n" +
    "2/Main Street\r\n" +
    "3/GB/London\r\n" +
    ":75:/RequestedByCustomer/\r\n" +
    "-}";

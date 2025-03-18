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
    dataProvider: dataProvider_mt110
}
isolated function testMt110ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt110() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_107_1_1_camt107_A_B_110": [finMessage_10711_mt110_A_B, check io:fileReadXml("./tests/c_107_1_1/mt110_camt_107_A_B.xml")]
    };
    return dataSet;
}

string finMessage_10711_mt110_A_B = "{1:F01RBSSGBKCXXXX0000000000}{2:O1100905221020MYMBGB2LXXXX00000000002210200905N}{4:\r\n" +
    ":20:camt107bzmsgidr1\r\n" +
    ":21:102145\r\n" +
    ":30:221020\r\n" +
    ":32B:GBP25250,\r\n" +
    ":50F:/60779854\r\n" +
    "1/Debtor Co\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":59F:1/Ardent Finance\r\n" +
    "2/Main Street\r\n" +
    "3/GB/London\r\n" +
    "-}";

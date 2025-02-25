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
    dataProvider: dataProvider_mt942
}
isolated function testMt942ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}


function dataProvider_mt942() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_52_1_1_camt052_A_B_942" : [finMessage_5211_mt942_A_B, check io:fileReadXml("./tests/c_52_1_1/mt942_camt_052_A_B.xml")],
        "c_52_1_1_camt052_C_D_942" : [finMessage_5211_mt942_C_D, check io:fileReadXml("./tests/c_52_1_1/mt942_camt_052_C_D.xml")]
    };
    return dataSet;
}

string finMessage_5211_mt942_A_B = "{1:F01AZSEDEMMXXXX0000000000}{2:O9421100201124DEUTDEFFXXXX00000000002011241100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:DE8547812\r\n" +
    ":28C:10001/3\r\n" +
    ":34F:EUR0,\r\n" +
    ":13D:2011241100+0100\r\n" +
    ":61:201124C750000,NTRFpacs008EndToEnd\r\n" +
    "-}";

string finMessage_5211_mt942_C_D = "{1:F01VEBHIT2MXXXX0000000000}{2:O9421100201215MEDBITMMXXXX00000000002012151100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:48751258\r\n" +
    ":28C:50010/1\r\n" +
    ":34F:EUR0,\r\n" +
    ":13D:2012151100+0000\r\n" +
    ":61:201215C1000000,NTRFpacs008EndToEnd\r\n" +
    "-}";

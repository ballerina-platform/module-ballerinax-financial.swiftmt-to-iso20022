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
    dataProvider: dataProvider_mt920
}
isolated function testMt920ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt920() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_60_1_1_camt060_A_B_920": [finMessage_6011_mt920_A_B, check io:fileReadXml("./tests/c_60_1_1/mt920_camt_060_A_B.xml")]};
    return dataSet;
}

string finMessage_6011_mt920_A_B = "{1:F01ABNANL2AXXXX0000000000}{2:O9200725221020INGBROBUXXXX00000000002210200725N}{4:\r\n" +
":20:3948\r\n" +
":12:942\r\n" +
":25:123-45678\r\n" +
":34F:CHFD1000000,\r\n" +
":34F:CHFC100000,\r\n" +
"-}";

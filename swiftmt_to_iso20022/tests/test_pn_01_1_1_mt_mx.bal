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
    dataProvider: dataProvider_mt101
}
isolated function testMt101ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt101() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "pn_01_1_1_pain001_A_B_111": [finMessage_00111_mt101_A_B, check io:fileReadXml("./tests/pn_01_1_1/mt101_pain_001_A_B.xml")]
    };
    return dataSet;
}

string finMessage_00111_mt101_A_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O1010825221020NDEADKK2XXXX00000000002210200825N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:11FF99RR\r\n" +
    ":28D:1/1\r\n" +
    ":30:090327\r\n" +
    ":21:REF501\r\n" +
    ":21F:UKNOWIT1234\r\n" +
    ":32B:USD90000,\r\n" +
    ":50F:/9020123100\r\n" +
    "1/FINPETROL INC.\r\n" +
    "2/ANDRELAE SPINKATU 7\r\n" +
    "3/FI/HELSINKI\r\n" +
    ":57C://CP999\r\n" +
    ":59F:/756-857489-21\r\n" +
    "1/SOFTEASE PC GRAPHICS\r\n" +
    "2/34 BRENTWOOD ROAD\r\n" +
    "3/US/SEAFORD, NEW YORK, 11246\r\n" +
    ":70:/INV/19S95\r\n" +
    ":77B:/BENEFRES/US\r\n" +
    "//34 BRENTWOOD ROAD\r\n" +
    "//SEAFORD, NEW YORK 11246\r\n" +
    ":33B:EUR100000,\r\n" +
    ":71A:SHA\r\n" +
    ":25A:/9101000123\r\n" +
    ":36:0,90\r\n" +
    "-}";

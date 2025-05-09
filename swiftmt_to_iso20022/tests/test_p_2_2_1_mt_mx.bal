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
    dataProvider: dataProvider_p221
}
isolated function testP221(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p221() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "299_pasc002": [finMessage_p_2_2_1_D_C, check io:fileReadXml("./tests/p_2_2_1/mt299_pacs_002_D_C.xml")],
        "202_pasc009_B_C": [finMessage_p_2_2_1_B_C, check io:fileReadXml("./tests/p_2_2_1/mt202_pacs_009_B_C.xml")]
    };
    return dataSet;
};

string finMessage_p_2_2_1_D_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O2991113200803HELSFIHHXXXX00000000002008031113N}{3:{121:dab3b64f-092b-4839-b7e9-8f438af50961}}{4:\r\n" +
    ":20:pacs2bizmsgidr01\r\n" +
    ":21:pacs9bizmsgidr02\r\n" +
    ":79:/REJT/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr02\r\n" +
    "/TREF/pacs009EndToEnd+\r\n" +
    "/TEXT//UETR/dab3b64f-092b-4839-b7e9-8f438af50961\r\n" +
    "-}";

string finMessage_p_2_2_1_B_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O2021013200803ABNANL2AXXXX00000000002008031013N}{3:{121:dab3b64f-092b-4839-b7e9-8f438af50961}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs009EndToEnd+\r\n" +
    ":32A:200803EUR654489,98\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":57A:HELSFIHHXXX\r\n" +
    ":58A:EVSEFIHHXXX\r\n" +
    ":72:/INS/ABNANL2AXXX\r\n" +
    "/BNF/Invoice: 456464-9663\r\n" +
    "-}";

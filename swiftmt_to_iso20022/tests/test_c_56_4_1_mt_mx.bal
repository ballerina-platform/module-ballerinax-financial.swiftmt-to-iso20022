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
    dataProvider: dataProvider_C5641
}
isolated function testC5641(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_C5641() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "mt202_pacs009": [finMessage_5641_B_C, check io:fileReadXml("./tests/c_56_4_1/mt202-pacs009_B_C.xml")],
        "mt296_camt029_E_B": [finMessage_5641_E_B, check io:fileReadXml("./tests/c_56_4_1/mt296_camt_029_E_B.xml")],
        "mt292_camt056_B_E": [finMessage_5641_B_E, check io:fileReadXml("./tests/c_56_4_1/mt292_camt056_B_E.xml")]
    };
    return dataSet;
}

string finMessage_5641_B_C = "{1:F01TDOMCATTXXXX0000000000}{2:O2021415210427TDOMUS33XXXX00000000002104271415N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52A:TDOMUS33\r\n" +
    ":57A:ROYCCAT2\r\n" +
    ":58A:NWBKGB2L\r\n" +
    ":72:/UDLC/RBOSGB2L\r\n" +
    "/INS/TDOMCATT\r\n" +
    "-}";

string finMessage_5641_E_B = "{1:F01TDOMUS33XXXX0000000000}{2:O2962010210427NWBKGB2LXXXX00000000002104272010N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:CNCL-ID001\r\n" +
    ":21:CSE-001\r\n" +
    ":76:/PDCR/\r\n" +
    ":77A:/UETR/7a562c67-ca16-48ba-b074-65581\r\n" +
    "//be6f001\r\n" +
    ":11R:202\r\n" +
    "210427\r\n" +
    "-}";

string finMessage_5641_B_E = "{1:F01NWBKGB2LXXXX0000000000}{2:O2921515210427TDOMUS33XXXX00000000002104271515N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:CSE-001\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":11S:202\r\n" +
    "210427\r\n" +
    ":79:/AM09/\r\n" +
    "/UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    "-}";

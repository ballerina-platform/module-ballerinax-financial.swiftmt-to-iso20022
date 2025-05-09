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
    dataProvider: dataProvider_c2941
}
isolated function testc2941(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_c2941() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "202_pacs009adv": [finMessage_c2941_B_E, check io:fileReadXml("./tests/c_29_4_1/mt202_pacs_009ADV_B_E.xml")],
        "292_camt056": [finMessage_c2941_B_E_camt, check io:fileReadXml("./tests/c_29_4_1/mt292_camt_056_B_E.xml")]
    };
    return dataSet;
}

string finMessage_c2941_B_E = "{1:F01NWBKGB2LXXXX0000000000}{2:O2021415210427TDOMUS33XXXX00000000002104271415N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs9AdvEndToEn+\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52A:HKBCCATTCLS\r\n" +
    ":53A:TDOMCATT\r\n" +
    ":54A:ROYCCAT2\r\n" +
    ":57A:NWBKGB2L\r\n" +
    ":58A:RBOSGB2L\r\n" +
    ":72:/INS/TDOMUS33\r\n" +
    "-}";

string finMessage_c2941_B_E_camt = "{1:F01NWBKGB2LXXXX0000000000}{2:O2921515210427TDOMUS33XXXX00000000002104271515N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:CSE-001\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":11S:202\r\n" +
    "210427\r\n" +
    ":79:/CUST/\r\n" +
    "/UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    "-}";

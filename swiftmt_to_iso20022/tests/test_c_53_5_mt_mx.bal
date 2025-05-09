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
    dataProvider: dataProvider_C535
}
isolated function testC535(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_C535() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "mt103_pacs008": [finMessage_535_A_B, check io:fileReadXml("./tests/c_53_5/mt103_pacs008_A_B.xml")]
    };
    return dataSet;
}

string finMessage_535_A_B = "{1:F01DBSSSGSGXXXX0000000000}{2:O1030905200805WPACAU2SXXXX00000000002008050905N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:pacs8bizmsgidr01\r\n" +
    ":23B:CRED\r\n" +
    ":32A:200805SGD500000,\r\n" +
    ":50F:/458756241\r\n" +
    "1/Australian Submarine\r\n" +
    "2/694 Mersey Rd\r\n" +
    "3/AU/Adelaide\r\n" +
    ":52A:WPACAU2S\r\n" +
    ":56A:DBSSSGSG\r\n" +
    ":57A:UOVBSGSG\r\n" +
    ":59F:/985412687\r\n" +
    "1/Agoda Company\r\n" +
    "2/30 Cecil Street\r\n" +
    "3/SG/Singapore\r\n" +
    ":70:/ROC/E2E04044506271305\r\n" +
    ":71A:OUR\r\n" +
    "-}";

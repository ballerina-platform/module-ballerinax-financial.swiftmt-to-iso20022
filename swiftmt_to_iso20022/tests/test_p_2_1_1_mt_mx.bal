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
    dataProvider: dataProvider_p211
}
isolated function testP211(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p211() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "103_pasc008": [finMessage_p_2_1_1_C_D, check io:fileReadXml("./tests/p_2_1_1/mt103_pacs_008_C_D.xml")]
    };
    return dataSet;
};

string finMessage_p_2_1_1_C_D = "{1:F01HELSFIHHXXXX0000000000}{2:O1030720210409NDEAFIHHXXXX00000000002104090720N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs8bizmsgidr03\r\n" +
    ":23B:CRED\r\n" +
    ":32A:210409EUR15669,38\r\n" +
    ":33B:EUR15669,38\r\n" +
    ":50F:/12547896\r\n" +
    "1/C Consumer\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":57A:HELSFIHHXXX\r\n" +
    ":59F:/98653214\r\n" +
    "1/Evli\r\n" +
    "2/Aleksanterinkatu 19\r\n" +
    "3/FI/Helsinki\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    ":72:/INS/ABNANL2AXXX\r\n" +
    "-}";

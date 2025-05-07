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
    dataProvider: dataProvider_mtn90
}
isolated function testMtn90ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mtn90() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_105_1_1_camt105_B_A_190": [finMessage_10511_mt190_B_A, check io:fileReadXml("./tests/c_105_1_1/mt190_camt_105_B_A.xml")],
        "c_105_1_1_camt105_B_A_290": [finMessage_10511_mt290_B_A, check io:fileReadXml("./tests/c_105_1_1/mt290_camt_105_B_A.xml")]
    };
    return dataSet;
}

string finMessage_10511_mt190_B_A = "{1:F01CBRLGB2LXXXX0000000000}{2:O1901020221020RBOSGBCHXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt105chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":25:48751258\r\n" +
    ":32D:221020GBP10,\r\n" +
    ":71B:/NSTP/GBP10,/D\r\n" +
    ":72:/CHRQ/RBOSGBCHXXX\r\n" +
    "-}";

string finMessage_10511_mt290_B_A = "{1:F01CBRLGB2LXXXX0000000000}{2:O2901020221020RBOSGBCHXXXX00000000002210201020N}{4:\r\n" +
    ":20:camt105chrgid1\r\n" +
    ":21:camt108bzmsgidr1\r\n" +
    ":25:48751258\r\n" +
    ":32D:221020GBP10,\r\n" +
    ":71B:/CANF/GBP10,/D\r\n" +
    ":72:/CHRQ/RBOSGBCHXXX\r\n" +
    "-}";

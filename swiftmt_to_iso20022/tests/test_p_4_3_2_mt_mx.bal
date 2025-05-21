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
    dataProvider: dataProvider_p432
}
isolated function testP432(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p432() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "205COV_pasc009_A_B": [finMessage_p_4_3_2_A_B, check io:fileReadXml("./tests/P_4_3_2/mt_205_COV_pacs_009_A_B.xml")],
        "205COV_pasc009_B_C": [finMessage_p_4_3_2_B_C, check io:fileReadXml("./tests/P_4_3_2/mt_205_COV_pacs_009_B_C.xml")]
    };
    return dataSet;
};

string finMessage_p_4_3_2_A_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O2050910200810CLYDGB2SXXXX00000000002008100910N}{3:{119:COV}{121:54b2852b-bfaa-4c89-980e-8ad806388f44}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs8bizmsgidr01\r\n" +
    ":32A:200810EUR35612,21\r\n" +
    ":52A:/2020-08-10\r\n" +
    "CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:/BOFSGB2L\r\n" +
    "CAIXESBB\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/601915153\r\n" +
    "1/A Investor\r\n" +
    "2/Long Street\r\n" +
    "3/GB/Glasgow\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:CAIXESBB\r\n" +
    ":59F:/282717259\r\n" +
    "1/Spanish Investor\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";

string finMessage_p_4_3_2_B_C = "{1:F01BSCHESMMXXXX0000000000}{2:O2050000991231BOFSGB2LXXXX00000000009912310000N}{3:{119:COV}{121:54b2852b-bfaa-4c89-980e-8ad806388f44}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs8bizmsgidr01\r\n" +
    ":32A:200810EUR35612,21\r\n" +
    ":52A:/2020-08-10\r\n" +
    "CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:/BSCHESMM\r\n" +
    "CAIXESBB\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/601915153\r\n" +
    "1/A Investor\r\n" +
    "2/Long Street\r\n" +
    "3/GB/Glasgow\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:CAIXESBB\r\n" +
    ":59F:/282717259\r\n" +
    "1/Spanish Investor\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";

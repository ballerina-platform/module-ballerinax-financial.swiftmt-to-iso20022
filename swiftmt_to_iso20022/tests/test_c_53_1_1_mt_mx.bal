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
    dataProvider: dataProvider_mt940
}
isolated function testMt940ToMx(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_mt940() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "c_53_1_1_camt053_B_D_940": [finMessage_5311_mt940_B_D, check io:fileReadXml("./tests/c_53_1_1/mt940_camt_053_B_D.xml")],
        "c_53_1_1_camt053_B_Dbtr_940": [finMessage_5311_mt940_B_Dbtr, check io:fileReadXml("./tests/c_53_1_1/mt940_camt_053_B_Dbtr.xml")],
        "c_53_1_1_camt053_C_D_940": [finMessage_5311_mt940_C_D, check io:fileReadXml("./tests/c_53_1_1/mt940_camt_053_C_D.xml")],
        "c_53_1_1_camt053_D_E_940": [finMessage_5311_mt940_D_E, check io:fileReadXml("./tests/c_53_1_1/mt940_camt_053_D_E.xml")]
    };
    return dataSet;
}

string finMessage_5311_mt940_B_D = "{1:F01CNORGB22XXXX0000000000}{2:O9401700221020RBOSGB2LXXXX00000000002210201700N}{4:\r\n" +
    ":20:Stmnt-100-01\r\n" +
    ":25:25698745\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020EUR2564,\r\n" +
    ":61:221020D45250,NTRFNONREF\r\n" +
    ":62F:D221020EUR47814,\r\n" +
    "-}";

string finMessage_5311_mt940_B_Dbtr = "{1:F01CNORGB22XXXX0000000000}{2:O9401700221020RBOSGB2LXXXX00000000002210201700N}{4:\r\n" +
    ":20:Stmnt-100-01\r\n" +
    ":25:25698745\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020EUR2564,\r\n" +
    ":61:221020D45250,NTRFNONREF\r\n" +
    ":62F:D221020EUR47814,\r\n" +
    "-}";

string finMessage_5311_mt940_C_D = "{1:F01CAIXESBBXXXX0000000000}{2:O9401100221020BSCHESMMXXXX00000000002210201100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:48751258\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020EUR8547,25\r\n" +
    ":61:221020C65784,32NTRFpacs008EndToEnd\r\n" +
    ":62F:C221020EUR57237,07\r\n" +
    "-}";

string finMessage_5311_mt940_D_E = "{1:F01BANODKKKXXXX0000000000}{2:O9401100221020AAKRDK22XXXX00000000002210201100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:65479512\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020DKK8547,25\r\n" +
    ":61:221020C350000,NTRFpacs010EndToEnd\r\n" +
    ":62F:C221020DKK341452,75\r\n" +
    "-}";

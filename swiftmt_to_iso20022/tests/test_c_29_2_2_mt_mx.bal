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
    dataProvider: dataProvider_C2922
}
isolated function testC2922(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_C2922() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "mt202_pacs009cov": [finMessage_2922_A_B, check io:fileReadXml("./tests/c_29_2_2/mt202_pacs_009COV_A_B.xml")],
        "mt196_camt029": [finMessage_2922_D_A, check io:fileReadXml("./tests/c_29_2_2/mt_196_camt_029_D_A.xml")],
        "mt192_camt056": [finMessage_2922_A_D, check io:fileReadXml("./tests/c_29_2_2/mt192_camt_056_A_D.xml")]
    };
    return dataSet;
}

string finMessage_2922_A_B = "{1:F01INGBROBUXXXX0000000000}{2:O2020905221020MYMBGB2LXXXX00000000002210200905N}{3:{119:COV}{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":32A:221020RON26546464,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":57A:RZBRROBUXXX\r\n" +
    ":58A:GEBABEBBXXX\r\n" +
    ":72:/INS/INGBROBUXXX\r\n" +
    ":50F:/25698745\r\n" +
    "1/Debtor Co\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":57A:GEBABEBBXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/Ardent Finance\r\n" +
    "2/Main Street\r\n" +
    "3/RO/Bucharest\r\n" +
    "-}";

string finMessage_2922_D_A = "{1:F01MYMBGB2LXXXX0000000000}{2:O1961355221020GEBABEBBXXXX00000000002210201355N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CNCL-ID001\r\n" +
    ":21:CSE-001\r\n" +
    ":76:/CNCL/\r\n" +
    ":77A:/UETR/174c245f-2682-4291-ad67-2a41e\r\n" +
    "//530cd27\r\n" +
    ":11R:103\r\n" +
    "221020\r\n" +
    "-}";

string finMessage_2922_A_D = "{1:F01GEBABEBBXXXX0000000000}{2:O1921135221020MYMBGB2LXXXX00000000002210201135N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CSE-001\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":11S:103\r\n" +
    "221020\r\n" +
    ":79:/AM09/\r\n" +
    "/UETR/174c245f-2682-4291-ad67-2a41e530cd27\r\n" +
    ":32A:221020RON26546464,\r\n" +
    "-}";

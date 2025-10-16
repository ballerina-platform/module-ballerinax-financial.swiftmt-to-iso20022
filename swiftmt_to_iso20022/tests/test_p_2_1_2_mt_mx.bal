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
    dataProvider: dataProvider_p212
}
isolated function testP212(string finMessage, xml mxXml) returns error? {
    xml result = check toIso20022Xml(finMessage);
    json expectedResult = check xmldata:toJson(mxXml);
    json actualResult = check xmldata:toJson(result);
    test:assertEquals(actualResult, expectedResult, "Invalid transformation of MT to MX");
}

function dataProvider_p212() returns map<[string, xml]>|error {
    // fin message, xml file
    map<[string, xml]> dataSet = {
        "103_pasc004": [finMessage_p_2_1_2_B_A, check io:fileReadXml("./tests/p_2_1_2/mt103_pacs_004_B_A.xml")],
        "103_pasc004-2": [finMessage_p_2_1_2_C_B, check io:fileReadXml("./tests/p_2_1_2/mt103_pacs_004_C_B.xml")],
        "103_pasc008_A_B": [finMessage_p_2_1_2_A_B, check io:fileReadXml("./tests/p_2_1_2/mt103_pacs_008_A_B.xml")],
        "103_pasc008_B_C": [finMessage_p_2_1_2_B_C, check io:fileReadXml("./tests/p_2_1_2/mt103_pacs008_B_C.xml")],
        "103_pacs004_B_B": [finMessage_p_2_1_2_B_B, check io:fileReadXml("./tests/p_2_1_2/mt103_pacs_004_B_B.xml")]
    };
    return dataSet;
};

string finMessage_p_2_1_2_B_A = "{1:F01CHASGB2LXXXX0000000000}{2:O1030703210511CHASUS33XXXX00000000002105110703N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4B2A-006\r\n" +
    ":23B:CRED\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":33B:USD136480,\r\n" +
    ":50A:ANBTUS44XXX\r\n" +
    ":52A:CHASUS33XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":59F:1/GB Engineering \r\n" +
    "2/Industrial Park\r\n" +
    "3/GB/Cambridge\r\n" +
    ":71A:SHA\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/A2B0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_p_2_1_2_C_B = "{1:F01CHASUS33XXXX0000000000}{2:O1030653210511ANBTUS44XXXX00000000002105110653N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4C2B-005\r\n" +
    ":23B:CRED\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":33B:USD136480,\r\n" +
    ":50A:ANBTUS44XXX\r\n" +
    ":52A:CHASUS33XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":59F:1/GB Engineering \r\n" +
    "2/Industrial Park\r\n" +
    "3/GB/Cambridge\r\n" +
    ":71A:SHA\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/B2C0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_p_2_1_2_A_B = "{1:F01CHASUS33XXXX0000000000}{2:O1031013210511CHASGB2LXXXX00000000002105111013N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:A2B0506272708\r\n" +
    ":23B:CRED\r\n" +
    ":32A:210511USD136500,\r\n" +
    ":33B:USD136500,\r\n" +
    ":50F:/96325874\r\n" +
    "1/GB Engineering \r\n" +
    "2/Industrial Park\r\n" +
    "3/GB/Cambridge\r\n" +
    ":52A:CHASGB2LXXX\r\n" +
    ":56A:ANBTUS44XXX\r\n" +
    ":57A:HNBAUS51XXX\r\n" +
    ":59F:/254178963\r\n" +
    "1/US Engines\r\n" +
    "2/20 Main St\r\n" +
    "3/US/Casper WY\r\n" +
    ":70:/ROC/E2E04044506271305\r\n" +
    ":71A:SHA\r\n" +
    "-}";

string finMessage_p_2_1_2_B_C = "{1:F01ANBTUS44XXXX0000000000}{2:O1030523210511CHASUS33XXXX00000000002105110523N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:B2C0506272708\r\n" +
    ":23B:CRED\r\n" +
    ":32A:210511USD136490,\r\n" +
    ":33B:USD136500,\r\n" +
    ":50F:/96325874\r\n" +
    "1/GB Engineering \r\n" +
    "2/Industrial Park\r\n" +
    "3/GB/Cambridge\r\n" +
    ":52A:CHASGB2LXXX\r\n" +
    ":57A:HNBAUS51XXX\r\n" +
    ":59F:/254178963\r\n" +
    "1/US Engines\r\n" +
    "2/20 Main St\r\n" +
    "3/US/Casper WY\r\n" +
    ":70:/ROC/E2E04044506271305\r\n" +
    ":71A:SHA\r\n" +
    ":71F:USD10,\r\n" +
    "-}";

string finMessage_p_2_1_2_B_B = "{1:F01CHASGB2LXXXX0000000000}{2:O1030703210511CHASUS33XXXX00000000002105110703N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4B2A-006\r\n" +
    ":23B:CRED\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":33B:USD136480,\r\n" +
    ":50A:ANBTUS44XXX\r\n" +
    ":52A:CHASUS33XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":59F:1/GB Engineering \r\n" +
    "2/Industrial Park\r\n" +
    "3/GB/Cambridge\r\n" +
    ":71A:BEN\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/A2B0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

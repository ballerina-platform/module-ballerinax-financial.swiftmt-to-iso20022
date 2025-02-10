// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

const DETAILS_CHRGS = [["BEN", "CRED"], ["OUR", "DEBT"], ["SHA", "SHAR"]];
const DEFAULT_NUM_OF_TX = "1";
const YEAR_PREFIX = "20";
const ASSIGN_ID = "ASSIGNID-01";
const SCHEMA_CODE = ["ARNU", "CCPT", "CUST", "DRLC", "EMPL", "NIDN", "SOSE", "TXID"];
const REASON_CODE = ["AGNT", "AM09", "COVR", "CURR", "CUST", "CUTA", "DUPL", "FRAD", "TECH", "UPAY"];
const MT_1XX_SNDR_CODE = ["INT", "ACC", "INS", "INTA", "SVCLVL", "LOCINS", "CATPURP"];
const MT_2XX_SNDR_CODE1 = ["INT", "ACC", "INS", "BNF", "TSU", "INTA", "PHON", "PHONBEN", "PHONIBK", "TELE", 
            "TELEBEN", "TELEIBK", "SVCLVL", "LOCINS", "CATPURP", "PURP", "UDLC"];
const MT_2XX_SNDR_CODE2 = ["INT", "ACC", "PHON", "PHONIBK", "TELE", "TELEIBK"];
const MT_2XX_SNDR_CODE3 = ["ACC", "BNF"];
const MISSING_INFO_CODE = ["3", "4", "5", "7", "10", "13", "14", "15", "16", "17", "18", "19", "23", "24", "25", "26", "27", "28", "29", "36", "37", "38", "42", "48", "49", "50", "51"];
const INCORRECT_INFO_CODE = ["2", "6", "8", "9", "11", "12", "20", "22", "39", "40", "41", "43", "44", "45", "46", "47"];
const map<string> INVTGTN_RJCT_RSN = {"RQDA": "NAUT", "LEGL": "NAUT", "INDM": "NAUT", "AGNT": "NAUT", "CUST": "NAUT", "NOOR": "NFND", "PTNA": "UKNW", "ARPL": "UKNW", "NOAS": "UKNW", "AM04": "PCOR", "AC04": "PCOR", "ARDT": "UKNW"};
final readonly & map<isolated function> transformFunctionMap =
    {
    "101": transformMT101ToPain001,
    "102": transformMT102ToPcs008,
    "102STP": transformMT102STPToPacs008,
    "103": transformMT103ToPacs008,
    "103STP": transformMT103STPToPacs008,
    "103REMIT": transformMT103REMITToPacs008,
    "107": transformMT107ToPacs003,
    "192": transformMTn92ToCamt055,
    "195": transformMTn95ToCamt026,
    "196": transformMTn96ToCamt029,
    "199": transformMTn99Pacs002,
    "200": transformMT200ToPacs009,
    "201": transformMT201ToPacs009,
    "202": transformMT202Pacs009,
    "202COV": transformMT202COVToPacs009,
    "203": transformMT203ToPacs009,
    "204": transformMT204ToPacs010,
    "205": transformMT205ToPacs009,
    "205COV": transformMT205COVToPacs009,
    "210": transformMT210ToCamt057,
    "292": transformMTn92ToCamt056,
    "295": transformMTn95ToCamt026,
    "296":transformMTn96ToCamt029,
    "299": transformMTn99Pacs002,
    "900": transformMT900ToCamt054,
    "910": transformMT910Camt054,
    "920": transformMT920ToCamt060,
    "940": transformMT940ToCamt053,
    "941": transformMT941ToCamt052,
    "942": transformMT942ToCamt052,
    "950": transformMT950ToCamt053,
    "970": transformMT970ToCamt053,
    "971": transformMT971ToCamt052,
    "972": transformMT972ToCamt052,
    "973": transformMT973ToCamt060,
    "992": transformMTn92ToCamt056,
    "995": transformMTn95ToCamt026,
    "996":transformMTn96ToCamt029
};

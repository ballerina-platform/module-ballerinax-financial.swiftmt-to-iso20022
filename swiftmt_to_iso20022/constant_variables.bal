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
    "101": transformMT101,
    "102": transformMT102,
    "102STP": transformMT102STP,
    "103": transformMT103,
    "103STP": transformMT103STP,
    "103REMIT": transformMT103REMIT,
    "107": transformMT107,
    "192": transformMT192ToCamt055,
    "195": transformMTn95ToCamt026,
    "196":transformMTn96ToCamt029,
    "200": transformMT200ToPacs009,
    "201": transformMT201,
    "202": transformMT202,
    "202COV": transformMT202COV,
    "203": transformMT203,
    "204": transformMT204,
    "205": transformMT205,
    "205COV": transformMT205COV,
    "210": transformMT210,
    "292": transformMTn92ToCamt056,
    "295": transformMTn95ToCamt026,
    "296":transformMTn96ToCamt029,
    "900": transformMT900,
    "910": transformMT910,
    "920": transformMT920,
    "940": transformMT940,
    "941": transformMT941,
    "942": transformMT942,
    "950": transformMT950,
    "970": transformMT970,
    "971": transformMT971,
    "972": transformMT972,
    "973": transformMT973,
    "992": transformMTn92ToCamt056,
    "995": transformMTn95ToCamt026,
    "996":transformMTn96ToCamt029
};

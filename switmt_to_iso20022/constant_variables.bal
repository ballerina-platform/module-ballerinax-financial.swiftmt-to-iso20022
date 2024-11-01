const DETAILS_CHRGS = [["BEN", "CRED"], ["OUR", "DEBT"], ["SHA", "SHAR"]];
const DEFAULT_NUM_OF_TX = "1";
const YEAR_PREFIX = "20";
final readonly & map<isolated function (record {} message) returns record {}|error> transformFunctionMap =
    {
    "101": transformMT101,
    "102": transformMT102,
    "102STP": transformMT102STP,
    "103": transformMT103,
    "103STP": transformMT103STP,
    "103REMIT": transformMT103REMIT,
    "107": transformMT107,
    "200": transformMT200ToPacs009,
    "201": transformMT201,
    "202": transformMT202,
    "202COV": transformMT202COV,
    "203": transformMT203,
    "204": transformMT204,
    "205": transformMT205,
    "205COV": transformMT205COV,
    "210": transformMT210,
    "900": transformMT900,
    "910": transformMT910,
    "920": transformMT920,
    "940": transformMT940,
    "950": transformMT950,
    "970": transformMT970,
    "971": transformMT971,
    "972": transformMT972,
    "973": transformMT973
};

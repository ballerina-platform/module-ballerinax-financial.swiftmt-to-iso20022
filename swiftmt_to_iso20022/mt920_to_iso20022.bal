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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MT920 SWIFT message into an ISO 20022 CAMT.060 document format. 
# It extracts relevant fields from the MT920 message and maps them to the CAMT structure.
#
# + message - The parsed MT920 message as a record value.
# + return - Returns a `Camt060Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT920ToCamt060(swiftmt:MT920Message message) returns camtIsoRecord:Camt060Document|error => {
    AcctRptgReq: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            MsgId: message.block4.MT20.msgId.content
        },
        RptgReq: [
            {
                Id: message.block4.MT20.msgId.content,
                ReqdMsgNmId: message.block4.MT12.Msg.content,
                AcctOwnr: {},
                Acct: {
                    Id: {
                        IBAN: validateAccountNumber(message.block4.MT25?.Acc)[0],
                        Othr: {
                            Id: validateAccountNumber(message.block4.MT25?.Acc)[1],
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT25?.Acc)
                            }
                        }
                    }
                },
                ReqdTxTp: {
                    Sts: {},
                    CdtDbtInd: camtIsoRecord:DBIT,
                    FlrLmt: check getFloorLimit(message.block4.MT34F)
                }
            }
        ]
    }
};
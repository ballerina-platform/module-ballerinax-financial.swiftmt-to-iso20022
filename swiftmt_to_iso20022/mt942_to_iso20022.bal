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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MT942 SWIFT message into an ISO 20022 CAMT.052 document.
# The relevant fields from the MT942 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT942 message as a record value.
# + return - Returns a `Camt052Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT942ToCamt052(swiftmt:MT942Message message) returns camtIsoRecord:Camt052Envelope|error =>
    let camtIsoRecord:ReportEntry14[] entries = check getEntries(message.block4.MT61, message.block4.MT34F[0].Ccy.content),
    [string?, string?] [iban, bban] = validateAccountNumber(message.block4.MT25?.Acc,
            acc2 = message.block4.MT25P?.Acc),
    string? dateTime = convertToISOStandardDateTime(message.block4.MT13D?.Dt, message.block4.MT13D?.Tm) in {
        AppHdr: {
            Fr: {
                FIId: {
                    FinInstnId: {
                        BICFI: getMessageSender(message.block1?.logicalTerminal,
                                message.block2.MIRLogicalTerminal)
                    }
                }
            },
            To: {
                FIId: {
                    FinInstnId: {
                        BICFI: getMessageReceiver(message.block1?.logicalTerminal,
                                message.block2.receiverAddress)
                    }
                }
            },
            BizMsgIdr: message.block4.MT20.msgId.content,
            MsgDefIdr: "camt.052.001.08",
            BizSvc: "swift.cbprplus.03",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            BkToCstmrAcctRpt: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    MsgId: message.block4.MT20.msgId.content
                },
                Rpt: [
                    {
                        Id: message.block4.MT20.msgId.content,
                        CreDtTm: dateTime is () ? () :
                            dateTime + message.block4.MT13D?.Sgn?.content.toString() +
                            message.block4.MT13D?.TmOfst?.content.toString().substring(0, 2) +
                            ":" + message.block4.MT13D?.TmOfst?.content.toString().substring(2),
                        Acct: bban is () && iban is () ? {} : {
                                Ccy: message.block4.MT34F[0].Ccy.content,
                                Id: {
                                    IBAN: iban,
                                    Othr: bban is () ? () : {
                                            Id: bban,
                                            SchmeNm: {
                                                Cd: getSchemaCode(message.block4.MT25?.Acc, message.block4.MT25P?.Acc)
                                            }
                                        }
                                }
                            },
                        ElctrncSeqNb: message.block4.MT28C.SeqNo?.content,
                        LglSeqNb: message.block4.MT28C.StmtNo.content,
                        RptPgntn: {
                            PgNb: "1",
                            LastPgInd: true
                        },
                        Ntry: entries.length() == 0 ? () : entries,
                        TxsSummry: message.block4.MT90C is () && message.block4.MT90D is () ? () : {
                                TtlNtries: {
                                    NbOfNtries: check getTotalNumOfEntries(message.block4.MT90C?.TtlNum,
                                            message.block4.MT90D?.TtlNum),
                                    Sum: check getTotalSumOfEntries(message.block4.MT90C?.Amnt, message.block4.MT90D?.Amnt)
                                },
                                TtlDbtNtries: message.block4.MT90D is () ? () : {
                                        NbOfNtries: message.block4.MT90D?.TtlNum?.content,
                                        Sum: check convertToDecimal(message.block4.MT90D?.Amnt)
                                    },
                                TtlCdtNtries: message.block4.MT90C is () ? () : {
                                        NbOfNtries: message.block4.MT90C?.TtlNum?.content,
                                        Sum: check convertToDecimal(message.block4.MT90C?.Amnt)
                                    }
                            },
                        AddtlRptInf: getInfoToAccOwnr(message.block4.MT86)
                    }
                ]
            }
        }
    };

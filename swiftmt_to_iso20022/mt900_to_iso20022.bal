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

# This function transforms an MT900 SWIFT message into an ISO 20022 CAMT.054 document.
# The MT900 message contains debit confirmation details, which are mapped to a notification
# in the CAMT.054 format, including account information, transaction details, and amounts.
#
# + message - The parsed MT900 message as a record value.
# + return - Returns a `Camt054Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT900ToCamt054(swiftmt:MT900Message message) returns camtIsoRecord:Camt054Envelope|error =>
    let string? dateTime = convertToISOStandardDateTime(message.block4.MT13D?.Dt, message.block4.MT13D?.Tm),
    [string?, string?] [iban, bban] = validateAccountNumber(message.block4.MT25?.Acc,
        acc2 = message.block4.MT25P?.Acc) in {
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal, 
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal, 
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "camt054.001.12",
        BizSvc: "swift.cbprplus.02", 
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, 
            true).ensureType(string)
    },
    Document: {
        BkToCstmrDbtCdtNtfctn: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, 
                    true).ensureType(string),
                MsgId: message.block4.MT20.msgId.content
            },
            Ntfctn: [
                {
                    Id: message.block4.MT20.msgId.content,
                    Acct: bban is () && iban is () ? {} : {
                        Id: {
                            IBAN: iban,
                            Othr: bban is () ? (): {
                                Id: bban,
                                SchmeNm: {
                                    Cd: getSchemaCode(message.block4.MT25?.Acc, message.block4.MT25P?.Acc)
                                }
                            }
                        },
                        Ownr: message.block4.MT25P is () ? () : {
                            Id: {
                                OrgId: {
                                    AnyBIC: message.block4.MT25P?.IdnCd?.content
                                }
                            }
                        }
                    },
                    Ntry: [{
                        BookgDt: dateTime is () ? (): {
                            DtTm:  dateTime + message.block4.MT13D?.Sgn?.content.toString() + 
                                message.block4.MT13D?.TmOfst?.content.toString().substring(0,2) + 
                                ":" + message.block4.MT13D?.TmOfst?.content.toString().substring(2)
                        },
                        Amt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        CdtDbtInd: camtIsoRecord:DBIT,
                        ValDt: {
                            Dt: convertToISOStandardDate(message.block4.MT32A.Dt)
                        },
                        Sts: {},
                        BkTxCd: {},
                        NtryDtls: [
                            {
                                TxDtls: [
                                    {
                                        Amt: {
                                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                                            Ccy: message.block4.MT32A.Ccy.content
                                        },
                                        RltdDts: {
                                            IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt)
                                        },
                                        CdtDbtInd: camtIsoRecord:DBIT,
                                        RltdPties: {
                                            Dbtr: {
                                                Agt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, 
                                                    message.block4.MT52D?.Nm, message.block4.MT52A?.PrtyIdn,
                                                    message.block4.MT52D?.PrtyIdn, (), (), 
                                                        message.block4.MT52D?.AdrsLine)
                                            },
                                            DbtrAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, 
                                                message.block4.MT52D?.PrtyIdn)
                                        }, 
                                        Refs: {
                                            EndToEndId: message.block4.MT21.Ref.content,
                                            InstrId: message.block4.MT21.Ref.content,
                                            UETR: message.block3?.NdToNdTxRef?.value
                                        },
                                        AddtlTxInf: message.block4.MT72?.Cd?.content
                                    }
                                ]
                            }
                        ]
                    }]
                }
            ]
        }
    }
};

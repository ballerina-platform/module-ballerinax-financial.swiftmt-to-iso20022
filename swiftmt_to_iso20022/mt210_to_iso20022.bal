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

# Transforms an MT210 message into an ISO 20022 Camt.057Document format.
#
# + message - The parsed MT210 message of type `swiftmt:MT210Message`.
# + return - Returns an ISO 20022 Camt.057Document or an error if the transformation fails.
isolated function transformMT210ToCamt057(swiftmt:MT210Message message) returns camtIsoRecord:Camt057Envelope|error =>
    let string? sender = getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal),
    string? receiver = getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress) in {
        AppHdr: {
            Fr: {FIId: {FinInstnId: {BICFI: sender}}},
            To: {FIId: {FinInstnId: {BICFI: receiver}}},
            BizMsgIdr: message.block4.MT20.msgId.content,
            MsgDefIdr: "camt.057.001.06",
            BizSvc: "swift.cbprplus.02",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            NtfctnToRcv: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    MsgId: message.block4.MT20.msgId.content
                },
                Ntfctn: {
                    Itm: [
                        {
                            Id: message.block4.MT21.Ref.content,
                            Amt: {
                                content: check convertToDecimalMandatory(message.block4.MT32B.Amnt),
                                Ccy: message.block4.MT32B.Ccy.content
                            },
                            XpctdValDt: convertToISOStandardDate(message.block4.MT30?.Dt),
                            EndToEndId: message.block4.MT21.Ref.content,
                            UETR: message.block3?.NdToNdTxRef?.value
                        }
                    ],
                    Acct: getCashAccount(message.block4.MT25?.Acc, ()),
                    AcctOwnr: sender == () ? () : {
                            Agt: {
                                FinInstnId: {
                                    BICFI: sender
                                }
                            }
                        },
                    AcctSvcr: sender == () ? () : {
                            FinInstnId: {
                                BICFI: receiver
                            }
                        },
                    Dbtr: {
                        Pty: getDebtorOrCreditor(message.block4.MT50C?.IdnCd, (), (), (),
                                message.block4.MT50F?.PrtyIdn, message.block4.MT50F?.Nm, message.block4.MT50?.Nm,
                                message.block4.MT50F?.AdrsLine, message.block4.MT50?.AdrsLine,
                                message.block4.MT50F?.CntyNTw, true)
                    },
                    DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, message.block4.MT52D?.Nm,
                            message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (), (),
                            message.block4.MT52D?.AdrsLine),
                    IntrmyAgt: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content, message.block4.MT56D?.Nm,
                            message.block4.MT56A?.PrtyIdn,
                            (), message.block4.MT56D?.PrtyIdn, (), message.block4.MT56D?.AdrsLine),
                    Id: message.block4.MT20.msgId.content
                }
            }
        }
    };

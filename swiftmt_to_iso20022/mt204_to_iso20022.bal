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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MT204 message into an ISO 20022 `Pacs010Document`.
#
# + message - The parsed MT204 message as record value.
# + return - Returns a `Pacs010Document` containing the direct debit transaction instructions,
# or an error if the transformation fails.
isolated function transformMT204ToPacs010(swiftmt:MT204Message message) returns pacsIsoRecord:Pacs010Envelope|error => {
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "pacs.010.001.06", 
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string)
    },
    Document: {
        FIDrctDbt: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
                NbOfTxs: message.block4.Transaction.length().toString(),
                MsgId: message.block4.MT20.msgId.content,
                CtrlSum: check convertToDecimal(message.block4.MT19.Amnt),
                InstgAgt: {
                    FinInstnId: {
                        BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                    }
                },
                InstdAgt: {
                    FinInstnId: {
                        BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                    }
                }
            },
            CdtInstr: [
                {
                    Cdtr: {
                        FinInstnId: {
                            BICFI: message.block4.MT58A?.IdnCd?.content,
                            ClrSysMmbId: {
                                MmbId: "", 
                                ClrSysId: {
                                    Cd: getPartyIdentifierOrAccount2(message.block4.MT58A?.PrtyIdn, message.block4.MT58D?.PrtyIdn)[0]
                                }
                            },
                            Nm: getName(message.block4.MT58D?.Nm),
                            PstlAdr: {
                                AdrLine: getAddressLine(message.block4.MT58D?.AdrsLine)
                            }
                        }
                    },
                    CdtrAcct: {
                        Id: {
                            IBAN: getPartyIdentifierOrAccount2(message.block4.MT58A?.PrtyIdn, message.block4.MT58D?.PrtyIdn)[1],
                            Othr: {
                                Id: getPartyIdentifierOrAccount2(message.block4.MT58A?.PrtyIdn, message.block4.MT58D?.PrtyIdn)[2],
                                SchmeNm: {
                                    Cd: getSchemaCode(prtyIdn1 = message.block4.MT58A?.PrtyIdn, prtyIdn2 = message.block4.MT58D?.PrtyIdn)
                                }
                            }
                        }
                    },
                    CdtrAgt: {
                        FinInstnId: {
                            BICFI: message.block4.MT57A?.IdnCd?.content,
                            ClrSysMmbId: {
                                MmbId: "", 
                                ClrSysId: {
                                    Cd: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[0]
                                }
                            },
                            Nm: getName(message.block4.MT57D?.Nm),
                            PstlAdr: {
                                AdrLine: getAddressLine(message.block4.MT57D?.AdrsLine, address3 = message.block4.MT57B?.Lctn?.content)
                            }
                        }
                    },
                    CdtrAgtAcct: {
                        Id: {
                            IBAN: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[1],
                            Othr: {
                                Id: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[2],
                                SchmeNm: {
                                    Cd: getSchemaCode(prtyIdn1 = message.block4.MT57A?.PrtyIdn, prtyIdn2 = message.block4.MT57B?.PrtyIdn, prtyIdn3 = message.block4.MT57D?.PrtyIdn)
                                }
                            }
                        }
                    },
                    CdtId: message.block4.MT20.msgId.content,
                    IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT30.Dt),
                    InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[0],
                    DrctDbtTxInf: check getMT204CreditTransferTransactionInfo(message.block4, message.block3)
                }
            ]
        }
    }
};

# This function extracts direct debit transaction information from an MT204 message 
# and converts it into an array of ISO 20022 `DirectDebitTransactionInformation33` records.
#
# + block4 - The parsed block4 of MT204 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT204 SWIFT message containing end to end id.
# + return - Returns an array of `DirectDebitTransactionInformation33` containing 
# the transaction information, or an error if the extraction fails.
isolated function getMT204CreditTransferTransactionInfo(swiftmt:MT204Block4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:DirectDebitTransactionInformation33[]|error {
    pacsIsoRecord:DirectDebitTransactionInformation33[] dbtTrfTxInfArray = [];
    foreach swiftmt:MT204Transaction transaxion in block4.Transaction {
        dbtTrfTxInfArray.push({
            IntrBkSttlmAmt: {
                content: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                Ccy: transaxion.MT32B.Ccy.content
            },
            PmtId: {
                EndToEndId: getMandatoryFields(transaxion.MT21?.Ref?.content),
                InstrId: transaxion.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value
            },
            Dbtr: {
                FinInstnId: {
                    BICFI: transaxion.MT53A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT53A?.PrtyIdn, transaxion.MT53B?.PrtyIdn, transaxion.MT53D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(transaxion.MT53D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(transaxion.MT53D?.AdrsLine, address3 = transaxion.MT53B?.Lctn?.content)
                    }
                }
            },
            DbtrAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT53A?.PrtyIdn, transaxion.MT53B?.PrtyIdn, transaxion.MT53D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT53A?.PrtyIdn, transaxion.MT53B?.PrtyIdn, transaxion.MT53D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT53A?.PrtyIdn, prtyIdn2 = transaxion.MT53B?.PrtyIdn, prtyIdn3 = transaxion.MT53D?.PrtyIdn)
                        }
                    }
                }
            }
        });
    }
    return dbtTrfTxInfArray;
}

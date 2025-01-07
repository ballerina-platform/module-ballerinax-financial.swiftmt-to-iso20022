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

import ballerina/uuid;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MT203 SWIFT message into an ISO 20022 Pacs009Document.
#
# + message - The parsed MT203 message as a record value.
# + return - Returns a `Pacs009Document` if the transformation is successful, 
# otherwise returns an error.
isolated function transformMT203ToPacs009(swiftmt:MT203Message message) returns pacsIsoRecord:Pacs009Envelope|error => {
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)}}}, 
        BizMsgIdr: uuid:createType4AsString().substring(0, 35), 
        MsgDefIdr: "pacs.009.001.11", 
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string)
    },
    Document: {
        FICdtTrf: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
                CtrlSum: check convertToDecimal(message.block4.MT19.Amnt),
                SttlmInf: {
                    SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B, message.block4.MT53D),
                    InstgRmbrsmntAgt: {
                        FinInstnId: {
                            BICFI: message.block4.MT53A?.IdnCd?.content,
                            ClrSysMmbId: {
                                MmbId: "", 
                                ClrSysId: {
                                    Cd: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn, message.block4.MT53D?.PrtyIdn)[0]
                                }
                            },
                            Nm: getName(message.block4.MT53D?.Nm),
                            PstlAdr: {
                                AdrLine: getAddressLine(message.block4.MT53D?.AdrsLine, address3 = message.block4.MT53B?.Lctn?.content)
                            }
                        }
                    },
                    InstgRmbrsmntAgtAcct: {
                        Id: {
                            IBAN: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn, message.block4.MT53D?.PrtyIdn)[1],
                            Othr: {
                                Id: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn, message.block4.MT53D?.PrtyIdn)[2],
                                SchmeNm: {
                                    Cd: getSchemaCode(prtyIdn1 = message.block4.MT53A?.PrtyIdn, prtyIdn2 = message.block4.MT53B?.PrtyIdn, prtyIdn3 = message.block4.MT53D?.PrtyIdn)
                                }
                            }
                        }
                    },
                    InstdRmbrsmntAgt: {
                        FinInstnId: {
                            BICFI: message.block4.MT54A?.IdnCd?.content,
                            ClrSysMmbId: {
                                MmbId: "", 
                                ClrSysId: {
                                    Cd: getPartyIdentifierOrAccount2(message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn, message.block4.MT54D?.PrtyIdn)[0]
                                }
                            },
                            Nm: getName(message.block4.MT54D?.Nm),
                            PstlAdr: {
                                AdrLine: getAddressLine(message.block4.MT54D?.AdrsLine, address3 = message.block4.MT54B?.Lctn?.content)
                            }
                        }
                    },
                    InstdRmbrsmntAgtAcct: {
                        Id: {
                            IBAN: getPartyIdentifierOrAccount2(message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn, message.block4.MT54D?.PrtyIdn)[1],
                            Othr: {
                                Id: getPartyIdentifierOrAccount2(message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn, message.block4.MT54D?.PrtyIdn)[2],
                                SchmeNm: {
                                    Cd: getSchemaCode(prtyIdn1 = message.block4.MT54A?.PrtyIdn, prtyIdn2 = message.block4.MT54B?.PrtyIdn, prtyIdn3 = message.block4.MT54D?.PrtyIdn)
                                }
                            }
                        }
                    }
                },
                InstgAgt: {
                    FinInstnId: {
                        BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                    }
                },
                InstdAgt: {
                    FinInstnId: {
                        BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                    }
                },
                NbOfTxs: message.block4.Transaction.length().toString(),
                MsgId: uuid:createType4AsString().substring(0, 35)
            },
            CdtTrfTxInf: check getMT203CreditTransferTransactionInfo(message.block4, message.block3)
        }
    }
};

# This function retrieves credit transfer transaction information from an MT203 message 
# and transforms it into an array of ISO 20022 `CreditTransferTransaction62` records.
#
# + block4 - The parsed block4 of MT203 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT203 SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction62` records containing 
# details of the transactions, or an error if the transformation fails.
isolated function getMT203CreditTransferTransactionInfo(swiftmt:MT203Block4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:CreditTransferTransaction62[]|error {
    pacsIsoRecord:CreditTransferTransaction62[] cdtTrfTxInfArray = [];
    foreach swiftmt:MT203Transaction transaxion in block4.Transaction {
        swiftmt:MT72? sndToRcvrInfo = getMT203RepeatingFields(block4, transaxion.MT72, "72");
        cdtTrfTxInfArray.push({
            Cdtr: {
                FinInstnId: {
                    BICFI: transaxion.MT58A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT58A?.PrtyIdn, transaxion.MT58D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(transaxion.MT58D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(transaxion.MT58D?.AdrsLine)
                    }
                }
            },
            CdtrAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT58A?.PrtyIdn, transaxion.MT58D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT58A?.PrtyIdn, transaxion.MT58D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT58A?.PrtyIdn, prtyIdn2 = transaxion.MT58D?.PrtyIdn)
                        }
                    }
                }
            },
            CdtrAgt: {
                FinInstnId: {
                    BICFI: transaxion.MT57A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(transaxion.MT57D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(transaxion.MT57D?.AdrsLine, address3 = transaxion.MT57B?.Lctn?.content)
                    }
                }
            },
            CdtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT57A?.PrtyIdn, prtyIdn2 = transaxion.MT57B?.PrtyIdn, prtyIdn3 = transaxion.MT57D?.PrtyIdn)
                        }
                    }
                }
            },
            IntrBkSttlmAmt: {
                content: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                Ccy: transaxion.MT32B.Ccy.content
            },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT30.Dt),
            PmtId: {
                EndToEndId: transaxion.MT21.Ref.content,
                InstrId: transaxion.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value
            },
            PmtTpInf: {
                SvcLvl: [{
                    Cd: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[4]
                }], 
                CtgyPurp: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[6],
                LclInstrm: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[5]
            },
            Dbtr: {
                FinInstnId: {
                    BICFI: block4.MT52A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(block4.MT52D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(block4.MT52D?.AdrsLine)
                    }
                }
            },
            DbtrAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = block4.MT52A?.PrtyIdn, prtyIdn2 = block4.MT52D?.PrtyIdn)
                        }
                    }
                }
            },
            IntrmyAgt1: {
                FinInstnId: {
                    BICFI: transaxion.MT56A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(transaxion.MT56D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(transaxion.MT56D?.AdrsLine)
                    }
                }
            },
            IntrmyAgt1Acct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT56A?.PrtyIdn, prtyIdn2 = transaxion.MT56D?.PrtyIdn)
                        }
                    }
                }
            },
            InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[1],
            InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[0],
            RmtInf: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[7],
            Purp: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo))[8]
        });
    }
    return cdtTrfTxInfArray;
}

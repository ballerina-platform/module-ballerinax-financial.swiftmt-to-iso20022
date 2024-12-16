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

# This function transforms an MT202 SWIFT message into an ISO 20022 Pacs009Document format.
#
# + message - The parsed MT202 message as a record value.
# + return - Returns a `Pacs009Document` object if the transformation is successful,
# otherwise returns an error.
isolated function transformMT202Pacs009(swiftmt:MT202Message message) returns pacsIsoRecord:Pacs009Document|error => {
    FICdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
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
            NbOfTxs: DEFAULT_NUM_OF_TX,
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: [
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
                IntrBkSttlmAmt: {
                    ActiveCurrencyAndAmount_SimpleType: {
                        ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                        Ccy: message.block4.MT32A.Ccy.content
                    }
                },
                IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                PmtId: {
                    EndToEndId: message.block4.MT21.Ref.content,
                    InstrId: message.block4.MT20.msgId.content,
                    UETR: message.block3?.NdToNdTxRef?.value
                },
                PmtTpInf: {
                    SvcLvl: [{
                        Cd: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[4]
                    }],
                    CtgyPurp: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[6],
                    LclInstrm: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[5]
                },
                SttlmTmReq: {
                    CLSTm: getTimeIndication(message.block4.MT13C)[0]
                },
                SttlmTmIndctn: {
                    CdtDtTm: getTimeIndication(message.block4.MT13C)[1],
                    DbtDtTm: getTimeIndication(message.block4.MT13C)[2]
                },
                Dbtr: {
                    FinInstnId: {
                        BICFI: message.block4.MT52A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn)[0]
                            }
                        },
                        Nm: getName(message.block4.MT52D?.Nm),
                        PstlAdr: {
                            AdrLine: getAddressLine(message.block4.MT52D?.AdrsLine)
                        }
                    }
                },
                DbtrAcct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT52A?.PrtyIdn, prtyIdn2 = message.block4.MT52D?.PrtyIdn)
                            }
                        }
                    }
                },
                IntrmyAgt1: {
                    FinInstnId: {
                        BICFI: message.block4.MT56A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0]
                            }
                        },
                        Nm: getName(message.block4.MT56D?.Nm),
                        PstlAdr: {
                            AdrLine: getAddressLine(message.block4.MT56D?.AdrsLine)
                        }
                    }
                },
                IntrmyAgt1Acct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT56A?.PrtyIdn, prtyIdn2 = message.block4.MT56D?.PrtyIdn)
                            }
                        }
                    }
                },
                InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[1],
                InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[0],
                RmtInf: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[7],
                Purp: (check getMT2XXSenderToReceiverInfo(message.block4.MT72))[8]
            }
        ]
    }
};

# This function transforms an MT202COV SWIFT message into an ISO 20022 Pacs009Document format.
#
# + message - The parsed MT202COV message as a record value.
# + return - Returns a `Pacs009Document` object if the transformation is successful,
# otherwise returns an error.
isolated function transformMT202COVToPacs009(swiftmt:MT202COVMessage message) returns pacsIsoRecord:Pacs009Document|error => {
    FICdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
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
            NbOfTxs: DEFAULT_NUM_OF_TX,
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: check getMT202COVCreditTransfer(message.block4, message.block3)
    }
};

# This function extracts and transforms credit transfer transaction information 
# from an MT202COV SWIFT message into an array of ISO 20022 CreditTransferTransaction62 records.
#
# + block4 - The parsed block4 of MT202 COV SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT202 COV SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction62` objects if the transformation is successful,
# otherwise returns an error.
isolated function getMT202COVCreditTransfer(swiftmt:MT202COVBlock4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:CreditTransferTransaction62[]|error {
    pacsIsoRecord:CreditTransferTransaction62[] cdtTrfTxInfArray = [];
    swiftmt:MT52A? ordgInstn52A = check getUnderlyingCustomerTransactionField52(block4.UndrlygCstmrCdtTrf.MT52A, block4.UndrlygCstmrCdtTrf.MT52D, block4)[0].ensureType();
    swiftmt:MT52D? ordgInstn52D = check getUnderlyingCustomerTransactionField52(block4.UndrlygCstmrCdtTrf.MT52A, block4.UndrlygCstmrCdtTrf.MT52D, block4)[1].ensureType();
    swiftmt:MT57A? cdtrAgt57A = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A, block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[0].ensureType();
    swiftmt:MT57B? cdtrAgt57B = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A, block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[1].ensureType();
    swiftmt:MT57C? cdtrAgt57C = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A, block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[2].ensureType();
    swiftmt:MT57D? cdtrAgt57D = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A, block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[3].ensureType();
    cdtTrfTxInfArray.push({
        Cdtr: {
            FinInstnId: {
                BICFI: block4.MT58A?.IdnCd?.content,
                ClrSysMmbId: {
                    MmbId: "", 
                    ClrSysId: {
                        Cd: getPartyIdentifierOrAccount2(block4.MT58A?.PrtyIdn, block4.MT58D?.PrtyIdn)[0]
                    }
                },
                Nm: getName(block4.MT58D?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(block4.MT58D?.AdrsLine)
                }
            }
        },
        CdtrAcct: {
            Id: {
                IBAN: getPartyIdentifierOrAccount2(block4.MT58A?.PrtyIdn, block4.MT58D?.PrtyIdn)[1],
                Othr: {
                    Id: getPartyIdentifierOrAccount2(block4.MT58A?.PrtyIdn, block4.MT58D?.PrtyIdn)[2],
                    SchmeNm: {
                        Cd: getSchemaCode(prtyIdn1 = block4.MT58A?.PrtyIdn, prtyIdn2 = block4.MT58D?.PrtyIdn)
                    }
                }
            }
        },
        CdtrAgt: {
            FinInstnId: {
                BICFI: block4.MT57A?.IdnCd?.content,
                ClrSysMmbId: {
                    MmbId: "", 
                    ClrSysId: {
                        Cd: getPartyIdentifierOrAccount2(block4.MT57A?.PrtyIdn, block4.MT57B?.PrtyIdn, block4.MT57D?.PrtyIdn)[0]
                    }
                },
                Nm: getName(block4.MT57D?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(block4.MT57D?.AdrsLine, address3 = block4.MT57B?.Lctn?.content)
                }
            }
        },
        CdtrAgtAcct: {
            Id: {
                IBAN: getPartyIdentifierOrAccount2(block4.MT57A?.PrtyIdn, block4.MT57B?.PrtyIdn, block4.MT57D?.PrtyIdn)[1],
                Othr: {
                    Id: getPartyIdentifierOrAccount2(block4.MT57A?.PrtyIdn, block4.MT57B?.PrtyIdn, block4.MT57D?.PrtyIdn)[2],
                    SchmeNm: {
                        Cd: getSchemaCode(prtyIdn1 = block4.MT57A?.PrtyIdn, prtyIdn2 = block4.MT57B?.PrtyIdn, prtyIdn3 = block4.MT57D?.PrtyIdn)
                    }
                }
            }
        },
        IntrBkSttlmAmt: {
            ActiveCurrencyAndAmount_SimpleType: {
                ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(block4.MT32A.Amnt),
                Ccy: block4.MT32A.Ccy.content
            }
        },
        IntrBkSttlmDt: convertToISOStandardDate(block4.MT32A.Dt),
        PmtId: {
            EndToEndId: block4.MT21.Ref.content,
            InstrId: block4.MT20.msgId.content,
            UETR: block3?.NdToNdTxRef?.value,
            TxId: block4.MT21.Ref.content
        },
        PmtTpInf: {
            SvcLvl: [{
                Cd: (check getMT2XXSenderToReceiverInfo(block4.MT72))[4]
            }], 
            CtgyPurp: (check getMT2XXSenderToReceiverInfo(block4.MT72))[6],
            LclInstrm: (check getMT2XXSenderToReceiverInfo(block4.MT72))[5]
        },
        SttlmTmReq: {
            CLSTm: getTimeIndication(block4.MT13C)[0]
        },
        SttlmTmIndctn: {
            CdtDtTm: getTimeIndication(block4.MT13C)[1],
            DbtDtTm: getTimeIndication(block4.MT13C)[2]
        },
        Dbtr: {
            FinInstnId: {
                BICFI: block4.MT52A?.IdnCd?.content,
                LEI: getPartyIdentifier(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn),
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
                BICFI: block4.MT56A?.IdnCd?.content,
                ClrSysMmbId: {
                    MmbId: "", 
                    ClrSysId: {
                        Cd: getPartyIdentifierOrAccount2(block4.MT56A?.PrtyIdn, block4.MT56D?.PrtyIdn)[0]
                    }
                },
                Nm: getName(block4.MT56D?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(block4.MT56D?.AdrsLine)
                }
            }
        },
        IntrmyAgt1Acct: {
            Id: {
                IBAN: getPartyIdentifierOrAccount2(block4.MT56A?.PrtyIdn, block4.MT56D?.PrtyIdn)[1],
                Othr: {
                    Id: getPartyIdentifierOrAccount2(block4.MT56A?.PrtyIdn, block4.MT56D?.PrtyIdn)[2],
                    SchmeNm: {
                        Cd: getSchemaCode(prtyIdn1 = block4.MT56A?.PrtyIdn, prtyIdn2 = block4.MT56D?.PrtyIdn)
                    }
                }
            }
        },
        InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(block4.MT72))[1],
        InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(block4.MT72))[0],
        RmtInf: (check getMT2XXSenderToReceiverInfo(block4.MT72))[7],
        Purp: (check getMT2XXSenderToReceiverInfo(block4.MT72))[8],
        UndrlygCstmrCdtTrf: {
            Dbtr: {
                Id: {
                    OrgId: {
                        AnyBIC: block4.UndrlygCstmrCdtTrf.MT50A?.IdnCd?.content,
                        Othr: getOtherId(block4.UndrlygCstmrCdtTrf.MT50A?.Acc, block4.UndrlygCstmrCdtTrf.MT50K?.Acc)
                    },
                    PrvtId: {
                        Othr: [
                            {
                                Id: getPartyIdentifierOrAccount(block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn)[0],
                                SchmeNm: {
                                    Cd: getPartyIdentifierOrAccount(block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn)[3]
                                },
                                Issr: getPartyIdentifierOrAccount(block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn)[4]
                            }
                        ]
                    }
                },
                Nm: getName(block4.UndrlygCstmrCdtTrf.MT50F?.Nm, block4.UndrlygCstmrCdtTrf.MT50K?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(block4.UndrlygCstmrCdtTrf.MT50F?.AdrsLine, block4.UndrlygCstmrCdtTrf.MT50K?.AdrsLine),
                    Ctry: getCountryAndTown(block4.UndrlygCstmrCdtTrf.MT50F?.CntyNTw)[0],
                    TwnNm: getCountryAndTown(block4.UndrlygCstmrCdtTrf.MT50F?.CntyNTw)[1]
                }
            },
            DbtrAcct: {
                Id: {
                    IBAN: getAccountId(validateAccountNumber(block4.UndrlygCstmrCdtTrf.MT50A?.Acc, acc2 = block4.UndrlygCstmrCdtTrf.MT50K?.Acc)[0], getPartyIdentifierOrAccount(block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn)[1]),
                    Othr: {
                        Id: getAccountId(validateAccountNumber(block4.UndrlygCstmrCdtTrf.MT50A?.Acc, acc2 = block4.UndrlygCstmrCdtTrf.MT50K?.Acc)[1], getPartyIdentifierOrAccount(block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn)[2]),
                        SchmeNm: {
                            Cd: getSchemaCode(block4.UndrlygCstmrCdtTrf.MT50A?.Acc, block4.UndrlygCstmrCdtTrf.MT50K?.Acc, prtyIdn1 = block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn)
                        }
                    }
                }
            },
            DbtrAgt: {
                FinInstnId: {
                    BICFI: ordgInstn52A?.IdnCd?.content,
                    LEI: getPartyIdentifier(ordgInstn52A?.PrtyIdn, ordgInstn52D?.PrtyIdn),
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(ordgInstn52D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(ordgInstn52D?.AdrsLine)
                    }
                }
            },
            DbtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = ordgInstn52A?.PrtyIdn, prtyIdn2 = ordgInstn52D?.PrtyIdn)
                        }
                    }
                }
            },
            InstdAmt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(instrdAmnt = block4.UndrlygCstmrCdtTrf.MT33B),
                    Ccy: getMandatoryFields(block4.UndrlygCstmrCdtTrf.MT33B?.Ccy?.content)
                }
            },
            IntrmyAgt1: {
                FinInstnId: {
                    BICFI: block4.UndrlygCstmrCdtTrf.MT56A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(block4.UndrlygCstmrCdtTrf.MT56A?.PrtyIdn, block4.UndrlygCstmrCdtTrf.MT56D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(block4.UndrlygCstmrCdtTrf.MT56D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(block4.UndrlygCstmrCdtTrf.MT56D?.AdrsLine)
                    }
                }
            },
            IntrmyAgt1Acct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(block4.UndrlygCstmrCdtTrf.MT56A?.PrtyIdn, block4.UndrlygCstmrCdtTrf.MT56D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(block4.UndrlygCstmrCdtTrf.MT56A?.PrtyIdn, block4.UndrlygCstmrCdtTrf.MT56D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = block4.UndrlygCstmrCdtTrf.MT56A?.PrtyIdn, prtyIdn2 = block4.UndrlygCstmrCdtTrf.MT56D?.PrtyIdn)
                        }
                    }
                }
            },
            CdtrAgt: {
                FinInstnId: {
                    BICFI: cdtrAgt57A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(cdtrAgt57A?.PrtyIdn, cdtrAgt57B?.PrtyIdn, cdtrAgt57C?.PrtyIdn, cdtrAgt57D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(cdtrAgt57D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(cdtrAgt57D?.AdrsLine, address3 = cdtrAgt57B?.Lctn?.content)
                    }
                }
            },
            CdtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(cdtrAgt57A?.PrtyIdn, cdtrAgt57B?.PrtyIdn, cdtrAgt57C?.PrtyIdn, cdtrAgt57D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(cdtrAgt57A?.PrtyIdn, cdtrAgt57B?.PrtyIdn, cdtrAgt57C?.PrtyIdn, cdtrAgt57D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = cdtrAgt57A?.PrtyIdn, prtyIdn2 = cdtrAgt57B?.PrtyIdn, prtyIdn3 = cdtrAgt57C?.PrtyIdn, prtyIdn4 = cdtrAgt57D?.PrtyIdn)
                        }
                    }
                }
            },
            Cdtr: {
                Id: {
                    OrgId: {
                        AnyBIC: block4.UndrlygCstmrCdtTrf.MT59A?.IdnCd?.content,
                        Othr: getOtherId(block4.UndrlygCstmrCdtTrf.MT59?.Acc, block4.UndrlygCstmrCdtTrf.MT59A?.Acc, block4.UndrlygCstmrCdtTrf.MT59F?.Acc)
                    }
                },
                Nm: getName(block4.UndrlygCstmrCdtTrf.MT59F?.Nm, block4.UndrlygCstmrCdtTrf.MT59?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(block4.UndrlygCstmrCdtTrf.MT59F?.AdrsLine, block4.UndrlygCstmrCdtTrf.MT59?.AdrsLine),
                    Ctry: getCountryAndTown(block4.UndrlygCstmrCdtTrf.MT59F?.CntyNTw)[0],
                    TwnNm: getCountryAndTown(block4.UndrlygCstmrCdtTrf.MT59F?.CntyNTw)[1]
                }
            },
            CdtrAcct: {
                Id: {
                    IBAN: validateAccountNumber(block4.UndrlygCstmrCdtTrf.MT59F?.Acc, acc2 = block4.UndrlygCstmrCdtTrf.MT59?.Acc, acc3 = block4.UndrlygCstmrCdtTrf.MT59A?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(block4.UndrlygCstmrCdtTrf.MT59F?.Acc, acc2 = block4.UndrlygCstmrCdtTrf.MT59?.Acc, acc3 = block4.UndrlygCstmrCdtTrf.MT59A?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(block4.UndrlygCstmrCdtTrf.MT59F?.Acc, block4.UndrlygCstmrCdtTrf.MT59?.Acc, block4.UndrlygCstmrCdtTrf.MT59A?.Acc)
                        }
                    }
                }
            },
            InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(block4.UndrlygCstmrCdtTrf.MT72))[1],
            InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(block4.UndrlygCstmrCdtTrf.MT72))[0],
            RmtInf: {Ustrd: [getRemmitanceInformation(block4.UndrlygCstmrCdtTrf.MT70?.Nrtv?.content)], Strd: []}
        }
    });
    return cdtTrfTxInfArray;
}

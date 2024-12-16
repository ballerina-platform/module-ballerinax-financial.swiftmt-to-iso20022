// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
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

# Transforms the given SWIFT MT103REMIT message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT103REMIT message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103REMIT message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103REMITToPacs008(swiftmt:MT103REMITMessage message) returns pacsIsoRecord:Pacs008Document|error => {
    FIToFICstmrCdtTrf: {
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
                },
                ThrdRmbrsmntAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT55A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT55A?.PrtyIdn, message.block4.MT55B?.PrtyIdn, message.block4.MT55D?.PrtyIdn)[0]
                            }
                        },
                        Nm: getName(message.block4.MT55D?.Nm),
                        PstlAdr: {
                            AdrLine: getAddressLine(message.block4.MT55D?.AdrsLine, address3 = message.block4.MT55B?.Lctn?.content)
                        }
                    }
                }
            },
            InstgAgt: {
                FinInstnId: {
                    BICFI: message.block4.MT51A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: message.block4.MT51A?.PrtyIdn?.content
                        }
                    }
                }
            },
            InstdAgt: {
                FinInstnId: {
                    BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                }
            },
            NbOfTxs: DEFAULT_NUM_OF_TX,
            TtlIntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                    Ccy: message.block4.MT32A.Ccy.content
                }
            },
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: [
            {
                Cdtr: {
                    Id: {
                        OrgId: {
                            AnyBIC: message.block4.MT59A?.IdnCd?.content,
                            Othr: getOtherId(message.block4.MT59?.Acc, message.block4.MT59A?.Acc, message.block4.MT59F?.Acc)
                        }
                    },
                    Nm: getName(message.block4.MT59F?.Nm, message.block4.MT59?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(message.block4.MT59F?.AdrsLine, message.block4.MT59?.AdrsLine),
                        Ctry: getCountryAndTown(message.block4.MT59F?.CntyNTw)[0],
                        TwnNm: getCountryAndTown(message.block4.MT59F?.CntyNTw)[1]
                    }
                },
                CdtrAcct: {
                    Id: {
                        IBAN: validateAccountNumber(message.block4.MT59F?.Acc, acc2 = message.block4.MT59?.Acc, acc3 = message.block4.MT59A?.Acc)[0],
                        Othr: {
                            Id: validateAccountNumber(message.block4.MT59F?.Acc, acc2 = message.block4.MT59?.Acc, acc3 = message.block4.MT59A?.Acc)[1],
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT59F?.Acc, message.block4.MT59?.Acc, message.block4.MT59A?.Acc)
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
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[0]
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
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT57A?.PrtyIdn, prtyIdn2 = message.block4.MT57B?.PrtyIdn, prtyIdn3 = message.block4.MT57C?.PrtyIdn, prtyIdn4 = message.block4.MT57D?.PrtyIdn)
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
                PmtId: {
                    EndToEndId: "",
                    InstrId: message.block4.MT20.msgId.content,
                    UETR: message.block3?.NdToNdTxRef?.value
                },
                SttlmTmReq: {
                    CLSTm: getTimeIndication(message.block4.MT13C)[0]
                },
                SttlmTmIndctn: {
                    CdtDtTm: getTimeIndication(message.block4.MT13C)[1],
                    DbtDtTm: getTimeIndication(message.block4.MT13C)[2]
                },
                PmtTpInf: {
                    SvcLvl: [
                        {
                            Cd: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[2]
                        }
                    ],
                    CtgyPurp: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[3]
                },
                IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                InstdAmt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(instrdAmnt = message.block4.MT33B, stlmntAmnt = message.block4.MT32A),
                        Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, message.block4.MT32A.Ccy.content)
                    }
                },
                DbtrAgt: {
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
                DbtrAgtAcct: {
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
                ChrgBr: check getDetailsChargesCd(message.block4.MT71A.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
                DbtrAcct: {
                    Id: {
                        IBAN: getAccountId(validateAccountNumber(message.block4.MT50A?.Acc, acc2 = message.block4.MT50K?.Acc)[0], getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[1]),
                        Othr: {
                            Id: getAccountId(validateAccountNumber(message.block4.MT50A?.Acc, acc2 = message.block4.MT50K?.Acc)[1], getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[2]),
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc, prtyIdn1 = message.block4.MT50F?.PrtyIdn)
                            }
                        }
                    }
                },
                Dbtr: {
                    Id: {
                        OrgId: {
                            AnyBIC: message.block4.MT50A?.IdnCd?.content,
                            Othr: getOtherId(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc)
                        },
                        PrvtId: {
                            Othr: [
                                {
                                    Id: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[0],
                                    SchmeNm: {
                                        Cd: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[3]
                                    },
                                    Issr: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[4]
                                }
                            ]
                        }
                    },
                    Nm: getName(message.block4.MT50F?.Nm, message.block4.MT50K?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(message.block4.MT50F?.AdrsLine, message.block4.MT50K?.AdrsLine),
                        Ctry: getCountryAndTown(message.block4.MT50F?.CntyNTw)[0],
                        TwnNm: getCountryAndTown(message.block4.MT50F?.CntyNTw)[1]
                    }
                },
                PrvsInstgAgt1: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[2],
                IntrmyAgt1: {
                    FinInstnId: {
                        BICFI: message.block4.MT56A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0]
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
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT56A?.PrtyIdn, prtyIdn2 = message.block4.MT56C?.PrtyIdn, prtyIdn3 = message.block4.MT56D?.PrtyIdn)
                            }
                        }
                    }
                },
                IntrmyAgt2: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[3],
                ChrgsInf: check getChargesInformation(message.block4.MT71F, message.block4.MT71G),
                RgltryRptg: getRegulatoryReporting(message.block4.MT77B?.Nrtv?.content),
                RmtInf: {Ustrd: [check getEnvelopeContent(message.block4.MT77T.EnvCntnt.content)[0].ensureType(string)], Strd: []},
                InstrForNxtAgt: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[1],
                InstrForCdtrAgt: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[0],
                Purp: {
                    Prtry: getMandatoryFields(message.block4.MT26T?.Typ?.content)
                },
                SplmtryData: [
                    {
                        Envlp: {
                            Nrtv: getEnvelopeContent(message.block4.MT77T.EnvCntnt.content)[2],
                            XmlContent: getEnvelopeContent(message.block4.MT77T.EnvCntnt.content)[1]
                        }
                    }
                ]
            }
        ]
    }
};

# Transforms the given SWIFT MT103STP message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT103STP message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103STP message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103STPToPacs008(swiftmt:MT103STPMessage message) returns pacsIsoRecord:Pacs008Document|error => {
    FIToFICstmrCdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            SttlmInf: {
                SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B),
                InstgRmbrsmntAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT53A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn)[0]
                            }
                        },
                        PstlAdr: {
                            AdrLine: getAddressLine((), address3 = message.block4.MT53B?.Lctn?.content)
                        }
                    }
                },
                InstgRmbrsmntAgtAcct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT53A?.PrtyIdn, prtyIdn2 = message.block4.MT53B?.PrtyIdn)
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
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT54A?.PrtyIdn)[0]
                            }
                        }
                    }
                },
                InstdRmbrsmntAgtAcct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT54A?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT54A?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT54A?.PrtyIdn)
                            }
                        }
                    }
                },
                ThrdRmbrsmntAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT55A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT55A?.PrtyIdn)[0]
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
            TtlIntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                    Ccy: message.block4.MT32A.Ccy.content
                }
            },
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: [
            {
                Cdtr: {
                    Id: {
                        OrgId: {
                            AnyBIC: message.block4.MT59A?.IdnCd?.content,
                            Othr: getOtherId(message.block4.MT59?.Acc, message.block4.MT59A?.Acc, message.block4.MT59F?.Acc)
                        }
                    },
                    Nm: getName(message.block4.MT59F?.Nm, message.block4.MT59?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(message.block4.MT59F?.AdrsLine, message.block4.MT59?.AdrsLine),
                        Ctry: getCountryAndTown(message.block4.MT59F?.CntyNTw)[0],
                        TwnNm: getCountryAndTown(message.block4.MT59F?.CntyNTw)[1]
                    }
                },
                CdtrAcct: {
                    Id: {
                        IBAN: validateAccountNumber(message.block4.MT59F?.Acc, acc2 = message.block4.MT59?.Acc, acc3 = message.block4.MT59A?.Acc)[0],
                        Othr: {
                            Id: validateAccountNumber(message.block4.MT59F?.Acc, acc2 = message.block4.MT59?.Acc, acc3 = message.block4.MT59A?.Acc)[1],
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT59F?.Acc, message.block4.MT59?.Acc, message.block4.MT59A?.Acc)
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
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn)[0]
                            }
                        }
                    }
                },
                CdtrAgtAcct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn)[0],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn)[0],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT57A?.PrtyIdn)
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
                PmtId: {
                    EndToEndId: getEndToEndId(remmitanceInfo = message.block4.MT70?.Nrtv?.content),
                    InstrId: message.block4.MT20.msgId.content,
                    UETR: message.block3?.NdToNdTxRef?.value
                },
                SttlmTmReq: {
                    CLSTm: getTimeIndication(message.block4.MT13C)[0]
                },
                SttlmTmIndctn: {
                    CdtDtTm: getTimeIndication(message.block4.MT13C)[1],
                    DbtDtTm: getTimeIndication(message.block4.MT13C)[2]
                },
                PmtTpInf: {
                    SvcLvl: [
                        {
                            Cd: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[2]
                        }
                    ],
                    CtgyPurp: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[3]
                },
                IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                InstdAmt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(instrdAmnt = message.block4.MT33B, stlmntAmnt = message.block4.MT32A),
                        Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, message.block4.MT32A.Ccy.content)
                    }
                },
                DbtrAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT52A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT52A?.PrtyIdn)[0]
                            }
                        }
                    }
                },
                DbtrAgtAcct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT52A?.PrtyIdn)[0],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT52A?.PrtyIdn)[0],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT52A?.PrtyIdn)
                            }
                        }
                    }
                },
                ChrgBr: check getDetailsChargesCd(message.block4.MT71A.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
                DbtrAcct: {
                    Id: {
                        IBAN: getAccountId(validateAccountNumber(message.block4.MT50A?.Acc, acc2 = message.block4.MT50K?.Acc)[0], getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[1]),
                        Othr: {
                            Id: getAccountId(validateAccountNumber(message.block4.MT50A?.Acc, acc2 = message.block4.MT50K?.Acc)[1], getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[2]),
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc, prtyIdn1 = message.block4.MT50F?.PrtyIdn)
                            }
                        }
                    }
                },
                Dbtr: {
                    Id: {
                        OrgId: {
                            AnyBIC: message.block4.MT50A?.IdnCd?.content,
                            Othr: getOtherId(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc)
                        },
                        PrvtId: {
                            Othr: [
                                {
                                    Id: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[0],
                                    SchmeNm: {
                                        Cd: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[3]
                                    },
                                    Issr: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[4]
                                }
                            ]
                        }
                    },
                    Nm: getName(message.block4.MT50F?.Nm, message.block4.MT50K?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(message.block4.MT50F?.AdrsLine, message.block4.MT50K?.AdrsLine),
                        Ctry: getCountryAndTown(message.block4.MT50F?.CntyNTw)[0],
                        TwnNm: getCountryAndTown(message.block4.MT50F?.CntyNTw)[1]
                    }
                },
                PrvsInstgAgt1: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[2],
                IntrmyAgt1: {
                    FinInstnId: {
                        BICFI: message.block4.MT56A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn)[0]
                            }
                        }
                    }
                },
                IntrmyAgt1Acct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn)[0],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn)[0],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT56A?.PrtyIdn)
                            }
                        }
                    }
                },
                IntrmyAgt2: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[3],
                ChrgsInf: check getChargesInformation(message.block4.MT71F, message.block4.MT71G),
                RgltryRptg: getRegulatoryReporting(message.block4.MT77B?.Nrtv?.content),
                RmtInf: {Ustrd: [getRemmitanceInformation(message.block4.MT70?.Nrtv?.content)], Strd: []},
                InstrForNxtAgt: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[1],
                InstrForCdtrAgt: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[0],
                Purp: {
                    Prtry: getMandatoryFields(message.block4.MT26T?.Typ?.content)
                }
            }
        ]
    }
};

# Transforms the given SWIFT MT103 message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT103 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103ToPacs008(swiftmt:MT103Message message) returns pacsIsoRecord:Pacs008Document|error => {
    FIToFICstmrCdtTrf: {
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
                },
                ThrdRmbrsmntAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT55A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT55A?.PrtyIdn, message.block4.MT55B?.PrtyIdn, message.block4.MT55D?.PrtyIdn)[0]
                            }
                        },
                        Nm: getName(message.block4.MT55D?.Nm),
                        PstlAdr: {
                            AdrLine: getAddressLine(message.block4.MT55D?.AdrsLine, address3 = message.block4.MT55B?.Lctn?.content)
                        }
                    }
                }
            },
            InstgAgt: {
                FinInstnId: {
                    BICFI: message.block4.MT51A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: message.block4.MT51A?.PrtyIdn?.content
                        }
                    }
                }
            },
            InstdAgt: {
                FinInstnId: {
                    BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                }
            },
            NbOfTxs: DEFAULT_NUM_OF_TX,
            TtlIntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                    Ccy: message.block4.MT32A.Ccy.content
                }
            },
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: [
            {
                Cdtr: {
                    Id: {
                        OrgId: {
                            AnyBIC: message.block4.MT59A?.IdnCd?.content,
                            Othr: getOtherId(message.block4.MT59?.Acc, message.block4.MT59A?.Acc, message.block4.MT59F?.Acc)
                        }
                    },
                    Nm: getName(message.block4.MT59F?.Nm, message.block4.MT59?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(message.block4.MT59F?.AdrsLine, message.block4.MT59?.AdrsLine),
                        Ctry: getCountryAndTown(message.block4.MT59F?.CntyNTw)[0],
                        TwnNm: getCountryAndTown(message.block4.MT59F?.CntyNTw)[1]
                    }
                },
                CdtrAcct: {
                    Id: {
                        IBAN: validateAccountNumber(message.block4.MT59F?.Acc, acc2 = message.block4.MT59?.Acc, acc3 = message.block4.MT59A?.Acc)[0],
                        Othr: {
                            Id: validateAccountNumber(message.block4.MT59F?.Acc, acc2 = message.block4.MT59?.Acc, acc3 = message.block4.MT59A?.Acc)[1],
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT59F?.Acc, message.block4.MT59?.Acc, message.block4.MT59A?.Acc)
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
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[0]
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
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT57A?.PrtyIdn, prtyIdn2 = message.block4.MT57B?.PrtyIdn, prtyIdn3 = message.block4.MT57C?.PrtyIdn, prtyIdn4 = message.block4.MT57D?.PrtyIdn)
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
                PmtId: {
                    EndToEndId: getEndToEndId(remmitanceInfo = message.block4.MT70?.Nrtv?.content),
                    InstrId: message.block4.MT20.msgId.content,
                    UETR: message.block3?.NdToNdTxRef?.value
                },
                SttlmTmReq: {
                    CLSTm: getTimeIndication(message.block4.MT13C)[0]
                },
                SttlmTmIndctn: {
                    CdtDtTm: getTimeIndication(message.block4.MT13C)[1],
                    DbtDtTm: getTimeIndication(message.block4.MT13C)[2]
                },
                PmtTpInf: {
                    SvcLvl: [
                        {
                            Cd: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[2]
                        }
                    ],
                    CtgyPurp: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[3]
                },
                IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                InstdAmt: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(instrdAmnt = message.block4.MT33B, stlmntAmnt = message.block4.MT32A),
                        Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, message.block4.MT32A.Ccy.content)
                    }
                },
                DbtrAgt: {
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
                DbtrAgtAcct: {
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
                ChrgBr: check getDetailsChargesCd(message.block4.MT71A.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
                DbtrAcct: {
                    Id: {
                        IBAN: getAccountId(validateAccountNumber(message.block4.MT50A?.Acc, acc2 = message.block4.MT50K?.Acc)[0], getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[1]),
                        Othr: {
                            Id: getAccountId(validateAccountNumber(message.block4.MT50A?.Acc, acc2 = message.block4.MT50K?.Acc)[1], getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[2]),
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc, prtyIdn1 = message.block4.MT50F?.PrtyIdn)
                            }
                        }
                    }
                },
                Dbtr: {
                    Id: {
                        OrgId: {
                            AnyBIC: message.block4.MT50A?.IdnCd?.content,
                            Othr: getOtherId(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc)
                        },
                        PrvtId: {
                            Othr: [
                                {
                                    Id: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[0],
                                    SchmeNm: {
                                        Cd: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[3]
                                    },
                                    Issr: getPartyIdentifierOrAccount(message.block4.MT50F?.PrtyIdn)[4]
                                }
                            ]
                        }
                    },
                    Nm: getName(message.block4.MT50F?.Nm, message.block4.MT50K?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(message.block4.MT50F?.AdrsLine, message.block4.MT50K?.AdrsLine),
                        Ctry: getCountryAndTown(message.block4.MT50F?.CntyNTw)[0],
                        TwnNm: getCountryAndTown(message.block4.MT50F?.CntyNTw)[1]
                    }
                },
                PrvsInstgAgt1: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[2],
                IntrmyAgt1: {
                    FinInstnId: {
                        BICFI: message.block4.MT56A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0]
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
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn)[0],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT56A?.PrtyIdn, prtyIdn2 = message.block4.MT56C?.PrtyIdn, prtyIdn3 = message.block4.MT56D?.PrtyIdn)
                            }
                        }
                    }
                },
                IntrmyAgt2: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[3],
                ChrgsInf: check getChargesInformation(message.block4.MT71F, message.block4.MT71G),
                RgltryRptg: getRegulatoryReporting(message.block4.MT77B?.Nrtv?.content),
                RmtInf: {Ustrd: [getRemmitanceInformation(message.block4.MT70?.Nrtv?.content)], Strd: []},
                InstrForNxtAgt: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[1],
                InstrForCdtrAgt: (check getInformationForAgents(message.block4.MT23E, message.block4.MT72))[0],
                Purp: {
                    Prtry: getMandatoryFields(message.block4.MT26T?.Typ?.content)
                }
            }
        ]
    }
};

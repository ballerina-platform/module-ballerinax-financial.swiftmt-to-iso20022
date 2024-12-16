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

import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given SWIFT MT101 message to its corresponding ISO 20022 Pain.001 format.
#
# This function extracts various fields from the SWIFT MT101 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT101 message as a record value.
# + return - Returns the transformed ISO 20022 `Pain001Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT101ToPain001(swiftmt:MT101Message message) returns painIsoRecord:Pain001Document|error => {
    CstmrCdtTrfInitn: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            InitgPty: {
                Id: {
                    OrgId: {
                        AnyBIC: message.block4.MT50C?.IdnCd?.content
                    },
                    PrvtId: {
                        Othr: [
                            {
                                Id: getPartyIdentifier(message.block4.MT50L?.PrtyIdn)
                            }
                        ]
                    }
                }
            },
            FwdgAgt: {
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
            NbOfTxs: message.block4.Transaction.length().toString(),
            MsgId: message.block4.MT20.msgId.content
        },
        PmtInf: check getPaymentInformation(message.block4, message.block3)
    }
};

# Extracts payment information from the provided MT101 message and maps it to an array of ISO 20022 PaymentInstruction44 records.
#
# This function iterates over the transactions in the SWIFT MT101 message and retrieves details such as debtor, creditor,
# instructed amount, exchange rate, and intermediary agents. These details are then structured in ISO 20022 format.
#
# + block4 - The parsed block4 of MT101 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT101 SWIFT message containing end to end id.
# + return - Returns an array of PaymentInstruction44 records or an error if an issue occurs while fetching information.
isolated function getPaymentInformation(swiftmt:MT101Block4 block4, swiftmt:Block3? block3) returns painIsoRecord:PaymentInstruction44[]|error {
    painIsoRecord:PaymentInstruction44[] pmtInfArray = [];
    foreach swiftmt:MT101Transaction transaxion in block4.Transaction {
        swiftmt:MT50F? ordgCstm50F = check getMT101RepeatingFields(block4, transaxion.MT50F, "50F").ensureType();
        swiftmt:MT50G? ordgCstm50G = check getMT101RepeatingFields(block4, transaxion.MT50G, "50G").ensureType();
        swiftmt:MT50H? ordgCstm50H = check getMT101RepeatingFields(block4, transaxion.MT50H, "50H").ensureType();
        swiftmt:MT52A? ordgInstn52A = check getMT101RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52C? ordgInstn52C = check getMT101RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();

        pmtInfArray.push({
            PmtInfId: block4.MT20.msgId.content,
            CdtTrfTxInf: [
                {
                    Amt: {
                        InstdAmt: {
                            ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                                ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                                Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                            }
                        }
                    },
                    PmtId: {
                        EndToEndId: getEndToEndId(block4.MT21R?.Ref?.content, transaxion.MT70?.Nrtv?.content, transaxion.MT21.Ref.content),
                        InstrId: block4.MT20.msgId.content,
                        UETR: block3?.NdToNdTxRef?.value
                    },
                    XchgRateInf: {
                        XchgRate: check convertToDecimal(transaxion.MT36?.Rt)
                    },
                    Cdtr: {
                        Id: {
                            OrgId: {
                                AnyBIC: transaxion.MT59A?.IdnCd?.content,
                                Othr: getOtherId(transaxion.MT59?.Acc, transaxion.MT59A?.Acc, transaxion.MT59F?.Acc)
                            }
                        },
                        Nm: getName(transaxion.MT59F?.Nm, transaxion.MT59?.Nm),
                        PstlAdr: {
                            AdrLine: getAddressLine(transaxion.MT59F?.AdrsLine, transaxion.MT59?.AdrsLine),
                            Ctry: getCountryAndTown(transaxion.MT59F?.CntyNTw)[0],
                            TwnNm: getCountryAndTown(transaxion.MT59F?.CntyNTw)[1]
                        }
                    },
                    CdtrAcct: {
                        Id: {
                            IBAN: validateAccountNumber(transaxion.MT59A?.Acc, acc2 = transaxion.MT59?.Acc, acc3 = transaxion.MT59F?.Acc)[0],
                            Othr: {
                                Id: validateAccountNumber(transaxion.MT59A?.Acc, acc2 = transaxion.MT59?.Acc, acc3 = transaxion.MT59F?.Acc)[1],
                                SchmeNm: {
                                    Cd: getSchemaCode(transaxion.MT59A?.Acc, transaxion.MT59?.Acc, transaxion.MT59F?.Acc)
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
                                    Cd: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[0]
                                }
                            },
                            Nm: getName(transaxion.MT57D?.Nm),
                            PstlAdr: {
                                AdrLine: getAddressLine(transaxion.MT57D?.AdrsLine)
                            }
                        }
                    },
                    CdtrAgtAcct: {
                        Id: {
                            IBAN: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[1],
                            Othr: {
                                Id: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[2],
                                SchmeNm: {
                                    Cd: getSchemaCode(prtyIdn1 = transaxion.MT57A?.PrtyIdn, prtyIdn2 = transaxion.MT57C?.PrtyIdn, prtyIdn3 = transaxion.MT57D?.PrtyIdn)
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
                                    Cd: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56C?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[0]
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
                            IBAN: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56C?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[1],
                            Othr: {
                                Id: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56C?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[2],
                                SchmeNm: {
                                    Cd: getSchemaCode(prtyIdn1 = transaxion.MT56A?.PrtyIdn, prtyIdn2 = transaxion.MT56C?.PrtyIdn, prtyIdn3 = transaxion.MT56D?.PrtyIdn)
                                }
                            }
                        }
                    },
                    InstrForDbtrAgt: getMT101InstructionCode(transaxion.MT23E, 1)[0],
                    InstrForCdtrAgt: getMT101InstructionCode(transaxion.MT23E, 1)[1],
                    RgltryRptg: getRegulatoryReporting(transaxion.MT77B?.Nrtv?.content),
                    RmtInf: {Ustrd: [getRemmitanceInformation(transaxion.MT70?.Nrtv?.content)], Strd: []}
                }
            ],
            PmtTpInf: {
                SvcLvl: getMT101InstructionCode(transaxion.MT23E, 1)[2],
                CtgyPurp: getMT101InstructionCode(transaxion.MT23E, 1)[3]
            },
            DbtrAcct: {
                Id: {
                    IBAN: getAccountId(validateAccountNumber(ordgCstm50G?.Acc, acc2 = ordgCstm50H?.Acc)[0], getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[1]),
                    Othr: {
                        Id: getAccountId(validateAccountNumber(ordgCstm50G?.Acc, acc2 = ordgCstm50H?.Acc)[1], getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[2]),
                        SchmeNm: {
                            Cd: getSchemaCode(ordgCstm50G?.Acc, ordgCstm50H?.Acc, prtyIdn1 = ordgCstm50F?.PrtyIdn)
                        }
                    }
                }
            },
            ReqdExctnDt: {
                Dt: convertToISOStandardDate(block4.MT30.Dt),
                DtTm: ""
            },
            DbtrAgt: {
                FinInstnId: {
                    BICFI: ordgInstn52A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52C?.PrtyIdn)[0]
                        }
                    }
                }
            },
            DbtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52C?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52C?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = ordgInstn52A?.PrtyIdn, prtyIdn2 = ordgInstn52C?.PrtyIdn)
                        }
                    }
                }
            },
            Dbtr: {
                Id: {
                    OrgId: {
                        AnyBIC: ordgCstm50G?.IdnCd?.content,
                        Othr: getOtherId(ordgCstm50G?.Acc, ordgCstm50H?.Acc)
                    },
                    PrvtId: {
                        Othr: [
                            {
                                Id: getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[0],
                                SchmeNm: {
                                    Cd: getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[3]
                                },
                                Issr: getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[4]
                            }
                        ]
                    }
                },
                Nm: getName(ordgCstm50F?.Nm, ordgCstm50H?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(ordgCstm50F?.AdrsLine, ordgCstm50H?.AdrsLine),
                    Ctry: getCountryAndTown(ordgCstm50F?.CntyNTw)[0],
                    TwnNm: getCountryAndTown(ordgCstm50F?.CntyNTw)[1]
                }
            },
            PmtMtd: "TRF",
            ChrgBr: check getDetailsChargesCd(transaxion.MT71A.Cd).ensureType(painIsoRecord:ChargeBearerType1Code),
            ChrgsAcct: {
                Id: {
                    IBAN: validateAccountNumber(transaxion.MT25A?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(transaxion.MT25A?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(transaxion.MT25A?.Acc)
                        }
                    }
                }
            }
        }
        );
    }
    return pmtInfArray;
}

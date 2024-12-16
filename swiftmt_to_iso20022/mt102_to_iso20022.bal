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

# Transforms the given SWIFT MT102STP message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT102STP message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT102STP message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure transforming the SWIFT message to ISO 20022 format.
isolated function transformMT102STPToPacs008(swiftmt:MT102STPMessage message) returns pacsIsoRecord:Pacs008Document|error => {
    FIToFICstmrCdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            SttlmInf: {
                SttlmMtd: getSettlementMethod(message.block4.MT53A),
                InstgRmbrsmntAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT53A?.IdnCd?.content,
                        LEI: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[0],
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[0]
                            }
                        }
                    }
                },
                InstgRmbrsmntAgtAcct: {
                    Id: {
                        IBAN: getAccountId(validateAccountNumber(message.block4.MT53C?.Acc)[0], getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[1]),
                        Othr: {
                            Id: getAccountId(validateAccountNumber(message.block4.MT53C?.Acc)[1], getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[2]),
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT53C?.Acc, prtyIdn1 = message.block4.MT53A?.PrtyIdn)
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
            TtlIntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                    Ccy: message.block4.MT32A.Ccy.content
                }
            },
            CtrlSum: check convertToDecimal(message.block4.MT19?.Amnt),
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: check getMT102STPCreditTransferTransactionInfo(message.block4, message.block3)
    }
};

# Processes an MT102 STP message and extracts credit transfer transaction information into ISO 20022 format.
# The function iterates over each transaction within the message, extracts relevant fields, and maps them 
# to the `CreditTransferTransaction64` ISO record structure. It handles various transaction fields such as 
# party identifiers, account information, currency amounts, and regulatory reporting.
#
# + block4 - The parsed block4 of MT102 STP SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT102 STP SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction64` records, each corresponding to a transaction 
# in the input message. If any error occurs during field extraction or conversion, an error will be returned.
isolated function getMT102STPCreditTransferTransactionInfo(swiftmt:MT102STPBlock4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:CreditTransferTransaction64[]|error {
    pacsIsoRecord:CreditTransferTransaction64[] cdtTrfTxInfArray = [];
    foreach swiftmt:MT102STPTransaction transaxion in block4.Transaction {
        swiftmt:MT26T? trnsTyp = check getMT102STPRepeatingFields(block4, transaxion.MT26T, "26T").ensureType();
        swiftmt:MT36? xchgRate = check getMT102STPRepeatingFields(block4, transaxion.MT36, "36").ensureType();
        swiftmt:MT50F? ordgCstm50F = check getMT102STPRepeatingFields(block4, transaxion.MT50F, "50F").ensureType();
        swiftmt:MT50A? ordgCstm50A = check getMT102STPRepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50K? ordgCstm50K = check getMT102STPRepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT52A? ordgInstn52A = check getMT102STPRepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT71A? dtlsChrgsCd = check getMT102STPRepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltyRptg = check getMT102STPRepeatingFields(block4, transaxion.MT77B, "77B").ensureType();

        cdtTrfTxInfArray.push({
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
                    IBAN: validateAccountNumber(transaxion.MT59F?.Acc, acc2 = transaxion.MT59?.Acc, acc3 = transaxion.MT59A?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(transaxion.MT59F?.Acc, acc2 = transaxion.MT59?.Acc, acc3 = transaxion.MT59A?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(transaxion.MT59F?.Acc, transaxion.MT59?.Acc, transaxion.MT59A?.Acc)
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
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn)[0]
                        }
                    }
                }
            },
            CdtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT57A?.PrtyIdn)
                        }
                    }
                }
            },
            IntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                    Ccy: transaxion.MT32B.Ccy.content
                }
            },
            PmtId: {
                EndToEndId: getEndToEndId(remmitanceInfo = transaxion.MT70?.Nrtv?.content, transactionId = transaxion.MT21.Ref.content),
                InstrId: block4.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value,
                TxId: transaxion.MT21.Ref.content
            },
            PmtTpInf: {
                SvcLvl: [
                    {
                        Cd: (check getMT1XXSenderToReceiverInformation(block4.MT72))[4]
                    }
                ],
                LclInstrm: (check getMT1XXSenderToReceiverInformation(block4.MT72))[5],
                CtgyPurp: (check getMT1XXSenderToReceiverInformation(block4.MT72))[6]
            },
            SttlmTmReq: {
                CLSTm: getTimeIndication(block4.MT13C)[0]
            },
            SttlmTmIndctn: {
                CdtDtTm: getTimeIndication(block4.MT13C)[1],
                DbtDtTm: getTimeIndication(block4.MT13C)[2]
            },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT32A.Dt),
            XchgRate: check convertToDecimal(xchgRate?.Rt),
            InstdAmt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                    Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                }
            },
            DbtrAgt: {
                FinInstnId: {
                    BICFI: ordgInstn52A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn)[0]
                        }
                    }
                }
            },
            DbtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = ordgInstn52A?.PrtyIdn)
                        }
                    }
                }
            },
            ChrgBr: check getDetailsChargesCd(dtlsChrgsCd?.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
            DbtrAcct: {
                Id: {
                    IBAN: getAccountId(validateAccountNumber(ordgCstm50A?.Acc, acc2 = ordgCstm50K?.Acc)[0], getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[1]),
                    Othr: {
                        Id: getAccountId(validateAccountNumber(ordgCstm50A?.Acc, acc2 = ordgCstm50K?.Acc)[1], getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[2]),
                        SchmeNm: {
                            Cd: getSchemaCode(ordgCstm50A?.Acc, ordgCstm50K?.Acc, prtyIdn1 = ordgCstm50F?.PrtyIdn)
                        }
                    }
                }
            },
            Dbtr: {
                Id: {
                    OrgId: {
                        AnyBIC: ordgCstm50A?.IdnCd?.content,
                        Othr: getOtherId(ordgCstm50A?.Acc, ordgCstm50K?.Acc)
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
                Nm: getName(ordgCstm50F?.Nm, ordgCstm50K?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(ordgCstm50F?.AdrsLine, ordgCstm50K?.AdrsLine),
                    Ctry: getCountryAndTown(ordgCstm50F?.CntyNTw)[0],
                    TwnNm: getCountryAndTown(ordgCstm50F?.CntyNTw)[1]
                }
            },
            PrvsInstgAgt1: (check getMT1XXSenderToReceiverInformation(block4.MT72))[2],
            IntrmyAgt1: (check getMT1XXSenderToReceiverInformation(block4.MT72))[3],
            ChrgsInf: check getChargesInformation(transaxion.MT71F, transaxion.MT71G),
            RgltryRptg: getRegulatoryReporting(rgltyRptg?.Nrtv?.content),
            RmtInf: {Ustrd: [getRemmitanceInformation(transaxion.MT70?.Nrtv?.content)], Strd: []},
            InstrForNxtAgt: (check getMT1XXSenderToReceiverInformation(block4.MT72))[1],
            InstrForCdtrAgt: (check getMT1XXSenderToReceiverInformation(block4.MT72))[0],
            Purp: {
                Prtry: getMandatoryFields(trnsTyp?.Typ?.content)
            }
        });
    }
    return cdtTrfTxInfArray;
}

# Transforms the given SWIFT MT102 message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT102 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT102 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT102ToPcs008(swiftmt:MT102Message message) returns pacsIsoRecord:Pacs008Document|error => {
    FIToFICstmrCdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            SttlmInf: {
                SttlmMtd: getSettlementMethod(message.block4.MT53A),
                InstgRmbrsmntAgt: {
                    FinInstnId: {
                        BICFI: message.block4.MT53A?.IdnCd?.content,
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[0]
                            }
                        }
                    }
                },
                InstgRmbrsmntAgtAcct: {
                    Id: {
                        IBAN: getAccountId(validateAccountNumber(message.block4.MT53C?.Acc)[0], getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[1]),
                        Othr: {
                            Id: getAccountId(validateAccountNumber(message.block4.MT53C?.Acc)[1], getPartyIdentifierOrAccount2(message.block4.MT53A?.PrtyIdn)[2]),
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT53C?.Acc, prtyIdn1 = message.block4.MT53A?.PrtyIdn)
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
            NbOfTxs: message.block4.Transaction.length().toString(),
            TtlIntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check getTotalInterBankSettlementAmount(message.block4.MT19, message.block4.MT32A),
                    Ccy: message.block4.MT32A.Ccy.content
                }
            },
            MsgId: message.block4.MT20.msgId.content
        },
        CdtTrfTxInf: check getMT102CreditTransferTransactionInfo(message.block4, message.block3)
    }
};

# Processes an MT102 message and extracts credit transfer transaction information into ISO 20022 format.
# The function iterates over each transaction within the message, extracts relevant fields, and maps them 
# to the `CreditTransferTransaction64` ISO record structure. It handles various transaction fields such as 
# party identifiers, account information, currency amounts, and regulatory reporting.
#
# + block4 - The parsed block4 of MT102 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT102 SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction64` records, each corresponding to a transaction 
# in the input message. If any error occurs during field extraction or conversion, an error will be returned.
isolated function getMT102CreditTransferTransactionInfo(swiftmt:MT102Block4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:CreditTransferTransaction64[]|error {
    pacsIsoRecord:CreditTransferTransaction64[] cdtTrfTxInfArray = [];
    foreach swiftmt:MT102Transaction transaxion in block4.Transaction {
        swiftmt:MT26T? trnsTyp = check getMT102RepeatingFields(block4, transaxion.MT26T, "26T").ensureType();
        swiftmt:MT36? xchgRate = check getMT102RepeatingFields(block4, transaxion.MT36, "36").ensureType();
        swiftmt:MT50F? ordgCstm50F = check getMT102RepeatingFields(block4, transaxion.MT50F, "50F").ensureType();
        swiftmt:MT50A? ordgCstm50A = check getMT102RepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50K? ordgCstm50K = check getMT102RepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT52A? ordgInstn52A = check getMT102RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52B? ordgInstn52B = check getMT102RepeatingFields(block4, transaxion.MT52B, "52B").ensureType();
        swiftmt:MT52C? ordgInstn52C = check getMT102RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        swiftmt:MT71A? dtlsChrgsCd = check getMT102RepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltyRptg = check getMT102RepeatingFields(block4, transaxion.MT77B, "77B").ensureType();

        cdtTrfTxInfArray.push({
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
                    IBAN: validateAccountNumber(transaxion.MT59F?.Acc, acc2 = transaxion.MT59?.Acc, acc3 = transaxion.MT59A?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(transaxion.MT59F?.Acc, acc2 = transaxion.MT59?.Acc, acc3 = transaxion.MT59A?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(transaxion.MT59F?.Acc, transaxion.MT59?.Acc, transaxion.MT59A?.Acc)
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
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn)[0]
                        }
                    }
                }
            },
            CdtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT57A?.PrtyIdn, prtyIdn2 = transaxion.MT57C?.PrtyIdn)
                        }
                    }
                }
            },
            IntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                    Ccy: transaxion.MT32B.Ccy.content
                }
            },
            PmtId: {
                EndToEndId: getEndToEndId(remmitanceInfo = transaxion.MT70?.Nrtv?.content, transactionId = transaxion.MT21.Ref.content),
                InstrId: block4.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value,
                TxId: transaxion.MT21.Ref.content
            },
            PmtTpInf: {
                SvcLvl: [
                    {
                        Cd: (check getMT1XXSenderToReceiverInformation(block4.MT72))[4]
                    }
                ],
                LclInstrm: (check getMT1XXSenderToReceiverInformation(block4.MT72))[5],
                CtgyPurp: (check getMT1XXSenderToReceiverInformation(block4.MT72))[6]
            },
            SttlmTmReq: {
                CLSTm: getTimeIndication(block4.MT13C)[0]
            },
            SttlmTmIndctn: {
                CdtDtTm: getTimeIndication(block4.MT13C)[1],
                DbtDtTm: getTimeIndication(block4.MT13C)[2]
            },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT32A.Dt),
            XchgRate: check convertToDecimal(xchgRate?.Rt),
            InstdAmt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                    Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                }
            },
            DbtrAgt: {
                FinInstnId: {
                    BICFI: ordgInstn52A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52B?.PrtyIdn, ordgInstn52C?.PrtyIdn)[0]
                        }
                    },
                    PstlAdr: {
                        AdrLine: getAddressLine((), address3 = ordgInstn52B?.Lctn?.content)
                    }
                }
            },
            DbtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52B?.PrtyIdn, ordgInstn52C?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(ordgInstn52A?.PrtyIdn, ordgInstn52B?.PrtyIdn, ordgInstn52C?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = ordgInstn52A?.PrtyIdn, prtyIdn2 = ordgInstn52B?.PrtyIdn, prtyIdn3 = ordgInstn52C?.PrtyIdn)
                        }
                    }
                }
            },
            ChrgBr: check getDetailsChargesCd(dtlsChrgsCd?.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
            DbtrAcct: {
                Id: {
                    IBAN: getAccountId(validateAccountNumber(ordgCstm50A?.Acc, acc2 = ordgCstm50K?.Acc)[0], getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[1]),
                    Othr: {
                        Id: getAccountId(validateAccountNumber(ordgCstm50A?.Acc, acc2 = ordgCstm50K?.Acc)[1], getPartyIdentifierOrAccount(ordgCstm50F?.PrtyIdn)[2]),
                        SchmeNm: {
                            Cd: getSchemaCode(ordgCstm50A?.Acc, ordgCstm50K?.Acc, prtyIdn1 = ordgCstm50F?.PrtyIdn)
                        }
                    }
                }
            },
            Dbtr: {
                Id: {
                    OrgId: {
                        AnyBIC: ordgCstm50A?.IdnCd?.content,
                        Othr: getOtherId(ordgCstm50A?.Acc, ordgCstm50K?.Acc)
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
                Nm: getName(ordgCstm50F?.Nm, ordgCstm50K?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(ordgCstm50F?.AdrsLine, ordgCstm50K?.AdrsLine),
                    Ctry: getCountryAndTown(ordgCstm50F?.CntyNTw)[0],
                    TwnNm: getCountryAndTown(ordgCstm50F?.CntyNTw)[1]
                }
            },
            PrvsInstgAgt1: (check getMT1XXSenderToReceiverInformation(block4.MT72))[2],
            IntrmyAgt1: (check getMT1XXSenderToReceiverInformation(block4.MT72))[3],
            ChrgsInf: check getChargesInformation(transaxion.MT71F, transaxion.MT71G),
            RgltryRptg: getRegulatoryReporting(rgltyRptg?.Nrtv?.content),
            RmtInf: {Ustrd: [getRemmitanceInformation(transaxion.MT70?.Nrtv?.content)], Strd: []},
            InstrForNxtAgt: (check getMT1XXSenderToReceiverInformation(block4.MT72))[1],
            InstrForCdtrAgt: (check getMT1XXSenderToReceiverInformation(block4.MT72))[0],
            Purp: {
                Prtry: getMandatoryFields(trnsTyp?.Typ?.content)
            }
        });
    }
    return cdtTrfTxInfArray;
}

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
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given SWIFT MT104 message to its corresponding ISO 20022 Pacs.003 format.
#
# This function extracts various fields from the SWIFT MT104 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT104 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs003Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT104ToPacs003(swiftmt:MT104Message message) returns pacsIsoRecord:Pacs003Document|error => {
    FIToFICstmrDrctDbt: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            SttlmInf: {
                SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B)
            },
            NbOfTxs: message.block4.Transaction.length().toString(),
            TtlIntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32B.Amnt),
                    Ccy: message.block4.MT32B.Ccy.content
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
            MsgId: message.block4.MT20.msgId.content
        },
        DrctDbtTxInf: check getDirectDebitTransactionInfoMT104(message.block4, message.block3)
    }
};

# Processes an MT104 direct debit message and extracts direct debit transaction information into ISO 20022 format.
# The function iterates over each transaction within the message, extracts relevant fields, and maps them 
# to the `DirectDebitTransactionInformation31` ISO record structure. It handles various transaction fields 
# such as party identifiers, account information, settlement details, and remittance information.
#
# + block4 - The parsed block4 of MT104 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT104 SWIFT message containing end to end id.
# + return - Returns an array of `DirectDebitTransactionInformation31` records, each corresponding to a transaction 
# in the input message. If any error occurs during field extraction or conversion, an error will be returned.
isolated function getDirectDebitTransactionInfoMT104(swiftmt:MT104Block4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:DirectDebitTransactionInformation31[]|error {
    pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInfArray = [];
    foreach swiftmt:MT104Transaction transaxion in block4.Transaction {
        swiftmt:MT23E? instrCd = check getMT104RepeatingFields(block4, transaxion.MT23E, "23E").ensureType();
        swiftmt:MT50A? creditor50A = check getMT104RepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50C? instgPrty50C = check getMT104RepeatingFields(block4, transaxion.MT50C, "50C").ensureType();
        swiftmt:MT50K? creditor50K = check getMT104RepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT50L? instgPrty50L = check getMT104RepeatingFields(block4, transaxion.MT50L, "50L").ensureType();
        swiftmt:MT52A? accWthInstn52A = check getMT104RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52C? accWthInstn52C = check getMT104RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        swiftmt:MT52D? accWthInstn52D = check getMT104RepeatingFields(block4, transaxion.MT52D, "52D").ensureType();
        swiftmt:MT71A? dtlsOfChrgs = check getMT104RepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltryRptg = check getMT104RepeatingFields(block4, transaxion.MT77B, "77B").ensureType();

        drctDbtTxInfArray.push({
            Cdtr: {
                Id: {
                    OrgId: {
                        AnyBIC: creditor50A?.IdnCd?.content,
                        Othr: getOtherId(creditor50A?.Acc, creditor50K?.Acc)
                    }
                },
                Nm: getName(creditor50K?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(creditor50K?.AdrsLine)
                }
            },
            CdtrAcct: {
                Id: {
                    IBAN: validateAccountNumber(creditor50A?.Acc, acc2 = creditor50K?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(creditor50A?.Acc, acc2 = creditor50K?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(creditor50A?.Acc, creditor50K?.Acc)
                        }
                    }
                }
            },
            CdtrAgt: {
                FinInstnId: {
                    BICFI: accWthInstn52A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(accWthInstn52D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(accWthInstn52D?.AdrsLine)
                    }
                }
            },
            CdtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = accWthInstn52A?.PrtyIdn, prtyIdn2 = accWthInstn52C?.PrtyIdn, prtyIdn3 = accWthInstn52D?.PrtyIdn)
                        }
                    }
                }
            },
            DbtrAcct: {
                Id: {
                    IBAN: validateAccountNumber(transaxion.MT59A?.Acc, acc2 = transaxion.MT59?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(transaxion.MT59A?.Acc, acc2 = transaxion.MT59?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(transaxion.MT59A?.Acc, transaxion.MT59?.Acc)
                        }
                    }
                }
            },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT30.Dt),
            IntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                    Ccy: transaxion.MT32B.Ccy.content
                }
            },
            InstdAmt: {
                ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                    ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                    Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                }
            },
            XchgRate: check convertToDecimal(transaxion.MT36?.Rt),
            DrctDbtTx: {
                MndtRltdInf: {
                    MndtId: transaxion.MT21C?.Ref?.content
                }
            },
            PmtId: {
                EndToEndId: getEndToEndId(block4.MT21R?.Ref?.content, transaxion.MT70?.Nrtv?.content, transaxion.MT21.Ref.content),
                InstrId: block4.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value,
                TxId: transaxion.MT21.Ref.content
            },
            PmtTpInf: {
                CtgyPurp: {
                    Cd: instrCd?.InstrnCd?.content
                }
            },
            DbtrAgt: {
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
            DbtrAgtAcct: {
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
                    BICFI: block4.MT53A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(block4.MT53A?.PrtyIdn, block4.MT53B?.PrtyIdn)[0]
                        }
                    },
                    PstlAdr: {
                        AdrLine: getAddressLine((), address3 = block4.MT53B?.Lctn?.content)
                    }
                }
            },
            IntrmyAgt1Acct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(block4.MT53A?.PrtyIdn, block4.MT53B?.PrtyIdn)[0],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(block4.MT53A?.PrtyIdn, block4.MT53B?.PrtyIdn)[0],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = block4.MT53A?.PrtyIdn, prtyIdn2 = block4.MT53B?.PrtyIdn)
                        }
                    }
                }
            },
            InitgPty: {
                Id: {
                    OrgId: {
                        AnyBIC: instgPrty50C?.IdnCd?.content
                    },
                    PrvtId: {
                        Othr: [
                            {
                                Id: getPartyIdentifier(instgPrty50L?.PrtyIdn)
                            }
                        ]
                    }
                }
            },
            ChrgBr: check getDetailsChargesCd(dtlsOfChrgs?.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
            Dbtr: {
                Id: {
                    OrgId: {
                        AnyBIC: transaxion.MT59A?.IdnCd?.content,
                        Othr: getOtherId(transaxion.MT59?.Acc, transaxion.MT59A?.Acc)
                    }
                },
                Nm: getName(transaxion.MT59?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(transaxion.MT59?.AdrsLine)
                }
            },
            RgltryRptg: getRegulatoryReporting(rgltryRptg?.Nrtv?.content),
            RmtInf: {
                Ustrd: [getRemmitanceInformation(transaxion.MT70?.Nrtv?.content)],
                Strd: []
            }
        }
        );
    }
    return drctDbtTxInfArray;
}

# Transforms the given SWIFT MT104 message to its corresponding ISO 20022 Pain.008 format.
#
# This function extracts various fields from the SWIFT MT104 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT104 message as a record value.
# + return - Returns the transformed ISO 20022 `Pain008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT104ToPain008(swiftmt:MT104Message message) returns painIsoRecord:Pain008Document|error => {
    CstmrDrctDbtInitn: {
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
        PmtInf: check getPaymentInformationOfMT104(message.block4, message.block3)
    }
};

# Processes an MT104 message and extracts payment information into ISO 20022 format.
# This function maps the SWIFT MT104 transaction details into an array of `PaymentInstruction45` ISO records.
# It extracts important fields such as creditor information, settlement details, and payment method from each transaction.
#
# + block4 - The parsed block4 of MT104 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT104 SWIFT message containing end to end id.
# + return - Returns an array of `PaymentInstruction45` records, each corresponding to a transaction 
# in the input message. An error is returned if any field extraction or conversion fails.
isolated function getPaymentInformationOfMT104(swiftmt:MT104Block4 block4, swiftmt:Block3? block3) returns painIsoRecord:PaymentInstruction45[]|error {
    painIsoRecord:PaymentInstruction45[] paymentInstructionArray = [];
    foreach swiftmt:MT104Transaction transaxion in block4.Transaction {
        swiftmt:MT26T? trnsTp = check getMT104RepeatingFields(block4, transaxion.MT26T, "26T").ensureType();
        swiftmt:MT50A? creditor50A = check getMT104RepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50K? creditor50K = check getMT104RepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT52A? accWthInstn52A = check getMT104RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52C? accWthInstn52C = check getMT104RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        swiftmt:MT52D? accWthInstn52D = check getMT104RepeatingFields(block4, transaxion.MT52D, "52D").ensureType();
        swiftmt:MT71A? dtlsOfChrgs = check getMT104RepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltryRptg = check getMT104RepeatingFields(block4, transaxion.MT77B, "77B").ensureType();

        paymentInstructionArray.push({
            Cdtr: {
                Id: {
                    OrgId: {
                        AnyBIC: creditor50A?.IdnCd?.content,
                        Othr: getOtherId(creditor50A?.Acc, creditor50K?.Acc)
                    }
                },
                Nm: getName(creditor50K?.Nm),
                PstlAdr: {
                    AdrLine: getAddressLine(creditor50K?.AdrsLine)
                }
            },
            ReqdColltnDt: convertToISOStandardDateMandatory(block4.MT30.Dt),
            CdtrAgt: {
                FinInstnId: {
                    BICFI: accWthInstn52A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(accWthInstn52D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(accWthInstn52D?.AdrsLine)
                    }
                }
            },
            CdtrAgtAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = accWthInstn52A?.PrtyIdn, prtyIdn2 = accWthInstn52C?.PrtyIdn, prtyIdn3 = accWthInstn52D?.PrtyIdn)
                        }
                    }
                }
            },
            CdtrAcct: {
                Id: {
                    IBAN: validateAccountNumber(creditor50A?.Acc, acc2 = creditor50K?.Acc)[0],
                    Othr: {
                        Id: validateAccountNumber(creditor50A?.Acc, acc2 = creditor50K?.Acc)[1],
                        SchmeNm: {
                            Cd: getSchemaCode(creditor50A?.Acc, creditor50K?.Acc)
                        }
                    }
                }
            },
            PmtInfId: transaxion.MT21.Ref.content,
            PmtTpInf: {
                CtgyPurp: {
                    Cd: block4.MT23E?.InstrnCd?.content
                }
            },
            ChrgBr: check getDetailsChargesCd(dtlsOfChrgs?.Cd).ensureType(painIsoRecord:ChargeBearerType1Code),
            DrctDbtTxInf: [
                {
                    DrctDbtTx: {
                        MndtRltdInf: {
                            MndtId: transaxion.MT21C?.Ref?.content
                        }
                    },
                    DbtrAcct: {
                        Id: {
                            IBAN: validateAccountNumber(transaxion.MT59A?.Acc, acc2 = transaxion.MT59?.Acc)[0],
                            Othr: {
                                Id: validateAccountNumber(transaxion.MT59A?.Acc, acc2 = transaxion.MT59?.Acc)[1],
                                SchmeNm: {
                                    Cd: getSchemaCode(transaxion.MT59A?.Acc, transaxion.MT59?.Acc)
                                }
                            }
                        }
                    },
                    PmtId: {
                        EndToEndId: getEndToEndId(block4.MT21R?.Ref?.content, transaxion.MT70?.Nrtv?.content, transaxion.MT21.Ref.content),
                        InstrId: block4.MT20.msgId.content,
                        UETR: block3?.NdToNdTxRef?.value
                    },
                    DbtrAgt: {
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
                    DbtrAgtAcct: {
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
                    InstdAmt: {
                        ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                            ActiveOrHistoricCurrencyAndAmount_SimpleType: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                            Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                        }
                    },
                    Dbtr: {
                        Id: {
                            OrgId: {
                                AnyBIC: transaxion.MT59A?.IdnCd?.content,
                                Othr: getOtherId(transaxion.MT59?.Acc, transaxion.MT59A?.Acc)
                            }
                        },
                        Nm: getName(transaxion.MT59?.Nm),
                        PstlAdr: {
                            AdrLine: getAddressLine(transaxion.MT59?.AdrsLine)
                        }
                    },
                    RgltryRptg: getRegulatoryReporting(rgltryRptg?.Nrtv?.content),
                    RmtInf: {Ustrd: [getRemmitanceInformation(transaxion.MT70?.Nrtv?.content)], Strd: []},
                    Purp: {
                        Prtry: getMandatoryFields(trnsTp?.Typ?.content)
                    }
                }
            ],
            PmtMtd: "DD"
        });
    }
    return paymentInstructionArray;
}
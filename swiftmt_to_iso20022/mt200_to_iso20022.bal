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
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MT200 SWIFT message into an ISO 20022 PACS.009 document.
# The relevant fields from the MT200 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT200 message as a record value.
# + return - Returns a `Pacs009Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT200ToPacs009(swiftmt:MT200Message message) returns pacsIsoRecord:Pacs009Document|error => {
    FICdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            SttlmInf: {
                SttlmMtd: getSettlementMethod(mt53B = message.block4.MT53B)
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
                CdtrAcct: {
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
                    EndToEndId: "",
                    InstrId: message.block4.MT20.msgId.content,
                    UETR: message.block3?.NdToNdTxRef?.value
                },
                Dbtr: {
                    FinInstnId: {
                        ClrSysMmbId: {
                            MmbId: "", 
                            ClrSysId: {
                                Cd: getPartyIdentifierOrAccount2(message.block4.MT53B?.PrtyIdn)[0]
                            }
                        },
                        PstlAdr: {
                            AdrLine: getAddressLine((), address3 = message.block4.MT53B?.Lctn?.content)
                        }
                    }
                },
                DbtrAcct: {
                    Id: {
                        IBAN: getPartyIdentifierOrAccount2(message.block4.MT53B?.PrtyIdn)[1],
                        Othr: {
                            Id: getPartyIdentifierOrAccount2(message.block4.MT53B?.PrtyIdn)[2],
                            SchmeNm: {
                                Cd: getSchemaCode(prtyIdn1 = message.block4.MT53B?.PrtyIdn)
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
                InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72, 2))[1],
                InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72, 2))[0]
            }
        ]
    }
};

# This function transforms an MT200 SWIFT message into an ISO 20022 CAMT.050 document.
# The relevant fields from the MT200 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT200 message as a record value.
# + return - Returns a `Camt050Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT200ToCamt050(swiftmt:MT200Message message) returns camtIsoRecord:Camt050Document|error => {
    LqdtyCdtTrf: {
        MsgHdr: {
            MsgId: uuid:createType4AsString().substring(0, 35),
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string)
        },
        LqdtyCdtTrf: {
            LqdtyTrfId: {
                EndToEndId: "",
                InstrId: message.block4.MT20.msgId.content,
                UETR: message.block3?.NdToNdTxRef?.value
            },
            TrfdAmt: {
                AmtWthCcy: {
                    ActiveCurrencyAndAmount_SimpleType: {
                        ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                        Ccy: message.block4.MT32A.Ccy.content
                    }
                }
            },
            SttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt)
        }
    }
};

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

# This function transforms an MT192 SWIFT message to a camt.055 ISO 20022 XML document format.
#
# This function performs the conversion of an MT192 SWIFT message to the corresponding
# ISO 20022 XML camt.055 format.
# The relevant fields from the MT192 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The MT192 message to be transformed, which should be in the `swiftmt:MTn92Message` format.
# + return - Returns a record in `camtIsoRecord:Camt055Document` format if successful, otherwise returns an error.
isolated function transformMTn92ToCamt055(swiftmt:MTn92Message message) returns camtIsoRecord:Camt055Envelope|error => {
    AppHdr: {
        Fr: {
            FIId: {
                FinInstnId: {
                    BICFI: getMessageSender(message.block1?.logicalTerminal,
                            message.block2.MIRLogicalTerminal)
                }
            }
        },
        To: {
            FIId: {
                FinInstnId: {
                    BICFI: getMessageReceiver(message.block1?.logicalTerminal,
                            message.block2.receiverAddress)
                }
            }
        },
        BizMsgIdr: message.block4.MT20.msgId.content,
        MsgDefIdr: "camt055.001.12",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string)
    },
    Document: {
        CstmrPmtCxlReq: {
            Assgnmt: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string),
                Assgne: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                        }
                    }
                },
                Id: ASSIGN_ID,
                Assgnr: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                        }
                    }
                }
            },
            Undrlyg: [
                {
                    OrgnlGrpInfAndCxl: {
                        OrgnlMsgId: "",
                        OrgnlMsgNmId: getOrignalMessageName(message.block4.MT11S.MtNum.content),
                        OrgnlCreDtTm: convertToISOStandardDate(message.block4.MT11S.Dt),
                        Case: {
                            Id: message.block4.MT20.msgId.content,
                            Cretr: {
                                Agt: {
                                    FinInstnId: {
                                        BICFI: getMessageSender(message.block1?.logicalTerminal,
                                                message.block2.MIRLogicalTerminal)
                                    }
                                }
                            }
                        }
                    },
                    OrgnlPmtInfAndCxl: [
                        {
                            OrgnlPmtInfId: message.block4.MT21.Ref.content,
                            CxlRsnInf: [
                                {
                                    Rsn: {
                                        Cd: getCancellationReasonCode(message.block4.MT79)
                                    },
                                    AddtlInf: getAdditionalCancellationInfo(message.block4.MT79)
                                }
                            ]
                        }
                    ]
                }
            ],
            SplmtryData: [
                {
                    Envlp: {
                        CpOfOrgnlMsg: message.block4.MessageCopy.toJson()
                    }
                }
            ]
        }
    }
};

# This function transforms an MT292 or MT992 SWIFT message to a camt.056 ISO 20022 XML document format.
#
# This function performs the conversion of an MT292 or MT992 SWIFT message to the corresponding
# ISO 20022 XML camt.056 format.
# The relevant fields from the MT292 or MT992 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The MT292 or MT992 message to be transformed, which should be in the `swiftmt:MTn92Message` format.
# + return - Returns a record in `camtIsoRecord:Camt056Document` format if successful, otherwise returns an error.
isolated function transformMTn92ToCamt056(swiftmt:MTn92Message message) returns camtIsoRecord:Camt056Envelope|error => {
    AppHdr: {
        Fr: {
            FIId: {
                FinInstnId: {
                    BICFI: getMessageSender(message.block1?.logicalTerminal,
                            message.block2.MIRLogicalTerminal)
                }
            }
        },
        To: {
            FIId: {
                FinInstnId: {
                    BICFI: getMessageReceiver(message.block1?.logicalTerminal,
                            message.block2.receiverAddress)
                }
            }
        },
        BizMsgIdr: message.block4.MT20.msgId.content,
        MsgDefIdr: "camt056.001.11",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string) + DEFAULT_TIME_OFFSET
    },
    Document: {
        FIToFIPmtCxlReq: {
            Assgnmt: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string) + DEFAULT_TIME_OFFSET,
                Assgne: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                        }
                    }
                },
                Id: ASSIGN_ID,
                Assgnr: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                        }
                    }
                }
            },
            Undrlyg: [
                {
                    TxInf: [
                        {
                            OrgnlGrpInf: {
                                OrgnlMsgId: "",
                                OrgnlMsgNmId: getOrignalMessageName(message.block4.MT11S.MtNum.content),
                                OrgnlCreDtTm: convertToISOStandardDate(message.block4.MT11S.Dt)
                            },
                            Case: {
                                Id: message.block4.MT20.msgId.content,
                                Cretr: {
                                    Agt: {
                                        FinInstnId: {
                                            BICFI: getMessageSender(message.block1?.logicalTerminal,
                                                    message.block2.MIRLogicalTerminal)
                                        }
                                    }
                                }
                            },
                            OrgnlInstrId: message.block4.MT21.Ref.content,
                            OrgnlUETR: message.block3?.NdToNdTxRef?.value,
                            CxlRsnInf: [
                                {
                                    Rsn: {
                                        Cd: getCancellationReasonCode(message.block4.MT79)
                                    },
                                    AddtlInf: getAdditionalCancellationInfo(message.block4.MT79)
                                }
                            ]
                        }
                    ]
                }
            ],
            SplmtryData: [
                {
                    Envlp: {
                        CpOfOrgnlMsg: message.block4.MessageCopy.toJson()
                    }
                }
            ]
        }
    }
};

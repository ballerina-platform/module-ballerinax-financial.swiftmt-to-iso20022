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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MTn96 SWIFT message to a camt.028 ISO 20022 XML document format.
#
# This function performs the conversion of an MTn96 SWIFT message to the corresponding
# ISO 20022 XML camt.028 format.
# The relevant fields from the MTn96 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The MTn96 message to be transformed, which should be in the `swiftmt:MTn96Message` format.
# + return - Returns a record in `camtIsoRecord:Camt028Document` format if successful, otherwise returns an error.
isolated function transformMTn96ToCamt028(swiftmt:MTn96Message message) returns camtIsoRecord:Camt028Envelope|error =>{
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "camt028.001.12",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string)
    },
    Document: {
        AddtlPmtInf: {
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
            Case: {
                Id: message.block4.MT20.msgId.content,
                Cretr: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                        }
                    }
                }
            },
            Undrlyg: {
                Initn: {
                    OrgnlInstrId: message.block4.MT21.Ref.content,
                    OrgnlUETR: message.block3?.NdToNdTxRef?.value
                }
            },
            Inf: {},
            SplmtryData: [
                {
                    Envlp: {
                        CpOfOrgnlMsg: message.block4.MessageCopy.toJson(),
                        Nrtv: getDescriptionOfMessage(message.block4.MT79?.Nrtv)
                    }
                },
                {
                    Envlp: {
                        Nrtv: message.block4.MT76.Nrtv.content
                    }
                }
            ]
        }
    }
};

isolated function transformMTn96ToCamt029(swiftmt:MTn96Message message) returns camtIsoRecord:Camt029Envelope|error =>
    let string? date = convertToISOStandardDate(message.block4.MT11R?.Dt) in {
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "camt029.001.13",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string) + "+00:00"
    },
    Document: {
        RsltnOfInvstgtn: {
            Assgnmt: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string) + "+00:00", 
                Assgne: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                        }
                    }
                }, 
                Id: message.block4.MT20.msgId.content, 
                Assgnr: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                        }
                    }
                }
            }, 
            CxlDtls: [{
                TxInfAndSts: [{
                    OrgnlGrpInf: {
                        OrgnlMsgId: "",
                        OrgnlMsgNmId: getOrignalMessageName(message.block4.MT11R?.MtNum?.content),
                        OrgnlCreDtTm: date is () ? () : date + "T00:00:00+00:00"
                    },
                    CxlStsId: message.block4.MT20.msgId.content,
                    OrgnlUETR: message.block3?.NdToNdTxRef?.value is () ? getOrgnlUETR(message.block4.MT77A?.Nrtv?.content)
                        : message.block3?.NdToNdTxRef?.value,
                    RslvdCase: {
                        Id: message.block4.MT21.Ref.content,
                        Cretr: {}
                    },
                    CxlStsRsnInf: getCancellationReason(message.block4.MT76.Nrtv.content)
                }]
            }],
            Sts: {
                Conf: getStatusConfirmation(message.block4.MT76.Nrtv.content)
            }
        }
    }
};

# This function transforms an MTn96 SWIFT message to a camt.031 ISO 20022 XML document format.
#
# This function performs the conversion of an MTn96 SWIFT message to the corresponding
# ISO 20022 XML camt.031 format.
# The relevant fields from the MTn96 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The MTn96 message to be transformed, which should be in the `swiftmt:MTn96Message` format.
# + return - Returns a record in `camtIsoRecord:Camt031Document` format if successful, otherwise returns an error.
isolated function transformMTn96ToCamt031(swiftmt:MTn96Message message) returns camtIsoRecord:Camt031Envelope|error =>{
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "camt031.001.07",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string)
    },
    Document: {
        RjctInvstgtn: {
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
            Case: {
                Id: message.block4.MT20.msgId.content,
                Cretr: {
                    Agt: {
                        FinInstnId: {
                            BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                        }
                    }
                }
            },
            Justfn: {
                RjctnRsn: check getRejectedReason(message.block4.MT76.Nrtv.content)
            },
            SplmtryData: [
                {
                    Envlp: {
                        CpOfOrgnlMsg: message.block4.MessageCopy.toJson(),
                        Nrtv: getDescriptionOfMessage(message.block4.MT79?.Nrtv)
                    }
                },
                {
                    Envlp: {
                        Nrtv: message.block4.MT76.Nrtv.content
                    }
                }
            ]
        }
    }
};

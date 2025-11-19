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

# This function transforms an MTn95 SWIFT message to a camt.026 ISO 20022 XML document format.
#
# This function performs the conversion of an MTn95 SWIFT message to the corresponding
# ISO 20022 XML camt.026 format.
# The relevant fields from the MTn95 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The MTn95 message to be transformed, which should be in the `swiftmt:MTn95Message` format.
# + return - Returns a record in `camtIsoRecord:Camt026Document` format if successful, otherwise returns an error.
isolated function transformMTn95ToCamt026(swiftmt:MTn95Message message) returns camtIsoRecord:Camt026Envelope|error => {
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
        MsgDefIdr: "camt.026.001.08",
        BizSvc: "swift.cbprplus.03",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string)
    },
    Document: {
        UblToApply: {
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
            Justfn: {
                MssngOrIncrrctInf: getJustificationReason(message.block4.MT75.Nrtv.content)
            },
            SplmtryData: [
                {
                    Envlp: {
                        CpOfOrgnlMsg: message.block4.MessageCopy.toJson(),
                        Nrtv: getDescriptionOfMessage(message.block4.MT79?.Nrtv)
                    }
                }
            ]
        }
    }
};

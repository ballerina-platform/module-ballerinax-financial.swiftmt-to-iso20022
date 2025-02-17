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
isolated function transformMT200ToPacs009(swiftmt:MT200Message message) returns pacsIsoRecord:Pacs009Envelope|error =>{
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "pacs.009.001.11",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string)
    },
    Document: {
        FICdtTrf: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string),
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
                    Cdtr: getFinancialInstitution(message.block4.MT57A?.IdnCd?.content, message.block4.MT57D?.Nm,
                        message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, (), 
                        message.block4.MT57D?.PrtyIdn,message.block4.MT57D?.AdrsLine,
                        message.block4.MT57B?.Lctn?.content) ?: {FinInstnId: {}},
                    CdtrAcct: getCashAccount(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn,
                        message.block4.MT57D?.PrtyIdn),
                    IntrBkSttlmAmt: {
                        content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                        Ccy: message.block4.MT32A.Ccy.content
                    },
                    IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                    PmtId: {
                        EndToEndId: "",
                        InstrId: message.block4.MT20.msgId.content,
                        UETR: message.block3?.NdToNdTxRef?.value
                    },
                    Dbtr: getFinancialInstitution((), (), message.block4.MT53B?.PrtyIdn, (),
                        adrsLine2 = message.block4.MT53B?.Lctn?.content) ?: {FinInstnId: {}},
                    DbtrAcct: getCashAccount(message.block4.MT53B?.PrtyIdn, ()),
                    IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content, message.block4.MT56D?.Nm,
                        message.block4.MT56A?.PrtyIdn, (), message.block4.MT56D?.PrtyIdn, (),
                        message.block4.MT56D?.AdrsLine),
                    IntrmyAgt1Acct: getCashAccount(message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn),
                    InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72, 2))[1],
                    InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(message.block4.MT72, 2))[0]
                }
            ]
        }
    }
};

# This function transforms an MT200 SWIFT message into an ISO 20022 CAMT.050 document.
# The relevant fields from the MT200 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT200 message as a record value.
# + return - Returns a `Camt050Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT200ToCamt050(swiftmt:MT200Message message) returns camtIsoRecord:Camt050Envelope|error =>{
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "camt.050.001.07", 
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string)
    },
    Document: {
        LqdtyCdtTrf: {
            MsgHdr: {
                MsgId: uuid:createType4AsString().substring(0, 35),
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
            },
            LqdtyCdtTrf: {
                LqdtyTrfId: {
                    EndToEndId: "",
                    InstrId: message.block4.MT20.msgId.content,
                    UETR: message.block3?.NdToNdTxRef?.value
                },
                TrfdAmt: {
                    AmtWthCcy: {
                        content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                        Ccy: message.block4.MT32A.Ccy.content
                    }
                },
                SttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt)
            }
        }
    }
};

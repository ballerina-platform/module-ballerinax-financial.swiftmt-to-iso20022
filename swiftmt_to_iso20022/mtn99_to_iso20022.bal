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

# This function transforms an MTn99 SWIFT message into an ISO 20022 Pacs002Document format.
#
# + message - The parsed MTn99 message as a record value.
# + return - Returns a `Pacs002Document` object if the transformation is successful,
# otherwise returns an error.
isolated function transformMTn99Pacs002(swiftmt:MTn99Message message) returns pacsIsoRecord:Pacs002Envelope|error =>
    let [pacsIsoRecord:Max105Text[], string?, string?, string?, string?] [addtnlInfo, messageId, endToEndId, uetr,
        reason] = getInfoFromField79ForPacs002(message.block4.MT79.Nrtv) in {
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "pacs.002.001.14",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string)
    },
    Document: {
        FIToFIPmtStsRpt: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string), 
                MsgId: message.block4.MT20.msgId.content
            },
            TxInfAndSts: [{
                OrgnlGrpInf: {
                    OrgnlMsgId: messageId is string ? messageId : "",
                    OrgnlMsgNmId: "MT" + message.block2.messageType
                },
                OrgnlInstrId: message.block4.MT21?.Ref?.content,
                OrgnlEndToEndId: endToEndId,
                OrgnlUETR: uetr is string ? uetr : message.block3?.NdToNdTxRef?.value,
                StsRsnInf: reason is () && addtnlInfo.length() == 0 ? () : [{
                    Rsn: reason is () ? () :{
                        Cd:reason
                    },
                    AddtlInf: addtnlInfo.length() == 0 ? () : addtnlInfo
                }]
            }]
        }
    }
};
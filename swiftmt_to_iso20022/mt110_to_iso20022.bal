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

// import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
// import ballerinax/financial.swift.mt as swiftmt;

// # This function transforms an MT110 SWIFT message into an ISO 20022 CAMT.107 document.
// # The relevant fields from the MT110 message are extracted and mapped to the corresponding ISO 20022 structure.
// #
// # + message - The parsed MT110 message as a record value.
// # + return - Returns a `Camt107Document` object if the transformation is successful, otherwise returns an error.
// isolated function transformMT970ToCamt053(swiftmt:MT110Message message) returns camtIsoRecord:Camt107Envelope => {
//     AppHdr: {
//         Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)}}}, 
//         To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)}}}, 
//         BizMsgIdr: message.block4.MT20.msgId.content, 
//         MsgDefIdr: "camt107.001.12", 
//         CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string)
//     },
//     Document: {
        
//     }
// };

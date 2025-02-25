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

# This function transforms an MT110 SWIFT message into an ISO 20022 CAMT.107 document.
# The relevant fields from the MT110 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT110 message as a record value.
# + return - Returns a `Camt107Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT110ToCamt107(swiftmt:MT110Message message) 
    returns camtIsoRecord:Camt107Envelope|error => let 
    camtIsoRecord:Cheque17[] chequesInfo = check getChequeInformation(message.block4) in {
        AppHdr: {
            Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
                message.block2.MIRLogicalTerminal)}}}, 
            To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
                message.block2.receiverAddress)}}}, 
            BizMsgIdr: message.block4.MT20.msgId.content, 
            MsgDefIdr: "camt107.001.01", 
            BizSvc: "swift.cbprplus.02",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string) + "+00:00"
        },
        Document: {
            ChqPresntmntNtfctn: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string) + "+00:00",
                    NbOfChqs: chequesInfo.length().toString(),
                    MsgId: message.block4.MT20.msgId.content}, 
                Chq: chequesInfo}}
};

isolated function getChequeInformation(swiftmt:MT110Block4 block4) returns camtIsoRecord:Cheque17[]|error {
    camtIsoRecord:Cheque17[] cheques = [];

    foreach swiftmt:Cheques cheque in block4.Cheques {
        cheques.push({
            IsseDt: convertToISOStandardDateMandatory(cheque.MT30.Dt),
            ChqNb: cheque.MT21.Ref.content,
            InstrId: block4.MT20.msgId.content,
            Amt: cheque.MT32A is () ? {content: check convertToDecimalMandatory(cheque.MT32B?.Amnt), 
                Ccy: cheque.MT32B?.Ccy?.content.toString()} : {content: check convertToDecimalMandatory(cheque.MT32A?.Amnt), 
                Ccy: cheque.MT32A?.Ccy?.content.toString()},
            ValDt: {Dt: cheque.MT32A is () ? () : convertToISOStandardDate(cheque.MT32A?.Dt)},
            Pyer: getDebtorOrCreditor(cheque.MT50A?.IdnCd, cheque.MT50A?.Acc, cheque.MT50K?.Acc, (),
                cheque.MT50F?.PrtyIdn, cheque.MT50F?.Nm, cheque.MT50K?.Nm, cheque.MT50F?.AdrsLine,
                cheque.MT50K?.AdrsLine, cheque.MT50F?.CntyNTw, true),
            PyerAcct: getCashAccount2(cheque.MT50A?.Acc, cheque.MT50K?.Acc, (), cheque.MT50F?.PrtyIdn),
            DrwrAgt: getFinancialInstitution(cheque.MT52A?.IdnCd?.content, cheque.MT52D?.Nm, cheque.MT52A?.PrtyIdn,
                cheque.MT52B?.PrtyIdn, cheque.MT52D?.PrtyIdn, (), cheque.MT52D?.AdrsLine, cheque.MT52B?.Lctn?.content),
            DrwrAgtAcct: getCashAccount(cheque.MT52A?.PrtyIdn, cheque.MT52B?.PrtyIdn,cheque.MT52D?.PrtyIdn),
            Pyee: getDebtorOrCreditor((), cheque.MT59?.Acc, (), cheque.MT59F?.Acc, (), cheque.MT59F?.Nm,
                cheque.MT59?.Nm, cheque.MT59F?.AdrsLine, cheque.MT59?.AdrsLine, cheque.MT59F?.CntyNTw, false),
            PyeeAcct: getCashAccount2(cheque.MT59?.Acc, cheque.MT59F?.Acc)});
    }

    return cheques;
}

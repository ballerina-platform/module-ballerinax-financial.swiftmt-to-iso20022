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

# This function transforms an MT112 SWIFT message into an ISO 20022 CAMT.109 document.
# The relevant fields from the MT112 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT112 message as a record value.
# + return - Returns a `Camt109Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT112ToCamt109(swiftmt:MT112Message message) returns camtIsoRecord:Camt109Envelope|error =>{
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal,
            message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal,
            message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "camt.109.001.01", 
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
            true).ensureType(string) + "+00:00"
    },
    Document: {
        ChqCxlOrStopRpt: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string) + "+00:00",
                NbOfChqs: "1",
                MsgId: message.block4.MT20.msgId.content}, 
            Chq: [{
                IsseDt: convertToISOStandardDateMandatory(message.block4.MT30.Dt),
                ChqNb: message.block4.MT21.Ref.content,
                InstrId: message.block4.MT20.msgId.content,
                Amt: message.block4.MT32A is () ? {content: check convertToDecimalMandatory(message.block4.MT32B?.Amnt), 
                Ccy: message.block4.MT32B?.Ccy?.content.toString()} : {content: check convertToDecimalMandatory(
                    message.block4.MT32A?.Amnt), 
                Ccy: message.block4.MT32A?.Ccy?.content.toString()},
                FctvDt: {Dt: message.block4.MT32A is () ? () : convertToISOStandardDate(
                    message.block4.MT32A?.Dt)},
                DrwrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, message.block4.MT52D?.Nm,
                    message.block4.MT52A?.PrtyIdn, message.block4.MT52B?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (),
                    message.block4.MT52D?.AdrsLine, message.block4.MT52B?.Lctn?.content),
                DrwrAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52B?.PrtyIdn,
                    message.block4.MT52D?.PrtyIdn),
                Pyee: getDebtorOrCreditor((), message.block4.MT59?.Acc, (), (), (), message.block4.MT59?.Nm, (),
                    message.block4.MT59?.AdrsLine, ()),
                ChqCxlOrStopSts: getChequeStopStatus(message.block4.MT76?.Nrtv?.content)}]}}
};

isolated function getChequeStopStatus(string? narration) returns camtIsoRecord:ChequeCancellationStatus1 {
    if narration is string {
        string code = "";
        foreach int i in 1...narration.length() - 1 {
            if narration.substring(i, i + 1) == "/" {
                if chequeCancelStatusCode[code] !is () {
                    if narration.length() - 1 > i {
                        return {Sts: {Cd: chequeCancelStatusCode[code]}, AddtlInf: narration.substring((i + 1))};
                    } 
                    return {Sts: {Cd: chequeCancelStatusCode[code]}};
                } 
                break;
            }
            code += narration.substring(i, i + 1);
        }
    }
    return {Sts: {Cd: "NOTPROVIDED"}};
}

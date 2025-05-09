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

# This function transforms an MTn90 SWIFT message into an ISO 20022 CAMT.105 document.
# The relevant fields from the MTn90 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MTn90 message as a record value.
# + return - Returns a `Camt105Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMTn90ToCamt105(swiftmt:MTn90Message message) returns camtIsoRecord:Camt105Envelope|error =>
    let camtIsoRecord:ChargesBreakdown1[] chrgsBrkdwn = check getChargesAmount(message.block4.MT71B.Nrtv.content),
    boolean isMultipleTx = chrgsBrkdwn.length() > 1,
    camtIsoRecord:BranchAndFinancialInstitutionIdentification8? chrgrsRqstr = message.block4.MT72?.Cd?.content is string &&
                    message.block4.MT72?.Cd?.content.toString().length() > 6 ?
                    {FinInstnId: {BICFI: message.block4.MT72?.Cd?.content.toString().substring(6)}} : () in {
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
            MsgDefIdr: "camt.105.001.02",
            BizSvc: isMultipleTx ? "swift.cbprplus.mlp.01" : "swift.cbprplus.01",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            ChrgsPmtNtfctn: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    MsgId: message.block4.MT20.msgId.content,
                    ChrgsAcct: getCashAccount2(message.block4.MT25?.Acc, ()),
                    ChrgsRqstr: isMultipleTx ? () : chrgrsRqstr,
                    TtlChrgs: isMultipleTx ? {
                            NbOfChrgsRcrds: chrgsBrkdwn.length().toString(),
                            TtlChrgsAmt: {
                                content: check convertToDecimalMandatory(message.block4.MT32D?.Amnt),
                                Ccy: message.block4.MT32D?.Ccy?.content ?: ""
                            },
                            CdtDbtInd: "DBIT"
                        } : ()
                },
                Chrgs: {
                    PerTx: {
                        ChrgsId: message.block4.MT20.msgId.content,
                        Rcrd: check getChrgsPerTxForMtn90(message, isMultipleTx, chrgsBrkdwn, chrgrsRqstr)
                    }
                }
            }
        }
    };

isolated function getChrgsPerTxForMtn90(swiftmt:MTn90Message message, boolean isMultipleTx,
        camtIsoRecord:ChargesBreakdown1[] chrgsBrkdwn, camtIsoRecord:BranchAndFinancialInstitutionIdentification8? chrgrsRqstr)
        returns camtIsoRecord:ChargesPerTransactionRecord4[]|error {

    camtIsoRecord:ChargesPerTransactionRecord4[] chrgsPerTx = [];
    foreach int i in 0 ... chrgsBrkdwn.length() - 1 {
        chrgsPerTx.push(
        {
            ChrgsRqstr: isMultipleTx ? chrgrsRqstr : (),
            UndrlygTx: {
                InstrId: message.block4.MT21.Ref.content,
                UETR: message.block3?.NdToNdTxRef?.value
            },
            TtlChrgsPerRcrd: {
                NbOfChrgsBrkdwnItms: "1",
                TtlChrgsAmt: {
                    content: chrgsBrkdwn[i].Amt.content,
                    Ccy: chrgsBrkdwn[i].Amt.Ccy
                },
                CdtDbtInd: message.block4.MT32C is () ? "DBIT" : "CRDT"
            },
            ValDt: {
                Dt: message.block4.MT32C is () ? convertToISOStandardDate(message.block4.MT32D?.Dt) :
                    convertToISOStandardDate(message.block4.MT32C?.Dt)
            },
            DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content,
                    message.block4.MT52D?.Nm, message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (),
                    (), message.block4.MT52D?.AdrsLine),
            DbtrAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
            ChrgsBrkdwn: [chrgsBrkdwn[i]]
        });
    }
    return chrgsPerTx;
}

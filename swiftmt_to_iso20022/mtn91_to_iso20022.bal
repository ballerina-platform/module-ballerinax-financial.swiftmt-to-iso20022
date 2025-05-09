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

# This function transforms an MTn91 SWIFT message into an ISO 20022 CAMT.106 document.
# The relevant fields from the MTn91 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MTn91 message as a record value.
# + return - Returns a `Camt106Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMTn91ToCamt106(swiftmt:MTn91Message message) returns camtIsoRecord:Camt106Envelope|error =>
    let [string?, string?, string?] [chrgRqstr, instr, info] =
        getChrgRqstrAndInstrFrAgt(message.block4.MT72?.Cd?.content),
    camtIsoRecord:ChargesBreakdown1[] chrgsBrkdwn = check getChargesAmount(message.block4.MT71B.Nrtv.content),
    boolean isMultipleTx = chrgsBrkdwn.length() > 1
    in {
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
            MsgDefIdr: "camt.106.001.02",
            BizSvc: isMultipleTx ? "swift.cbprplus.mlp.01" : "swift.cbprplus.01",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            ChrgsPmtReq: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    MsgId: message.block4.MT20.msgId.content,
                    ChrgsAcctAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
                    ChrgsRqstr: isMultipleTx ? () : chrgRqstr is () ? () : {FinInstnId: {BICFI: chrgRqstr}},
                    TtlChrgs: isMultipleTx ? {
                            NbOfChrgsRcrds: chrgsBrkdwn.length().toString(),
                            TtlChrgsAmt: {
                                content: check convertToDecimalMandatory(message.block4.MT32B.Amnt),
                                Ccy: message.block4.MT32B.Ccy.content
                            },
                            CdtDbtInd: "DBIT"
                        } : ()
                },
                Chrgs: {
                    PerTx: {
                        ChrgsId: message.block4.MT20.msgId.content,
                        Rcrd: check getChrgsPerTx(message, isMultipleTx, chrgRqstr, chrgsBrkdwn, instr, info)
                    }
                }
            }
        }
    };

isolated function getChrgsPerTx(swiftmt:MTn91Message message, boolean isMultipleTx, string? chrgRqstr,
        camtIsoRecord:ChargesBreakdown1[] chrgsBrkdwn, string? instr, string? info)
        returns camtIsoRecord:ChargesPerTransactionRecord3[]|error {

    camtIsoRecord:ChargesPerTransactionRecord3[] chrgsPerTx = [];
    foreach int i in 0 ... chrgsBrkdwn.length() - 1 {
        chrgsPerTx.push(
        {
            ChrgsRqstr: isMultipleTx ? chrgRqstr is () ? () : {FinInstnId: {BICFI: chrgRqstr}} : (),
            UndrlygTx: {
                MsgNmId: "pacs.008.001.08",
                InstrId: message.block4.MT21.Ref.content,
                UETR: message.block3?.NdToNdTxRef?.value
            },
            TtlChrgsPerRcrd: {
                NbOfChrgsBrkdwnItms: "1",
                TtlChrgsAmt: {
                    content: chrgsBrkdwn[i].Amt.content,
                    Ccy: chrgsBrkdwn[i].Amt.Ccy
                },
                CdtDbtInd: "DBIT"
            },
            DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content,
                    message.block4.MT52D?.Nm, message.block4.MT52A?.PrtyIdn,
                    message.block4.MT52D?.PrtyIdn, (), (), message.block4.MT52D?.AdrsLine),
            DbtrAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
            ChrgsBrkdwn: [chrgsBrkdwn[i]],
            InstrForInstdAgt: instr is () && info is () ? () : {
                    Cd: instr is () ? () : instr,
                    InstrInf: info is () ? () : info
                }
        });
    }
    return chrgsPerTx;
}

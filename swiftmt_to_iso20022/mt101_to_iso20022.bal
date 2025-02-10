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

import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given SWIFT MT101 message to its corresponding ISO 20022 Pain.001 format.
#
# This function extracts various fields from the SWIFT MT101 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT101 message as a record value.
# + return - Returns the transformed ISO 20022 `Pain001Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT101ToPain001(swiftmt:MT101Message message) returns painIsoRecord:Pain001Envelope|error => {
    AppHdr: {
        Fr: {FIId: {FinInstnId: {BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)}}}, 
        To: {FIId: {FinInstnId: {BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)}}}, 
        BizMsgIdr: message.block4.MT20.msgId.content, 
        MsgDefIdr: "pain.001.001.12", 
        BizSvc: "swift.cbprplus.02",
        CreDt: "9999-12-31T00:00:00+00:00"
    },
    Document: {
        CstmrCdtTrfInitn: {
            GrpHdr: {
                CreDtTm: "9999-12-31T00:00:00+00:00",
                InitgPty: {
                    Id: message.block4.MT50C?.IdnCd?.content is () && message.block4.MT50L?.PrtyIdn is () ? () : {
                        OrgId: message.block4.MT50C?.IdnCd?.content is () ? () : {
                            AnyBIC: message.block4.MT50C?.IdnCd?.content
                        },
                        PrvtId: getPartyIdentifier(message.block4.MT50L?.PrtyIdn) is () ? () :{
                            Othr: [
                                {
                                    Id: getPartyIdentifier(message.block4.MT50L?.PrtyIdn)
                                }
                            ]
                        }
                    }
                },
                FwdgAgt: getOptionalFinancialInstitution(message.block4.MT51A?.IdnCd?.content,
                        (), message.block4.MT51A?.PrtyIdn, ()),
                NbOfTxs: message.block4.Transaction.length().toString(),
                MsgId: message.block4.MT20.msgId.content
            },
            PmtInf: check getPaymentInformation(message.block4, message.block3)
        }
    }
};

# Extracts payment information from the provided MT101 message and maps it to an array of ISO 20022 PaymentInstruction44 records.
#
# This function iterates over the transactions in the SWIFT MT101 message and retrieves details such as debtor, creditor,
# instructed amount, exchange rate, and intermediary agents. These details are then structured in ISO 20022 format.
#
# + block4 - The parsed block4 of MT101 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT101 SWIFT message containing end to end id.
# + return - Returns an array of PaymentInstruction44 records or an error if an issue occurs while fetching information.
isolated function getPaymentInformation(swiftmt:MT101Block4 block4, swiftmt:Block3? block3) returns painIsoRecord:PaymentInstruction44[]|error {
    painIsoRecord:PaymentInstruction44[] pmtInfArray = [];
    foreach swiftmt:MT101Transaction transaxion in block4.Transaction {
        swiftmt:MT50F? ordgCstm50F = check getMT101RepeatingFields(block4, transaxion.MT50F, "50F").ensureType();
        swiftmt:MT50G? ordgCstm50G = check getMT101RepeatingFields(block4, transaxion.MT50G, "50G").ensureType();
        swiftmt:MT50H? ordgCstm50H = check getMT101RepeatingFields(block4, transaxion.MT50H, "50H").ensureType();
        swiftmt:MT52A? ordgInstn52A = check getMT101RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52C? ordgInstn52C = check getMT101RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        [painIsoRecord:InstructionForDebtorAgent1?, InstructionForCreditorAgentArray?, 
            painIsoRecord:ServiceLevel8Choice[]?, painIsoRecord:CategoryPurpose1Choice?] [instrFrDbtrAgt, instrFrCdtrAgt,
            serviceLevel, catPurpose] = getMT101InstructionCode(transaxion.MT23E);

        pmtInfArray.push({
            PmtInfId: block4.MT20.msgId.content,
            CdtTrfTxInf: [
                {
                    Amt: {
                        InstdAmt: {
                            content: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                            Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                            }
                        },
                    PmtId: {
                        EndToEndId: getEndToEndId(block4.MT21R?.Ref?.content, transaxion.MT70?.Nrtv?.content, transaxion.MT21.Ref.content),
                        InstrId: block4.MT20.msgId.content,
                        UETR: block3?.NdToNdTxRef?.value
                    },
                    PmtTpInf: serviceLevel is () && catPurpose is () ? () : {
                        SvcLvl: serviceLevel,
                        CtgyPurp: catPurpose
                    },
                    XchgRateInf: transaxion.MT36?.Rt is () ? () : {
                        XchgRate: check convertToDecimal(transaxion.MT36?.Rt)
                    },
                    Cdtr: getDebtorOrCreditor(transaxion.MT59A?.IdnCd, transaxion.MT59?.Acc,
                        transaxion.MT59A?.Acc, transaxion.MT59F?.Acc, (),
                        transaxion.MT59F?.Nm, transaxion.MT59?.Nm,
                        transaxion.MT59F?.AdrsLine, transaxion.MT59?.AdrsLine,
                        transaxion.MT59F?.CntyNTw, false, transaxion.MT77B?.Nrtv),
                    CdtrAcct: getCashAccountForDbtrOrCdtr(transaxion.MT59?.Acc, transaxion.MT59A?.Acc, transaxion.MT59F?.Acc),
                    CdtrAgt: getMandatoryFinancialInstitution(transaxion.MT57A?.IdnCd?.content, transaxion.MT57D?.Nm, transaxion.MT57A?.PrtyIdn,
                        (), transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn,transaxion.MT57D?.AdrsLine),
                    CdtrAgtAcct: getCashAccount(transaxion.MT57A?.PrtyIdn, (), transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn),
                    IntrmyAgt1: getOptionalFinancialInstitution(transaxion.MT56A?.IdnCd?.content, transaxion.MT56D?.Nm, transaxion.MT56A?.PrtyIdn,
                        transaxion.MT56C?.PrtyIdn, transaxion.MT56D?.PrtyIdn, (), transaxion.MT56D?.AdrsLine),
                    IntrmyAgt1Acct: getCashAccount(transaxion.MT56A?.PrtyIdn, transaxion.MT56C?.PrtyIdn, transaxion.MT56D?.PrtyIdn),
                    InstrForDbtrAgt: instrFrDbtrAgt,
                    InstrForCdtrAgt: instrFrCdtrAgt,
                    RgltryRptg: getRegulatoryReporting(transaxion.MT77B?.Nrtv?.content),
                    ChrgBr: check getDetailsChargesCd(transaxion.MT71A.Cd).ensureType(painIsoRecord:ChargeBearerType1Code),
                    RmtInf: {Ustrd: [getRemmitanceInformation(transaxion.MT70?.Nrtv?.content)], Strd: []}
                }
            ],
            DbtrAcct: getCashAccountForDbtrOrCdtr(ordgCstm50G?.Acc, ordgCstm50H?.Acc, (), ordgCstm50F?.PrtyIdn) ?: {},
            ReqdExctnDt: {
                Dt: convertToISOStandardDate(block4.MT30.Dt),
                DtTm: ""
            },
            DbtrAgt: getMandatoryFinancialInstitution(ordgInstn52A?.IdnCd?.content, (), ordgInstn52A?.PrtyIdn,
                        ordgInstn52C?.PrtyIdn, ()),
                    DbtrAgtAcct: getCashAccount(ordgInstn52A?.PrtyIdn, ordgInstn52C?.PrtyIdn),
            Dbtr: getDebtorOrCreditor(ordgCstm50G?.IdnCd, ordgCstm50G?.Acc,
                        ordgCstm50H?.Acc, (), ordgCstm50F?.PrtyIdn,
                        ordgCstm50F?.Nm, ordgCstm50H?.Nm,
                        ordgCstm50F?.AdrsLine, ordgCstm50H?.AdrsLine,
                        ordgCstm50F?.CntyNTw, true, transaxion.MT77B?.Nrtv),
            PmtMtd: "TRF",
            ChrgsAcct: getCashAccountForDbtrOrCdtr(transaxion.MT25A?.Acc, ())
        }
        );
    }
    return pmtInfArray;
}

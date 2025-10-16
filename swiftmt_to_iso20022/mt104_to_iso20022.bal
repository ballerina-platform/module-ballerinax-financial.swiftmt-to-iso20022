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

import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given SWIFT MT104 message to its corresponding ISO 20022 Pacs.003 format.
#
# This function extracts various fields from the SWIFT MT104 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT104 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs003Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT104ToPacs003(swiftmt:MT104Message message) returns pacsIsoRecord:Pacs003Envelope|error => let
    string? receiver = getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress) in {
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
                        BICFI: receiver
                    }
                }
            },
            BizMsgIdr: message.block4.MT20.msgId.content,
            MsgDefIdr: "pacs.003.001.08",
            BizSvc: "swift.cbprplus.02",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            FIToFICstmrDrctDbt: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    SttlmInf: {
                        SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B)
                    },
                    NbOfTxs: message.block4.Transaction.length().toString(),
                    MsgId: message.block4.MT20.msgId.content
                },
                DrctDbtTxInf: check getDirectDebitTransactionInfoMT104(message.block4, message.block3, receiver, getMessageSender(message.block1?.logicalTerminal,
                                message.block2.MIRLogicalTerminal))
            }
        }
    };

# Processes an MT104 direct debit message and extracts direct debit transaction information into ISO 20022 format.
# The function iterates over each transaction within the message, extracts relevant fields, and maps them 
# to the `DirectDebitTransactionInformation31` ISO record structure. It handles various transaction fields 
# such as party identifiers, account information, settlement details, and remittance information.
#
# + block4 - The parsed block4 of MT104 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT104 SWIFT message containing end to end id.
# + receiver - The receiver address extracted from the message.
# + sender - The sender address extracted from the message.
# + return - Returns an array of `DirectDebitTransactionInformation31` records, each corresponding to a transaction 
# in the input message. If any error occurs during field extraction or conversion, an error will be returned.
isolated function getDirectDebitTransactionInfoMT104(swiftmt:MT104Block4 block4, swiftmt:Block3? block3, string? receiver, string? sender)
    returns pacsIsoRecord:DirectDebitTransactionInformation31[]|error {
    pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInfArray = [];
    foreach swiftmt:MT104Transaction transaxion in block4.Transaction {
        swiftmt:MT23E? instrCd = check getMT104RepeatingFields(block4, transaxion.MT23E, "23E").ensureType();
        swiftmt:MT50A? creditor50A = check getMT104RepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50C? instgPrty50C = check getMT104RepeatingFields(block4, transaxion.MT50C, "50C").ensureType();
        swiftmt:MT50K? creditor50K = check getMT104RepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT50L? instgPrty50L = check getMT104RepeatingFields(block4, transaxion.MT50L, "50L").ensureType();
        swiftmt:MT52A? accWthInstn52A = check getMT104RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52C? accWthInstn52C = check getMT104RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        swiftmt:MT52D? accWthInstn52D = check getMT104RepeatingFields(block4, transaxion.MT52D, "52D").ensureType();
        swiftmt:MT71A? dtlsOfChrgs = check getMT104RepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltryRptg = check getMT104RepeatingFields(block4, transaxion.MT77B, "77B").ensureType();
        string remmitanceInfo = getRemmitanceInformation(transaxion.MT70?.Nrtv?.content);

        drctDbtTxInfArray.push({
            Cdtr: getDebtorOrCreditor(creditor50A?.IdnCd, creditor50K?.Acc, creditor50A?.Acc, (), (), (),
                    creditor50K?.Nm, (), creditor50K?.AdrsLine, (), false, rgltryRptg?.Nrtv),
            CdtrAcct: getCashAccount2(creditor50A?.Acc, creditor50K?.Acc),
            CdtrAgt: getFinancialInstitution(accWthInstn52A?.IdnCd?.content, (), accWthInstn52A?.PrtyIdn,
                    accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn, (), accWthInstn52D?.AdrsLine)
                        ?: {FinInstnId: {}},
            CdtrAgtAcct: getCashAccount(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn),
            DbtrAcct: getCashAccount2(transaxion.MT59?.Acc, transaxion.MT59A?.Acc) ?: {},
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT30.Dt),
            IntrBkSttlmAmt: {
                content: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                Ccy: transaxion.MT32B.Ccy.content
            },
            InstdAmt: {
                content: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
            },
            XchgRate: check convertToDecimal(transaxion.MT36?.Rt),
            DrctDbtTx: transaxion.MT21C is () ? () : {
                    MndtRltdInf: {
                        MndtId: transaxion.MT21C?.Ref?.content
                    }
                },
            ReqdColltnDt: convertToISOStandardDateMandatory(block4.MT30.Dt),
            PmtId: {
                EndToEndId: getEndToEndId(block4.MT21R?.Ref?.content, transaxion.MT70?.Nrtv?.content,
                        transaxion.MT21.Ref.content),
                InstrId: block4.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value
            },
            InstgAgt: {
                FinInstnId: {
                    BICFI: sender
                }
            },
            InstdAgt: {
                FinInstnId: {
                    BICFI: receiver
                }
            },
            PmtTpInf: instrCd is () ? () : {
                    CtgyPurp: {
                        Cd: instrCd?.InstrnCd?.content
                    }
                },
            DbtrAgt: getFinancialInstitution(transaxion.MT57A?.IdnCd?.content, transaxion.MT57D?.Nm,
                    transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn, (),
                    transaxion.MT57D?.AdrsLine) ?: {FinInstnId: {}},
            DbtrAgtAcct: getCashAccount(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn,
                    transaxion.MT57D?.PrtyIdn),
            IntrmyAgt1: getFinancialInstitution(block4.MT53A?.IdnCd?.content, (), block4.MT53A?.PrtyIdn,
                    block4.MT53B?.PrtyIdn, (), (), (), block4.MT53B?.Lctn?.content),
            IntrmyAgt1Acct: getCashAccount(block4.MT53A?.PrtyIdn, block4.MT53B?.PrtyIdn),
            InitgPty: instgPrty50C is () && instgPrty50L is () ? () : {
                    Id: {
                        OrgId: instgPrty50C is () ? () : {
                                AnyBIC: instgPrty50C?.IdnCd?.content
                            },
                        PrvtId: instgPrty50L is () ? () : {
                                Othr: [
                                    {
                                        Id: getPartyIdentifier(instgPrty50L?.PrtyIdn)
                                    }
                                ]
                            }
                    }
                },
            ChrgBr: check getDetailsChargesCd(dtlsOfChrgs?.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
            ChrgsInf: check getChargesInformation(transaxion.MT71F, transaxion.MT71G, receiver, false),
            Dbtr: getDebtorOrCreditor(transaxion.MT59A?.IdnCd, transaxion.MT59?.Acc, transaxion.MT59A?.Acc, (), (),
                    (), transaxion.MT59?.Nm, (), transaxion.MT59?.AdrsLine, (), true, rgltryRptg?.Nrtv),
            RgltryRptg: getRegulatoryReporting(rgltryRptg?.Nrtv?.content),
            RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []}
        }
            );
    }
    return drctDbtTxInfArray;
}

# Transforms the given SWIFT MT104 message to its corresponding ISO 20022 Pain.008 format.
#
# This function extracts various fields from the SWIFT MT104 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT104 message as a record value.
# + return - Returns the transformed ISO 20022 `Pain008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT104ToPain008(swiftmt:MT104Message message) returns painIsoRecord:Pain008Envelope|error => {
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
        MsgDefIdr: "pain.008.001.08",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string)
    },
    Document: {
        CstmrDrctDbtInitn: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string),
                InitgPty: message.block4.MT50C is () && message.block4.MT50L is () ? {Id: {OrgId: {AnyBIC: "NOTPROVIDED"}}} : {
                        Id: {
                            OrgId: message.block4.MT50C is () ? () : {
                                    AnyBIC: message.block4.MT50C?.IdnCd?.content
                                },
                            PrvtId: message.block4.MT50L is () ? {} : {
                                    Othr: [
                                        {
                                            Id: getPartyIdentifier(message.block4.MT50L?.PrtyIdn)
                                        }
                                    ]
                                }
                        }
                    },
                FwdgAgt: getFinancialInstitution(message.block4.MT51A?.IdnCd?.content, (),
                        message.block4.MT51A?.PrtyIdn, ()),
                NbOfTxs: message.block4.Transaction.length().toString(),
                MsgId: message.block4.MT20.msgId.content
            },
            PmtInf: check getPaymentInformationOfMT104(message.block4, message.block3)
        }
    }
};

# Processes an MT104 message and extracts payment information into ISO 20022 format.
# This function maps the SWIFT MT104 transaction details into an array of `PaymentInstruction45` ISO records.
# It extracts important fields such as creditor information, settlement details, and payment method from 
# each transaction.
#
# + block4 - The parsed block4 of MT104 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT104 SWIFT message containing end to end id.
# + return - Returns an array of `PaymentInstruction45` records, each corresponding to a transaction 
# in the input message. An error is returned if any field extraction or conversion fails.
isolated function getPaymentInformationOfMT104(swiftmt:MT104Block4 block4, swiftmt:Block3? block3)
    returns painIsoRecord:PaymentInstruction45[]|error {
    painIsoRecord:PaymentInstruction45[] paymentInstructionArray = [];
    foreach swiftmt:MT104Transaction transaxion in block4.Transaction {
        swiftmt:MT26T? trnsTp = check getMT104RepeatingFields(block4, transaxion.MT26T, "26T").ensureType();
        swiftmt:MT50A? creditor50A = check getMT104RepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50K? creditor50K = check getMT104RepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT52A? accWthInstn52A = check getMT104RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52C? accWthInstn52C = check getMT104RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        swiftmt:MT52D? accWthInstn52D = check getMT104RepeatingFields(block4, transaxion.MT52D, "52D").ensureType();
        swiftmt:MT71A? dtlsOfChrgs = check getMT104RepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltryRptg = check getMT104RepeatingFields(block4, transaxion.MT77B, "77B").ensureType();
        string remmitanceInfo = getRemmitanceInformation(transaxion.MT70?.Nrtv?.content);
        string|error chargeBearer= getDetailsChargesCd(dtlsOfChrgs?.Cd);

        paymentInstructionArray.push({
            Cdtr: getDebtorOrCreditor(creditor50A?.IdnCd, creditor50K?.Acc, creditor50A?.Acc, (), (), (),
                    creditor50K?.Nm, (), creditor50K?.AdrsLine, (), false, rgltryRptg?.Nrtv, true),
            ReqdColltnDt: convertToISOStandardDateMandatory(block4.MT30.Dt),
            BtchBookg: false,
            CdtrAcct: getCashAccount2(creditor50A?.Acc, creditor50K?.Acc) ?: {},
            CdtrAgt: getFinancialInstitution(accWthInstn52A?.IdnCd?.content, (), accWthInstn52A?.PrtyIdn,
                    accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn, (), accWthInstn52D?.AdrsLine)
                        ?: {FinInstnId: {}},
            CdtrAgtAcct: getCashAccount(accWthInstn52A?.PrtyIdn, accWthInstn52C?.PrtyIdn, accWthInstn52D?.PrtyIdn),
            PmtInfId: transaxion.MT21.Ref.content,
            ChrgBr: chargeBearer is error ? () : check chargeBearer.ensureType(painIsoRecord:ChargeBearerType1Code),
            DrctDbtTxInf: [
                {
                    DrctDbtTx: transaxion.MT21C is () ? () : {
                            MndtRltdInf: {
                                MndtId: transaxion.MT21C?.Ref?.content
                            }
                        },
                    DbtrAcct: getCashAccount2(transaxion.MT59?.Acc, transaxion.MT59A?.Acc) ?: {},
                    PmtId: {
                        EndToEndId: getEndToEndId(block4.MT21R?.Ref?.content, transaxion.MT70?.Nrtv?.content,
                                transaxion.MT21.Ref.content),
                        InstrId: block4.MT20.msgId.content,
                        UETR: block3?.NdToNdTxRef?.value
                    },
                    DbtrAgt: getFinancialInstitution(transaxion.MT57A?.IdnCd?.content, transaxion.MT57D?.Nm,
                            transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn, transaxion.MT57D?.PrtyIdn, (),
                            transaxion.MT57D?.AdrsLine) ?: {FinInstnId: {}},
                    DbtrAgtAcct: getCashAccount(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn,
                            transaxion.MT57D?.PrtyIdn),
                    InstdAmt: {
                        content: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                        Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
                    },
                    Dbtr: getDebtorOrCreditor(transaxion.MT59A?.IdnCd, transaxion.MT59?.Acc,
                            transaxion.MT59A?.Acc, (), (), (), transaxion.MT59?.Nm, (), transaxion.MT59?.AdrsLine, (),
                            true, rgltryRptg?.Nrtv, true),
                    RgltryRptg: getRegulatoryReporting(rgltryRptg?.Nrtv?.content),
                    RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []},
                    Purp: trnsTp is () ? () : {
                            Prtry: getMandatoryFields(trnsTp?.Typ?.content)
                        }
                }
            ],
            PmtMtd: "DD"
        });
    }
    return paymentInstructionArray;
}

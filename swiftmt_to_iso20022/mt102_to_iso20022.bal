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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given SWIFT MT102STP message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT102STP message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT102STP message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure transforming the SWIFT message to ISO 20022 format.
isolated function transformMT102STPToPacs008(swiftmt:MT102STPMessage message)
    returns pacsIsoRecord:Pacs008Envelope|error => {
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
        MsgDefIdr: "pacs.008.001.12",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string) 
    },
    Document: {
        FIToFICstmrCdtTrf: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string) ,
                SttlmInf: {
                    SttlmMtd: getSettlementMethod(message.block4.MT53A),
                    InstgRmbrsmntAgt: getFinancialInstitution(message.block4.MT53A?.IdnCd?.content,
                            (), message.block4.MT53A?.PrtyIdn, ()),
                    InstgRmbrsmntAgtAcct: getCashAccount2(message.block4.MT53C?.Acc, (),
                            acc4 = message.block4.MT53A?.PrtyIdn),
                    InstdRmbrsmntAgt: getFinancialInstitution(message.block4.MT54A?.IdnCd?.content,
                            (), message.block4.MT54A?.PrtyIdn, ()),
                    InstdRmbrsmntAgtAcct: getCashAccount(message.block4.MT54A?.PrtyIdn, ())
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
                NbOfTxs: message.block4.Transaction.length().toString(),
                TtlIntrBkSttlmAmt: {
                    content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                    Ccy: message.block4.MT32A.Ccy.content
                },
                CtrlSum: check convertToDecimal(message.block4.MT19?.Amnt),
                MsgId: message.block4.MT20.msgId.content
            },
            CdtTrfTxInf: check getMT102STPCreditTransferTransactionInfo(message.block4, message.block3)
        }
    }
};

# Processes an MT102 STP message and extracts credit transfer transaction information into ISO 20022 format.
# The function iterates over each transaction within the message, extracts relevant fields, and maps them 
# to the `CreditTransferTransaction64` ISO record structure. It handles various transaction fields such as 
# party identifiers, account information, currency amounts, and regulatory reporting.
#
# + block4 - The parsed block4 of MT102 STP SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT102 STP SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction64` records, each corresponding to a transaction 
# in the input message. If any error occurs during field extraction or conversion, an error will be returned.
isolated function getMT102STPCreditTransferTransactionInfo(swiftmt:MT102STPBlock4 block4, swiftmt:Block3? block3)
    returns pacsIsoRecord:CreditTransferTransaction64[]|error {
    pacsIsoRecord:CreditTransferTransaction64[] cdtTrfTxInfArray = [];
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(block4.MT13C);
    [InstructionForCreditorAgentArray, InstructionForNextAgent1Array,
            pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?,
            pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
            pacsIsoRecord:CategoryPurpose1Choice?] [instrFrCdtrAgt, instrFrNxtAgt, prvsInstgAgt1, intrmyAgt1,
            serviceLevel, lclInstrm, purpose] = check getMT1XXSenderToReceiverInformation(block4.MT72);
    foreach swiftmt:MT102STPTransaction transaxion in block4.Transaction {
        swiftmt:MT26T? trnsTyp = check getMT102STPRepeatingFields(block4, transaxion.MT26T, "26T").ensureType();
        swiftmt:MT36? xchgRate = check getMT102STPRepeatingFields(block4, transaxion.MT36, "36").ensureType();
        swiftmt:MT50F? ordgCstm50F = check getMT102STPRepeatingFields(block4, transaxion.MT50F, "50F").ensureType();
        swiftmt:MT50A? ordgCstm50A = check getMT102STPRepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50K? ordgCstm50K = check getMT102STPRepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT52A? ordgInstn52A = check getMT102STPRepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT71A? dtlsChrgsCd = check getMT102STPRepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltyRptg = check getMT102STPRepeatingFields(block4, transaxion.MT77B, "77B").ensureType();
        string remmitanceInfo = getRemmitanceInformation(transaxion.MT70?.Nrtv?.content);

        cdtTrfTxInfArray.push({
            Cdtr: getDebtorOrCreditor(transaxion.MT59A?.IdnCd, transaxion.MT59?.Acc,
                    transaxion.MT59A?.Acc, transaxion.MT59F?.Acc, (),
                    transaxion.MT59F?.Nm, transaxion.MT59?.Nm,
                    transaxion.MT59F?.AdrsLine, transaxion.MT59?.AdrsLine,
                    transaxion.MT59F?.CntyNTw, false, rgltyRptg?.Nrtv),
            CdtrAcct: getCashAccount2(transaxion.MT59?.Acc, transaxion.MT59A?.Acc, transaxion.MT59F?.Acc),
            CdtrAgt: getFinancialInstitution(transaxion.MT57A?.IdnCd?.content, (), transaxion.MT57A?.PrtyIdn,
                    ()) ?: {FinInstnId: {}},
            CdtrAgtAcct: getCashAccount(transaxion.MT57A?.PrtyIdn, ()),
            IntrBkSttlmAmt: {
                content: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                Ccy: transaxion.MT32B.Ccy.content
            },
            PmtId: {
                EndToEndId: getEndToEndId(remmitanceInfo = transaxion.MT70?.Nrtv?.content,
                        transactionId = transaxion.MT21.Ref.content),
                InstrId: block4.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value
            },
            PmtTpInf: serviceLevel is () && purpose is () && lclInstrm is () ? () : {
                    SvcLvl: serviceLevel is () ? () : [
                            {
                                Cd: serviceLevel
                            }
                        ],
                    LclInstrm: lclInstrm,
                    CtgyPurp: purpose
                },
            SttlmTmReq: clsTime is () ? () : {
                    CLSTm: clsTime
                },
            SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                    CdtDtTm: crdtTime,
                    DbtDtTm: dbitTime
                },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT32A.Dt),
            XchgRate: check convertToDecimal(xchgRate?.Rt),
            InstdAmt: {
                content: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
            },
            DbtrAgt: getFinancialInstitution(ordgInstn52A?.IdnCd?.content, (), ordgInstn52A?.PrtyIdn,
                    ()) ?: {FinInstnId: {}},
            DbtrAgtAcct: getCashAccount(ordgInstn52A?.PrtyIdn, ()),
            ChrgBr: check getDetailsChargesCd(dtlsChrgsCd?.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
            DbtrAcct: getCashAccount2(ordgCstm50A?.Acc, ordgCstm50K?.Acc, (), ordgCstm50F?.PrtyIdn),
            Dbtr: getDebtorOrCreditor(ordgCstm50A?.IdnCd, ordgCstm50A?.Acc, ordgCstm50K?.Acc, (),
                    ordgCstm50F?.PrtyIdn, ordgCstm50F?.Nm, ordgCstm50K?.Nm, ordgCstm50F?.AdrsLine,
                    ordgCstm50K?.AdrsLine, ordgCstm50F?.CntyNTw, true, rgltyRptg?.Nrtv),
            PrvsInstgAgt1: prvsInstgAgt1,
            IntrmyAgt1: intrmyAgt1,
            ChrgsInf: check getChargesInformation(transaxion.MT71F, transaxion.MT71G),
            RgltryRptg: getRegulatoryReporting(rgltyRptg?.Nrtv?.content),
            RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []},
            InstrForNxtAgt: instrFrNxtAgt,
            InstrForCdtrAgt: instrFrCdtrAgt,
            Purp: trnsTyp is () ? () : {
                    Prtry: getMandatoryFields(trnsTyp?.Typ?.content)
                }
        });
    }
    return cdtTrfTxInfArray;
}

# Transforms the given SWIFT MT102 message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT102 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT102 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT102ToPcs008(swiftmt:MT102Message message) returns pacsIsoRecord:Pacs008Envelope|error => {
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
        MsgDefIdr: "pacs.008.001.12",
        BizSvc: "swift.cbprplus.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string) 
    },
    Document: {
        FIToFICstmrCdtTrf: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string) ,
                SttlmInf: {
                    SttlmMtd: getSettlementMethod(message.block4.MT53A),
                    InstgRmbrsmntAgt: getFinancialInstitution(message.block4.MT53A?.IdnCd?.content,
                            (), message.block4.MT53A?.PrtyIdn, ()),
                    InstgRmbrsmntAgtAcct: getCashAccount2(message.block4.MT53C?.Acc, (),
                            acc4 = message.block4.MT53A?.PrtyIdn),
                    InstdRmbrsmntAgt: getFinancialInstitution(message.block4.MT54A?.IdnCd?.content,
                            (), message.block4.MT54A?.PrtyIdn, ()),
                    InstdRmbrsmntAgtAcct: getCashAccount(message.block4.MT54A?.PrtyIdn, ())
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
                NbOfTxs: message.block4.Transaction.length().toString(),
                TtlIntrBkSttlmAmt: {
                    content: check getTotalInterBankSettlementAmount(message.block4.MT19, message.block4.MT32A),
                    Ccy: message.block4.MT32A.Ccy.content
                },
                MsgId: message.block4.MT20.msgId.content
            },
            CdtTrfTxInf: check getMT102CreditTransferTransactionInfo(message.block4, message.block3)
        }
    }
};

# Processes an MT102 message and extracts credit transfer transaction information into ISO 20022 format.
# The function iterates over each transaction within the message, extracts relevant fields, and maps them 
# to the `CreditTransferTransaction64` ISO record structure. It handles various transaction fields such as 
# party identifiers, account information, currency amounts, and regulatory reporting.
#
# + block4 - The parsed block4 of MT102 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT102 SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction64` records, each corresponding to a transaction 
# in the input message. If any error occurs during field extraction or conversion, an error will be returned.
isolated function getMT102CreditTransferTransactionInfo(swiftmt:MT102Block4 block4, swiftmt:Block3? block3)
    returns pacsIsoRecord:CreditTransferTransaction64[]|error {
    pacsIsoRecord:CreditTransferTransaction64[] cdtTrfTxInfArray = [];
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(block4.MT13C);
    [InstructionForCreditorAgentArray, InstructionForNextAgent1Array,
            pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?,
            pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
            pacsIsoRecord:CategoryPurpose1Choice?] [instrFrCdtrAgt, instrFrNxtAgt, prvsInstgAgt1, intrmyAgt1,
            serviceLevel, lclInstrm, purpose] = check getMT1XXSenderToReceiverInformation(block4.MT72);
    foreach swiftmt:MT102Transaction transaxion in block4.Transaction {
        swiftmt:MT26T? trnsTyp = check getMT102RepeatingFields(block4, transaxion.MT26T, "26T").ensureType();
        swiftmt:MT36? xchgRate = check getMT102RepeatingFields(block4, transaxion.MT36, "36").ensureType();
        swiftmt:MT50F? ordgCstm50F = check getMT102RepeatingFields(block4, transaxion.MT50F, "50F").ensureType();
        swiftmt:MT50A? ordgCstm50A = check getMT102RepeatingFields(block4, transaxion.MT50A, "50A").ensureType();
        swiftmt:MT50K? ordgCstm50K = check getMT102RepeatingFields(block4, transaxion.MT50K, "50K").ensureType();
        swiftmt:MT52A? ordgInstn52A = check getMT102RepeatingFields(block4, transaxion.MT52A, "52A").ensureType();
        swiftmt:MT52B? ordgInstn52B = check getMT102RepeatingFields(block4, transaxion.MT52B, "52B").ensureType();
        swiftmt:MT52C? ordgInstn52C = check getMT102RepeatingFields(block4, transaxion.MT52C, "52C").ensureType();
        swiftmt:MT71A? dtlsChrgsCd = check getMT102RepeatingFields(block4, transaxion.MT71A, "71A").ensureType();
        swiftmt:MT77B? rgltyRptg = check getMT102RepeatingFields(block4, transaxion.MT77B, "77B").ensureType();
        string remmitanceInfo = getRemmitanceInformation(transaxion.MT70?.Nrtv?.content);

        cdtTrfTxInfArray.push({
            Cdtr: getDebtorOrCreditor(transaxion.MT59A?.IdnCd, transaxion.MT59?.Acc,
                    transaxion.MT59A?.Acc, transaxion.MT59F?.Acc, (),
                    transaxion.MT59F?.Nm, transaxion.MT59?.Nm,
                    transaxion.MT59F?.AdrsLine, transaxion.MT59?.AdrsLine,
                    transaxion.MT59F?.CntyNTw, false, rgltyRptg?.Nrtv),
            CdtrAcct: getCashAccount2(transaxion.MT59?.Acc, transaxion.MT59A?.Acc, transaxion.MT59F?.Acc),
            CdtrAgt: getFinancialInstitution(transaxion.MT57A?.IdnCd?.content, (), transaxion.MT57A?.PrtyIdn,
                    transaxion.MT57C?.PrtyIdn) ?: {FinInstnId: {}},
            CdtrAgtAcct: getCashAccount(transaxion.MT57A?.PrtyIdn, transaxion.MT57C?.PrtyIdn),
            IntrBkSttlmAmt: {
                content: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                Ccy: transaxion.MT32B.Ccy.content
            },
            PmtId: {
                EndToEndId: getEndToEndId(remmitanceInfo = transaxion.MT70?.Nrtv?.content,
                        transactionId = transaxion.MT21.Ref.content),
                InstrId: block4.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value
            },
            PmtTpInf: serviceLevel is () && purpose is () && lclInstrm is () ? () : {
                    SvcLvl: serviceLevel is () ? () : [
                            {
                                Cd: serviceLevel
                            }
                        ],
                    LclInstrm: lclInstrm,
                    CtgyPurp: purpose
                },
            SttlmTmReq: clsTime is () ? () : {
                    CLSTm: clsTime
                },
            SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                    CdtDtTm: crdtTime,
                    DbtDtTm: dbitTime
                },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT32A.Dt),
            XchgRate: check convertToDecimal(xchgRate?.Rt),
            InstdAmt: {
                content: check getInstructedAmount(transaxion.MT32B, transaxion.MT33B),
                Ccy: getCurrency(transaxion.MT33B?.Ccy?.content, transaxion.MT32B.Ccy.content)
            },
            DbtrAgt: getFinancialInstitution(ordgInstn52A?.IdnCd?.content, (), ordgInstn52A?.PrtyIdn,
                    ordgInstn52B?.PrtyIdn, ordgInstn52C?.PrtyIdn, (), (), ordgInstn52B?.Lctn?.content)
                        ?: {FinInstnId: {}},
            DbtrAgtAcct: getCashAccount(ordgInstn52A?.PrtyIdn, ordgInstn52B?.PrtyIdn, ordgInstn52C?.PrtyIdn),
            ChrgBr: check getDetailsChargesCd(dtlsChrgsCd?.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
            DbtrAcct: getCashAccount2(ordgCstm50A?.Acc, ordgCstm50K?.Acc, (), ordgCstm50F?.PrtyIdn),
            Dbtr: getDebtorOrCreditor(ordgCstm50A?.IdnCd, ordgCstm50A?.Acc, ordgCstm50K?.Acc, (),
                    ordgCstm50F?.PrtyIdn, ordgCstm50F?.Nm, ordgCstm50K?.Nm, ordgCstm50F?.AdrsLine,
                    ordgCstm50K?.AdrsLine, ordgCstm50F?.CntyNTw, true, rgltyRptg?.Nrtv),
            PrvsInstgAgt1: prvsInstgAgt1,
            IntrmyAgt1: intrmyAgt1,
            ChrgsInf: check getChargesInformation(transaxion.MT71F, transaxion.MT71G),
            RgltryRptg: getRegulatoryReporting(rgltyRptg?.Nrtv?.content),
            RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []},
            InstrForNxtAgt: instrFrNxtAgt,
            InstrForCdtrAgt: instrFrCdtrAgt,
            Purp: trnsTyp is () ? () : {
                    Prtry: getMandatoryFields(trnsTyp?.Typ?.content)
                }
        });
    }
    return cdtTrfTxInfArray;
}

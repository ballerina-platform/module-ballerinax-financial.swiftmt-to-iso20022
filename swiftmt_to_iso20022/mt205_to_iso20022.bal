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

# This function transforms an MT205 message into an ISO 20022 `Pacs009Document`.
#
# + message - The parsed MT205 message as a record type.
# + return - Returns a `Pacs009Document` containing the payment instruction information, 
# or an error if the transformation fails.
isolated function transformMT205ToPacs009(swiftmt:MT205Message message) returns pacsIsoRecord:Pacs009Envelope|error =>
    let [pacsIsoRecord:InstructionForCreditorAgent3[], pacsIsoRecord:InstructionForNextAgent1[],
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?,
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
    pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:RemittanceInformation2?, pacsIsoRecord:Purpose2Choice?]
    [instrFrCdtrAgt, instrFrNxtAgt, prvsInstgAgt1, intrmyAgt2, serviceLevel, lclInstrm, catPurpose, remmitanceInfo,
    purpose] = check getMT2XXSenderToReceiverInfo(message.block4.MT72),
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C) in {
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
            MsgDefIdr: "pacs.009.001.09",
            BizSvc: "swift.cbprplus.02",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string) + DEFAULT_TIME_OFFSET
        },
        Document: {
            FICdtTrf: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string) + DEFAULT_TIME_OFFSET,
                    SttlmInf: {
                        SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B, message.block4.MT53D),
                        InstgRmbrsmntAgt: getFinancialInstitution(message.block4.MT53A?.IdnCd?.content,
                                message.block4.MT53D?.Nm, message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
                                message.block4.MT53D?.PrtyIdn, (), message.block4.MT53D?.AdrsLine,
                                message.block4.MT53B?.Lctn?.content),
                        InstgRmbrsmntAgtAcct: getCashAccount(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
                                message.block4.MT53D?.PrtyIdn)
                    },
                    NbOfTxs: DEFAULT_NUM_OF_TX,
                    MsgId: message.block4.MT20.msgId.content
                },
                CdtTrfTxInf: [
                    {
                        Cdtr: getFinancialInstitution(message.block4.MT58A?.IdnCd?.content, message.block4.MT58D?.Nm,
                                message.block4.MT58A?.PrtyIdn, message.block4.MT58D?.PrtyIdn, (), (),
                                message.block4.MT58D?.AdrsLine) ?: {FinInstnId: {}},
                        CdtrAcct: getCashAccount(message.block4.MT58A?.PrtyIdn, message.block4.MT58D?.PrtyIdn),
                        CdtrAgt: getFinancialInstitution(message.block4.MT57A?.IdnCd?.content, message.block4.MT57D?.Nm,
                                message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57D?.PrtyIdn,
                                (), message.block4.MT57D?.AdrsLine, message.block4.MT57B?.Lctn?.content),
                        CdtrAgtAcct: getCashAccount(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn,
                                message.block4.MT57D?.PrtyIdn),
                        IntrBkSttlmAmt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                        PmtId: {
                            EndToEndId: message.block4.MT21.Ref.content,
                            InstrId: message.block4.MT20.msgId.content,
                            UETR: message.block3?.NdToNdTxRef?.value
                        },
                        InstgAgt: {
                            FinInstnId: {
                                BICFI: getMessageSender(message.block1?.logicalTerminal,
                                        message.block2.MIRLogicalTerminal)
                            }
                        },
                        InstdAgt: {
                            FinInstnId: {
                                BICFI: getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress)
                            }
                        },
                        PmtTpInf: serviceLevel is () && catPurpose is () && lclInstrm is () ? () : {
                                SvcLvl: serviceLevel is () ? () : [
                                        {
                                            Cd: serviceLevel
                                        }
                                    ],
                                CtgyPurp: catPurpose,
                                LclInstrm: lclInstrm
                            },
                        SttlmTmReq: clsTime is () ? () : {
                                CLSTm: clsTime
                            },
                        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                                CdtDtTm: crdtTime,
                                DbtDtTm: dbitTime
                            },
                        Dbtr: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, message.block4.MT52D?.Nm,
                                message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (), (),
                                message.block4.MT52D?.AdrsLine) ?: {FinInstnId: {}},
                        DbtrAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
                        IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content, message.block4.MT56D?.Nm,
                                message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn, (), (),
                                message.block4.MT56D?.AdrsLine),
                        IntrmyAgt1Acct: getCashAccount(message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn),
                        IntrmyAgt2: intrmyAgt2,
                        PrvsInstgAgt1: prvsInstgAgt1,
                        InstrForNxtAgt: instrFrNxtAgt,
                        InstrForCdtrAgt: instrFrCdtrAgt,
                        RmtInf: remmitanceInfo,
                        Purp: purpose
                    }
                ]
            }
        }
    };

# This function transforms an MT205COV message into an ISO 20022 `Pacs009Document`.
#
# + message - The parsed MT205COV message as a record value.
# + return - Returns a `Pacs009Document` containing the payment instruction information, 
# or an error if the transformation fails.
isolated function transformMT205COVToPacs009(swiftmt:MT205COVMessage message)
    returns pacsIsoRecord:Pacs009Envelope|error => {
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
        MsgDefIdr: "pacs.009.001.11",
        BizSvc: "swift.cbprplus.cov.02",
        CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                true).ensureType(string) + DEFAULT_TIME_OFFSET
    },
    Document: {
        FICdtTrf: {
            GrpHdr: {
                CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                        true).ensureType(string) + DEFAULT_TIME_OFFSET,
                SttlmInf: {
                    SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B,
                            message.block4.MT53D),
                    InstgRmbrsmntAgt: getFinancialInstitution(message.block4.MT53A?.IdnCd?.content,
                            message.block4.MT53D?.Nm, message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
                            message.block4.MT53D?.PrtyIdn, (), message.block4.MT53D?.AdrsLine,
                            message.block4.MT53B?.Lctn?.content),
                    InstgRmbrsmntAgtAcct: getCashAccount(message.block4.MT53A?.PrtyIdn,
                            message.block4.MT53B?.PrtyIdn, message.block4.MT53D?.PrtyIdn)
                },
                NbOfTxs: DEFAULT_NUM_OF_TX,
                MsgId: message.block4.MT20.msgId.content
            },
            CdtTrfTxInf: check getMT205COVCreditTransfer(message, message.block4, message.block3)
        }
    }
};

# This function extracts credit transfer transaction details from an MT205COV message and returns an array of 
# `CreditTransferTransaction62` records for ISO 20022.
#
# + message - The parsed message of MT205 COV SWIFT message.
# + block4 - The parsed block4 of MT205 COV SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT205 COV SWIFT message containing end to end id.
# + return - Returns an array of `camtIsoRecord:CreditTransferTransaction62` containing the credit transfer 
# transaction information, or an error if the extraction fails.
isolated function getMT205COVCreditTransfer(swiftmt:MT205COVMessage message, swiftmt:MT205COVBlock4 block4,
        swiftmt:Block3? block3) returns pacsIsoRecord:CreditTransferTransaction62[]|error {

    pacsIsoRecord:CreditTransferTransaction62[] cdtTrfTxInfArray = [];
    swiftmt:MT52A? ordgInstn52A = check getUnderlyingCustomerTransactionField52(block4.UndrlygCstmrCdtTrf.MT52A,
            block4.UndrlygCstmrCdtTrf.MT52D, block4)[0].ensureType();
    swiftmt:MT52D? ordgInstn52D = check getUnderlyingCustomerTransactionField52(block4.UndrlygCstmrCdtTrf.MT52A,
            block4.UndrlygCstmrCdtTrf.MT52D, block4)[1].ensureType();
    swiftmt:MT57A? cdtrAgt57A = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A,
            block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[0].ensureType();
    swiftmt:MT57B? cdtrAgt57B = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A,
            block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[1].ensureType();
    swiftmt:MT57C? cdtrAgt57C = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A,
            block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[2].ensureType();
    swiftmt:MT57D? cdtrAgt57D = check getUnderlyingCustomerTransactionField57(block4.UndrlygCstmrCdtTrf.MT57A,
            block4.UndrlygCstmrCdtTrf.MT57B, (), block4.UndrlygCstmrCdtTrf.MT52D, block4)[3].ensureType();
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C);
    [InstructionForCreditorAgentArray, InstructionForNextAgent1Array,
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?,
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?, string?, pacsIsoRecord:LocalInstrument2Choice?,
        pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:RemittanceInformation2?, pacsIsoRecord:Purpose2Choice?]
        [instrFrCdtrAgt, instrFrNxtAgt, prvsInstgAgt1, intrmyAgt2, serviceLevel, lclInstrm, catPurpose, remmitanceInfo,
        purpose] = check getMT2XXSenderToReceiverInfo(message.block4.MT72);
    string remmitanceInfo2 = getRemmitanceInformation(block4.UndrlygCstmrCdtTrf.MT70?.Nrtv?.content);

    cdtTrfTxInfArray.push({
        Cdtr: getFinancialInstitution(block4.MT58A?.IdnCd?.content, block4.MT58D?.Nm, block4.MT58A?.PrtyIdn,
                block4.MT58D?.PrtyIdn, (), (), block4.MT58D?.AdrsLine) ?: {FinInstnId: {}},
        CdtrAcct: getCashAccount(block4.MT58A?.PrtyIdn, block4.MT58D?.PrtyIdn),
        CdtrAgt: getFinancialInstitution(block4.MT57A?.IdnCd?.content, block4.MT57D?.Nm, block4.MT57A?.PrtyIdn,
                block4.MT57B?.PrtyIdn, block4.MT57D?.PrtyIdn, (), block4.MT57D?.AdrsLine, block4.MT57B?.Lctn?.content),
        CdtrAgtAcct: getCashAccount(block4.MT57A?.PrtyIdn, block4.MT57B?.PrtyIdn, block4.MT57D?.PrtyIdn),
        IntrBkSttlmAmt: {
            content: check convertToDecimalMandatory(block4.MT32A.Amnt),
            Ccy: block4.MT32A.Ccy.content
        },
        IntrBkSttlmDt: convertToISOStandardDate(block4.MT32A.Dt),
        PmtId: {
            EndToEndId: block4.MT21.Ref.content,
            InstrId: block4.MT20.msgId.content,
            UETR: block3?.NdToNdTxRef?.value
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
        PmtTpInf: serviceLevel is () && catPurpose is () && lclInstrm is () ? () : {
                SvcLvl: serviceLevel is () ? () : [
                        {
                            Cd: serviceLevel
                        }
                    ],
                CtgyPurp: catPurpose,
                LclInstrm: lclInstrm
            },
        SttlmTmReq: clsTime is () ? () : {
                CLSTm: clsTime
            },
        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                CdtDtTm: crdtTime,
                DbtDtTm: dbitTime
            },
        Dbtr: getFinancialInstitution(block4.MT52A?.IdnCd?.content, block4.MT52D?.Nm, block4.MT52A?.PrtyIdn,
                block4.MT52D?.PrtyIdn, (), (), block4.MT52D?.AdrsLine) ?: {FinInstnId: {}},
        DbtrAcct: getCashAccount(block4.MT52A?.PrtyIdn, block4.MT52D?.PrtyIdn),
        IntrmyAgt1: getFinancialInstitution(block4.MT56A?.IdnCd?.content, block4.MT56D?.Nm, block4.MT56A?.PrtyIdn,
                block4.MT56D?.PrtyIdn, (), (), block4.MT56D?.AdrsLine),
        IntrmyAgt1Acct: getCashAccount(block4.MT56A?.PrtyIdn, block4.MT56D?.PrtyIdn),
        IntrmyAgt2: intrmyAgt2,
        PrvsInstgAgt1: prvsInstgAgt1,
        InstrForNxtAgt: instrFrNxtAgt,
        InstrForCdtrAgt: instrFrCdtrAgt,
        RmtInf: remmitanceInfo,
        Purp: purpose,
        UndrlygCstmrCdtTrf: {
            Dbtr: getDebtorOrCreditor(block4.UndrlygCstmrCdtTrf.MT50A?.IdnCd, block4.UndrlygCstmrCdtTrf.MT50A?.Acc,
                    block4.UndrlygCstmrCdtTrf.MT50K?.Acc, (), block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn,
                    block4.UndrlygCstmrCdtTrf.MT50F?.Nm, block4.UndrlygCstmrCdtTrf.MT50K?.Nm,
                    block4.UndrlygCstmrCdtTrf.MT50F?.AdrsLine, block4.UndrlygCstmrCdtTrf.MT50K?.AdrsLine,
                    block4.UndrlygCstmrCdtTrf.MT50F?.CntyNTw, true),
            DbtrAcct: getCashAccount2(block4.UndrlygCstmrCdtTrf.MT50A?.Acc, block4.UndrlygCstmrCdtTrf.MT50K?.Acc,
                    (), block4.UndrlygCstmrCdtTrf.MT50F?.PrtyIdn),
            DbtrAgt: getFinancialInstitution(ordgInstn52A?.IdnCd?.content, ordgInstn52D?.Nm, ordgInstn52A?.PrtyIdn,
                    ordgInstn52D?.PrtyIdn, (), (), ordgInstn52D?.AdrsLine) ?: {FinInstnId: {}},
            DbtrAgtAcct: getCashAccount(ordgInstn52A?.PrtyIdn, ordgInstn52D?.PrtyIdn),
            InstdAmt: (check getInstructedAmount(instrdAmnt = block4.UndrlygCstmrCdtTrf.MT33B)).toString() == "0"
                ? () : {
                    content: check getInstructedAmount(instrdAmnt = block4.UndrlygCstmrCdtTrf.MT33B),
                    Ccy: getMandatoryFields(block4.UndrlygCstmrCdtTrf.MT33B?.Ccy?.content)
                },
            IntrmyAgt1: getFinancialInstitution(block4.UndrlygCstmrCdtTrf.MT56A?.IdnCd?.content,
                    block4.UndrlygCstmrCdtTrf.MT56D?.Nm, block4.UndrlygCstmrCdtTrf.MT56A?.PrtyIdn,
                    block4.UndrlygCstmrCdtTrf.MT56D?.PrtyIdn, (), (), block4.UndrlygCstmrCdtTrf.MT56D?.AdrsLine),
            IntrmyAgt1Acct: getCashAccount(block4.UndrlygCstmrCdtTrf.MT56A?.PrtyIdn,
                    block4.UndrlygCstmrCdtTrf.MT56D?.PrtyIdn),
            CdtrAgt: getFinancialInstitution(cdtrAgt57A?.IdnCd?.content, cdtrAgt57D?.Nm, cdtrAgt57A?.PrtyIdn,
                    cdtrAgt57D?.PrtyIdn, (), (), cdtrAgt57D?.AdrsLine) ?: {FinInstnId: {}},
            CdtrAgtAcct: getCashAccount(cdtrAgt57A?.PrtyIdn, cdtrAgt57B?.PrtyIdn, cdtrAgt57C?.PrtyIdn,
                    cdtrAgt57D?.PrtyIdn),
            Cdtr: getDebtorOrCreditor(block4.UndrlygCstmrCdtTrf.MT59A?.IdnCd, block4.UndrlygCstmrCdtTrf.MT59?.Acc,
                    block4.UndrlygCstmrCdtTrf.MT59A?.Acc, block4.UndrlygCstmrCdtTrf.MT59F?.Acc, (),
                    block4.UndrlygCstmrCdtTrf.MT59F?.Nm, block4.UndrlygCstmrCdtTrf.MT59?.Nm,
                    block4.UndrlygCstmrCdtTrf.MT59F?.AdrsLine, block4.UndrlygCstmrCdtTrf.MT59?.AdrsLine,
                    block4.UndrlygCstmrCdtTrf.MT59F?.CntyNTw),
            CdtrAcct: getCashAccount2(block4.UndrlygCstmrCdtTrf.MT59?.Acc, block4.UndrlygCstmrCdtTrf.MT59A?.Acc,
                    block4.UndrlygCstmrCdtTrf.MT59F?.Acc),
            IntrmyAgt2: (check getMT2XXSenderToReceiverInfo(block4.UndrlygCstmrCdtTrf.MT72))[3],
            PrvsInstgAgt1: (check getMT2XXSenderToReceiverInfo(block4.UndrlygCstmrCdtTrf.MT72))[2],
            InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(block4.UndrlygCstmrCdtTrf.MT72))[1],
            InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(block4.UndrlygCstmrCdtTrf.MT72))[0],
            RmtInf: remmitanceInfo2 == "" ? () : {
                    Ustrd: [
                        getRemmitanceInformation(
                                block4.UndrlygCstmrCdtTrf.MT70?.Nrtv?.content)
                    ],
                    Strd: []
                }
        }
    });
    return cdtTrfTxInfArray;
}

# This function transforms an MT205 SWIFT message into an ISO 20022 Pacs004Document format.
#
# + message - The parsed MT205 message as a record value.
# + return - Returns a `Pacs004Document` object if the transformation is successful,
# otherwise returns an error.
isolated function transformMT205RETNPacs004(swiftmt:MT205Message message) returns pacsIsoRecord:Pacs004Envelope|error =>
    let string field57Acct = getPartyIdentifierOrAccount2(message.block4.MT57B?.PrtyIdn)[1].toString() +
        getPartyIdentifierOrAccount2(message.block4.MT57B?.PrtyIdn)[2].toString(),
    string[]? field57AdrsLine = getAddressLine(message.block4.MT57D?.AdrsLine,
            address3 = message.block4.MT57B?.Lctn?.content),
    string? partyIdentifier = getPartyIdentifierOrAccount2(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn,
            message.block4.MT57D?.PrtyIdn)[0],
    string? name = getNameForCdtrAgtInPacs004(message.block4.MT57B, getName(message.block4.MT57D?.Nm), field57Acct,
            field57AdrsLine),
    string[]? address = getAddressForCdtrAgtInPacs004(field57Acct, field57AdrsLine),
    [string?, string?, string?] [_, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C),
    [string?, pacsIsoRecord:PaymentReturnReason7[]] [instructionId, returnReasonArray] =
        get202Or205RETNSndRcvrInfoForPacs004(message.block4.MT72)
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
            MsgDefIdr: "pacs.004.001.09",
            BizSvc: "swift.cbprplus.02",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string) + DEFAULT_TIME_OFFSET
        },
        Document: {
            PmtRtr: {
                GrpHdr: {
                    MsgId: message.block4.MT20.msgId.content,
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string) + DEFAULT_TIME_OFFSET,
                    NbOfTxs: DEFAULT_NUM_OF_TX,
                    SttlmInf: {
                        SttlmMtd: getSettlementMethod(message.block4.MT53A, message.block4.MT53B, message.block4.MT53D),
                        SttlmAcct: getCashAccount(message.block4.MT53B?.PrtyIdn, ())
                    }
                },
                TxInf: [
                    {
                        RtrId: message.block4.MT20.msgId.content,
                        OrgnlUETR: message.block3?.NdToNdTxRef?.value,
                        OrgnlInstrId: instructionId,
                        RtrdIntrBkSttlmAmt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                                CdtDtTm: crdtTime,
                                DbtDtTm: dbitTime
                            },
                        RtrChain: {
                            Cdtr: {
                                Agt: getFinancialInstitution(message.block4.MT58A?.IdnCd?.content, message.block4.MT58D?.Nm,
                                        message.block4.MT58A?.PrtyIdn, message.block4.MT58D?.PrtyIdn, (), (),
                                        message.block4.MT58D?.AdrsLine)
                            },
                            CdtrAgt: partyIdentifier is () && name is () && address is () &&
                                message.block4.MT57A?.IdnCd?.content is () ? () : {
                                    FinInstnId: {
                                        BICFI: message.block4.MT57A?.IdnCd?.content,
                                        ClrSysMmbId: {
                                            MmbId: "",
                                            ClrSysId: {
                                                Cd: partyIdentifier
                                            }
                                        },
                                        Nm: name,
                                        PstlAdr: address is () ? () : {
                                                AdrLine: address
                                            }
                                    }
                                },
                            Dbtr: {
                                Agt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, message.block4.MT52D?.Nm,
                                        message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (), (),
                                        message.block4.MT52D?.AdrsLine)
                            },
                            IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content, message.block4.MT56D?.Nm,
                                    message.block4.MT56A?.PrtyIdn, message.block4.MT56D?.PrtyIdn, (), (),
                                    message.block4.MT56D?.AdrsLine)
                        },
                        RtrRsnInf: returnReasonArray.length() == 0 ? () : returnReasonArray
                    }
                ]
            }
        }
    };

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

# Transforms the given SWIFT MT103REMIT message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT103REMIT message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103REMIT message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103REMITToPacs008(swiftmt:MT103REMITMessage message)
    returns pacsIsoRecord:Pacs008Envelope|error => let
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C),
    string? serviceTypeIdentifier = message.block3?.ServiceTypeIdentifier?.value,
    [InstructionForCreditorAgentArray, InstructionForNextAgent1Array, pacsIsoRecord:ServiceLevel8Choice[],
    pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:LocalInstrument2Choice?] 
        [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, purpose, lclInstrm] =
        check getInformationForAgents(message.block4.MT23E, message.block4.MT72, serviceTypeIdentifier),
    [string, string?, string?] [remmitanceInfo, narration, xmlContent] = getEnvelopeContent(
            message.block4.MT77T.EnvCntnt.content),
    string? receiver = getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress),
    string? sender = getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal),
    pacsIsoRecord:SettlementMethod1Code settlementMethod = getSettlementMethod(message.block4.MT53A, message.block4.MT53B, message.block4.MT53D),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instgRmbrmntAgt = getFinancialInstitution(
            message.block4.MT53A?.IdnCd?.content, message.block4.MT53D?.Nm, message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
            message.block4.MT53D?.PrtyIdn, (), message.block4.MT53D?.AdrsLine,
            message.block4.MT53B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? instgRmbrmntAcct = getCashAccount(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
            message.block4.MT53D?.PrtyIdn),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instdRmbrmntAgt = getFinancialInstitution(
            message.block4.MT54A?.IdnCd?.content, message.block4.MT54D?.Nm, message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn,
            message.block4.MT54D?.PrtyIdn, (), message.block4.MT54D?.AdrsLine, message.block4.MT54B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? instdRmbrmntAcct = getCashAccount(message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn,
            message.block4.MT54D?.PrtyIdn),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? thrdRmbrmntAgt = getFinancialInstitution(
            message.block4.MT55A?.IdnCd?.content, message.block4.MT55D?.Nm, message.block4.MT55A?.PrtyIdn, message.block4.MT55B?.PrtyIdn,
            message.block4.MT55D?.PrtyIdn, (), message.block4.MT55D?.AdrsLine, message.block4.MT55B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? thrdRmbrmntAcct = getCashAccount(message.block4.MT55A?.PrtyIdn, message.block4.MT55B?.PrtyIdn,
            message.block4.MT55D?.PrtyIdn),
    boolean isRTGS = isRTGSTransaction(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, 
        message.block4.MT56D?.PrtyIdn, message.block4.MT57A?.PrtyIdn, message.block4.MT57C?.PrtyIdn, 
        message.block4.MT57D?.PrtyIdn),
    pacsIsoRecord:ChargeBearerType1Code chargeBearer = 
        check getDetailsChargesCd(message.block4.MT71A.Cd).ensureType(pacsIsoRecord:ChargeBearerType1Code),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8[] prvsInstgAgts = 
        (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[2]
    in {
        AppHdr: {
            Fr: {
                FIId: {
                    FinInstnId: {
                        BICFI: sender
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
            MsgDefIdr: "pacs.008.001.08",
            BizSvc: "swift.cbprplus.03",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            FIToFICstmrCdtTrf: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    SttlmInf: {
                        SttlmMtd: settlementMethod,
                        InstgRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                instgRmbrmntAgt !is () ? instgRmbrmntAgt : instgRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        InstgRmbrsmntAgtAcct: settlementMethod == "INGA" || settlementMethod == "INDA" ? () : instgRmbrmntAcct,
                        InstdRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                instdRmbrmntAgt !is () ? instdRmbrmntAgt : instdRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        InstdRmbrsmntAgtAcct: settlementMethod == "INGA" || settlementMethod == "INDA" ? () : instdRmbrmntAcct,
                        ThrdRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                thrdRmbrmntAgt !is () ? thrdRmbrmntAgt : thrdRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        ThrdRmbrsmntAgtAcct: thrdRmbrmntAcct
                    },
                    NbOfTxs: DEFAULT_NUM_OF_TX,
                    MsgId: message.block4.MT20.msgId.content
                },
                CdtTrfTxInf: [
                    {
                        Cdtr: getDebtorOrCreditor(message.block4.MT59A?.IdnCd, message.block4.MT59?.Acc,
                                message.block4.MT59A?.Acc, message.block4.MT59F?.Acc, (),
                                message.block4.MT59F?.Nm, message.block4.MT59?.Nm,
                                message.block4.MT59F?.AdrsLine, message.block4.MT59?.AdrsLine,
                                message.block4.MT59F?.CntyNTw, false, message.block4.MT77B?.Nrtv),
                        CdtrAcct: getCashAccount2(message.block4.MT59?.Acc, message.block4.MT59A?.Acc,
                                message.block4.MT59F?.Acc),
                        CdtrAgt: getFinancialInstitution(message.block4.MT57A?.IdnCd?.content, message.block4.MT57D?.Nm,
                                message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn,
                                message.block4.MT57D?.PrtyIdn, message.block4.MT57D?.AdrsLine,
                                message.block4.MT57B?.Lctn?.content) ?: {FinInstnId: {BICFI: receiver}},
                        CdtrAgtAcct: getCashAccount(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn,
                                message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn),
                        IntrBkSttlmAmt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        PmtId: {
                            EndToEndId: getEndToEndId(remmitanceInfo = remmitanceInfo),
                            InstrId: message.block4.MT20.msgId.content,
                            UETR: message.block3?.NdToNdTxRef?.value
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
                        SttlmTmReq: clsTime is () ? () : {
                                CLSTm: clsTime
                            },
                        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                                CdtDtTm: crdtTime,
                                DbtDtTm: dbitTime
                            },
                        PmtTpInf: serviceLevel.length() == 0 && purpose is () ? () : {
                                ClrChanl: isRTGS ? "RTGS" : (),
                                SvcLvl: serviceLevel.length() == 0 ? () : serviceLevel,
                                CtgyPurp: purpose,
                                LclInstrm: lclInstrm is () ? () : lclInstrm
                            },
                        IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                        XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                        InstdAmt:  message.block4.MT33B is () ? () : {
                            content: check getInstructedAmount(instrdAmnt = message.block4.MT33B),
                            Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, message.block4.MT32A.Ccy.content)
                        },
                        DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, message.block4.MT52D?.Nm,
                                message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (), (),
                                message.block4.MT52D?.AdrsLine) ?: {FinInstnId: {BICFI: sender}},
                        DbtrAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
                        ChrgBr: chargeBearer,
                        Dbtr: getDebtorOrCreditor(message.block4.MT50A?.IdnCd, message.block4.MT50A?.Acc,
                                message.block4.MT50K?.Acc, (), message.block4.MT50F?.PrtyIdn,
                                message.block4.MT50F?.Nm, message.block4.MT50K?.Nm,
                                message.block4.MT50F?.AdrsLine, message.block4.MT50K?.AdrsLine,
                                message.block4.MT50F?.CntyNTw, true, message.block4.MT77B?.Nrtv),
                        DbtrAcct: getCashAccount2(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc, (),
                                message.block4.MT50F?.PrtyIdn),
                        PrvsInstgAgt1: prvsInstgAgts.length() > 0 ? prvsInstgAgts[0] : (),
                        PrvsInstgAgt2: prvsInstgAgts.length() > 1 ? prvsInstgAgts[1] : (),
                        PrvsInstgAgt3: prvsInstgAgts.length() > 2 ? prvsInstgAgts[2] : (),
                        IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content,
                                message.block4.MT56D?.Nm, message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn,
                                message.block4.MT56D?.PrtyIdn, (), message.block4.MT56D?.AdrsLine),
                        IntrmyAgt1Acct: getCashAccount(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn,
                                message.block4.MT56D?.PrtyIdn),
                        IntrmyAgt2: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[3],
                        ChrgsInf: check getChargesInformation(message.block4.MT71F, message.block4.MT71G, receiver,
                                "CRED" == chargeBearer),
                        RgltryRptg: getRegulatoryReporting(message.block4.MT77B?.Nrtv?.content),
                        RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []},
                        InstrForNxtAgt: instrFrNxtAgt,
                        InstrForCdtrAgt: instrFrCdtrAgt,
                        Purp: message.block4.MT26T is () ? () : {
                                Prtry: getMandatoryFields(message.block4.MT26T?.Typ?.content)
                            },
                        SplmtryData: narration is () && xmlContent is () ? () : [
                                {
                                    Envlp: {
                                        Nrtv: getEnvelopeContent(message.block4.MT77T.EnvCntnt.content)[2],
                                        XmlContent: getEnvelopeContent(message.block4.MT77T.EnvCntnt.content)[1]
                                    }
                                }
                            ]
                    }
                ]
            }
        }
    };

# Transforms the given SWIFT MT103STP message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT103STP message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103STP message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103STPToPacs008(swiftmt:MT103STPMessage message)
    returns pacsIsoRecord:Pacs008Envelope|error => let
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C),
    string? serviceTypeIdentifier = message.block3?.ServiceTypeIdentifier?.value,
    [InstructionForCreditorAgentArray, InstructionForNextAgent1Array,pacsIsoRecord:ServiceLevel8Choice[],
    pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:LocalInstrument2Choice?] 
        [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, purpose, lclInstrm] =
        check getInformationForAgents(message.block4.MT23E, message.block4.MT72, serviceTypeIdentifier),
    string remmitanceInfo = getRemmitanceInformation(message.block4.MT70?.Nrtv?.content),
    string? receiver = getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress),
    string? sender = getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal),
    pacsIsoRecord:SettlementMethod1Code settlementMethod = getCBPRPlusMTtoMXSettlementMethod(message.block4.MT53A, 
        message.block4.MT53B, (), message.block4.MT54A, (), (), sender, receiver),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instgRmbrmntAgt = getFinancialInstitution(
            message.block4.MT53A?.IdnCd?.content, (), message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
            (), (), (), message.block4.MT53B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? instgRmbrmntAcct = getCashAccount(message.block4.MT53A?.PrtyIdn,
            message.block4.MT53B?.PrtyIdn),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instdRmbrmntAgt = getFinancialInstitution(
            message.block4.MT54A?.IdnCd?.content, (), message.block4.MT54A?.PrtyIdn, ()),
    pacsIsoRecord:CashAccount40? instdRmbrmntAcct = getCashAccount(message.block4.MT54A?.PrtyIdn, ()),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? thrdRmbrmntAgt = getFinancialInstitution(
            message.block4.MT55A?.IdnCd?.content, (), message.block4.MT55A?.PrtyIdn, ()),
    pacsIsoRecord:CashAccount40? thrdRmbrmntAcct = getCashAccount(message.block4.MT55A?.PrtyIdn, ()),
    boolean isRTGS = isRTGSTransaction(message.block4.MT56A?.PrtyIdn, (), (),
            message.block4.MT57A?.PrtyIdn, (), ()),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8[] prvsInstgAgts = 
        (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[2],
    pacsIsoRecord:ChargeBearerType1Code chargeBearer = check getDetailsChargesCd(message.block4.MT71A.Cd)
        .ensureType(pacsIsoRecord:ChargeBearerType1Code)
    in {
        AppHdr: {
            Fr: {
                FIId: {
                    FinInstnId: {
                        BICFI: sender
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
            MsgDefIdr: "pacs.008.001.08",
            BizSvc: "swift.cbprplus.stp.03",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            FIToFICstmrCdtTrf: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    SttlmInf: {
                        SttlmMtd: settlementMethod,
                        InstgRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                instgRmbrmntAgt !is () ? instgRmbrmntAgt : instgRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        InstgRmbrsmntAgtAcct: settlementMethod == "INGA" || settlementMethod == "INDA" ? () : instgRmbrmntAcct,
                        InstdRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                instdRmbrmntAgt !is () ? instdRmbrmntAgt : instdRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        InstdRmbrsmntAgtAcct: settlementMethod == "INGA" || settlementMethod == "INDA" ? () : instdRmbrmntAcct,
                        ThrdRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                thrdRmbrmntAgt !is () ? thrdRmbrmntAgt : thrdRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        ThrdRmbrsmntAgtAcct: thrdRmbrmntAcct
                    },
                    NbOfTxs: DEFAULT_NUM_OF_TX,
                    MsgId: message.block4.MT20.msgId.content
                },
                CdtTrfTxInf: [
                    {
                        Cdtr: getDebtorOrCreditor(message.block4.MT59A?.IdnCd, message.block4.MT59?.Acc,
                                message.block4.MT59A?.Acc, message.block4.MT59F?.Acc, (),
                                message.block4.MT59F?.Nm, message.block4.MT59?.Nm,
                                message.block4.MT59F?.AdrsLine, message.block4.MT59?.AdrsLine,
                                message.block4.MT59F?.CntyNTw, false, message.block4.MT77B?.Nrtv),
                        CdtrAcct: getCashAccount2(message.block4.MT59?.Acc, message.block4.MT59A?.Acc,
                                message.block4.MT59F?.Acc),
                        CdtrAgt: getFinancialInstitution(message.block4.MT57A?.IdnCd?.content, (),
                                message.block4.MT57A?.PrtyIdn,
                                ()) ?: {FinInstnId: {BICFI: receiver}},
                        CdtrAgtAcct: getCashAccount(message.block4.MT57A?.PrtyIdn, ()),
                        IntrBkSttlmAmt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        PmtId: {
                            EndToEndId: getEndToEndId(remmitanceInfo = remmitanceInfo),
                            InstrId: message.block4.MT20.msgId.content,
                            UETR: message.block3?.NdToNdTxRef?.value
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
                        SttlmTmReq: clsTime is () ? () : {
                                CLSTm: clsTime
                            },
                        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                                CdtDtTm: crdtTime,
                                DbtDtTm: dbitTime
                            },
                        PmtTpInf: serviceLevel.length() == 0 && purpose is () ? () : {
                                ClrChanl: isRTGS ? "RTGS" : (),
                                SvcLvl: serviceLevel.length() == 0 ? () : serviceLevel,
                                CtgyPurp: purpose,
                                LclInstrm: lclInstrm is () ? () : lclInstrm
                            },
                        IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                        XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                        InstdAmt:  message.block4.MT33B is () ? () : {
                            content: check getInstructedAmount(instrdAmnt = message.block4.MT33B),
                            Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, message.block4.MT32A.Ccy.content)
                        },
                        DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, (),
                                message.block4.MT52A?.PrtyIdn,
                                ()) ?: {FinInstnId: {BICFI: sender}},
                        DbtrAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, ()),
                        ChrgBr: chargeBearer,
                        Dbtr: getDebtorOrCreditor(message.block4.MT50A?.IdnCd, message.block4.MT50A?.Acc,
                                message.block4.MT50K?.Acc, (), message.block4.MT50F?.PrtyIdn,
                                message.block4.MT50F?.Nm, message.block4.MT50K?.Nm,
                                message.block4.MT50F?.AdrsLine, message.block4.MT50K?.AdrsLine,
                                message.block4.MT50F?.CntyNTw, true, message.block4.MT77B?.Nrtv),
                        DbtrAcct: getCashAccount2(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc, (),
                                message.block4.MT50F?.PrtyIdn),
                        PrvsInstgAgt1: prvsInstgAgts.length() > 0 ? prvsInstgAgts[0] : (),
                        PrvsInstgAgt2: prvsInstgAgts.length() > 1 ? prvsInstgAgts[1] : (),
                        PrvsInstgAgt3: prvsInstgAgts.length() > 2 ? prvsInstgAgts[2] : (),
                        IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content, (),
                                message.block4.MT56A?.PrtyIdn, ()),
                        IntrmyAgt1Acct: getCashAccount(message.block4.MT56A?.PrtyIdn, ()),
                        IntrmyAgt2: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[3],
                        ChrgsInf: check getChargesInformation(message.block4.MT71F, message.block4.MT71G, receiver,
                                "CRED" == chargeBearer),
                        RgltryRptg: getRegulatoryReporting(message.block4.MT77B?.Nrtv?.content),
                        RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []},
                        InstrForNxtAgt: instrFrNxtAgt,
                        InstrForCdtrAgt: instrFrCdtrAgt,
                        Purp: message.block4.MT26T is () ? () : {
                                Prtry: getMandatoryFields(message.block4.MT26T?.Typ?.content)
                            }
                    }
                ]
            }
        }
    };

# Transforms the given SWIFT MT103 message to its corresponding ISO 20022 Pacs.008 format.
#
# This function extracts various fields from the SWIFT MT103 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs008Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103ToPacs008(swiftmt:MT103Message message)
    returns pacsIsoRecord:Pacs008Envelope|error => let
    [string?, string?, string?] [clsTime, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C),
    string? serviceTypeIdentifier = message.block3?.ServiceTypeIdentifier?.value,
    [InstructionForCreditorAgentArray, InstructionForNextAgent1Array, pacsIsoRecord:ServiceLevel8Choice[],
    pacsIsoRecord:CategoryPurpose1Choice?, pacsIsoRecord:LocalInstrument2Choice?] 
        [instrFrCdtrAgt, instrFrNxtAgt, serviceLevel, purpose, lclInstrm] =
        check getInformationForAgents(message.block4.MT23E, message.block4.MT72, serviceTypeIdentifier),
    string remmitanceInfo = getRemmitanceInformation(message.block4.MT70?.Nrtv?.content),
    string? receiver = getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress),
    string? sender = getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal),
    pacsIsoRecord:SettlementMethod1Code settlementMethod = getCBPRPlusMTtoMXSettlementMethod(message.block4.MT53A, 
        message.block4.MT53B, (), message.block4.MT54A, (), (), sender, receiver),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instgRmbrmntAgt = getFinancialInstitution(
            message.block4.MT53A?.IdnCd?.content, message.block4.MT53D?.Nm, message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
            message.block4.MT53D?.PrtyIdn, (), message.block4.MT53D?.AdrsLine,
            message.block4.MT53B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? instgRmbrmntAcct = getCashAccount(message.block4.MT53A?.PrtyIdn, message.block4.MT53B?.PrtyIdn,
            message.block4.MT53D?.PrtyIdn),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instdRmbrmntAgt = getFinancialInstitution(
            message.block4.MT54A?.IdnCd?.content, message.block4.MT54D?.Nm, message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn,
            message.block4.MT54D?.PrtyIdn, (), message.block4.MT54D?.AdrsLine, message.block4.MT54B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? instdRmbrmntAcct = getCashAccount(message.block4.MT54A?.PrtyIdn, message.block4.MT54B?.PrtyIdn,
            message.block4.MT54D?.PrtyIdn),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? thrdRmbrmntAgt = getFinancialInstitution(
            message.block4.MT55A?.IdnCd?.content, message.block4.MT55D?.Nm, message.block4.MT55A?.PrtyIdn, message.block4.MT55B?.PrtyIdn,
            message.block4.MT55D?.PrtyIdn, (), message.block4.MT55D?.AdrsLine, message.block4.MT55B?.Lctn?.content),
    pacsIsoRecord:CashAccount40? thrdRmbrmntAcct = getCashAccount(message.block4.MT55A?.PrtyIdn, message.block4.MT55B?.PrtyIdn,
            message.block4.MT55D?.PrtyIdn),
    boolean isRTGS = isRTGSTransaction(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn,
            message.block4.MT56D?.PrtyIdn, message.block4.MT57A?.PrtyIdn, message.block4.MT57C?.PrtyIdn,
            message.block4.MT57D?.PrtyIdn),
    pacsIsoRecord:ChargeBearerType1Code chargeBearer = check getDetailsChargesCd(message.block4.MT71A.Cd)
        .ensureType(pacsIsoRecord:ChargeBearerType1Code),
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8[] prvsInstgAgts = 
        (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[2]
    in {
        AppHdr: {
            Fr: {
                FIId: {
                    FinInstnId: {
                        BICFI: sender
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
            MsgDefIdr: "pacs.008.001.08",
            BizSvc: "swift.cbprplus.03",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            FIToFICstmrCdtTrf: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    SttlmInf: {
                        SttlmMtd: settlementMethod,
                        InstgRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                instgRmbrmntAgt !is () ? instgRmbrmntAgt : instgRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        InstgRmbrsmntAgtAcct: settlementMethod == "INGA" || settlementMethod == "INDA" ? () : instgRmbrmntAcct,
                        InstdRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                instdRmbrmntAgt !is () ? instdRmbrmntAgt : instdRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        InstdRmbrsmntAgtAcct: settlementMethod == "INGA" || settlementMethod == "INDA" ? () : instdRmbrmntAcct,
                        ThrdRmbrsmntAgt: settlementMethod == "INGA" || settlementMethod == "INDA" ? () :
                                thrdRmbrmntAgt !is () ? thrdRmbrmntAgt : thrdRmbrmntAcct is () ? () : {
                                        FinInstnId: {
                                            BICFI: "NOTPROVIDED"
                                        }
                                    },
                        ThrdRmbrsmntAgtAcct: thrdRmbrmntAcct
                    },
                    NbOfTxs: DEFAULT_NUM_OF_TX,
                    MsgId: message.block4.MT20.msgId.content
                },
                CdtTrfTxInf: [
                    {
                        Cdtr: getDebtorOrCreditor(message.block4.MT59A?.IdnCd, message.block4.MT59?.Acc,
                                message.block4.MT59A?.Acc, message.block4.MT59F?.Acc, (),
                                message.block4.MT59F?.Nm, message.block4.MT59?.Nm,
                                message.block4.MT59F?.AdrsLine, message.block4.MT59?.AdrsLine,
                                message.block4.MT59F?.CntyNTw, false, message.block4.MT77B?.Nrtv),
                        CdtrAcct: getCashAccount2(message.block4.MT59?.Acc, message.block4.MT59A?.Acc,
                                message.block4.MT59F?.Acc),
                        CdtrAgt: getFinancialInstitution(message.block4.MT57A?.IdnCd?.content, message.block4.MT57D?.Nm,
                                message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn,
                                message.block4.MT57D?.PrtyIdn, message.block4.MT57D?.AdrsLine,
                                message.block4.MT57B?.Lctn?.content) ?: {FinInstnId: {BICFI: receiver}},
                        CdtrAgtAcct: getCashAccount(message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn,
                                message.block4.MT57C?.PrtyIdn, message.block4.MT57D?.PrtyIdn),
                        IntrBkSttlmAmt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        PmtId: {
                            EndToEndId: getEndToEndId(remmitanceInfo = remmitanceInfo),
                            InstrId: message.block4.MT20.msgId.content,
                            UETR: message.block3?.NdToNdTxRef?.value
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
                        SttlmTmReq: clsTime is () ? () : {
                                CLSTm: clsTime
                            },
                        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                                CdtDtTm: crdtTime,
                                DbtDtTm: dbitTime
                            },
                        PmtTpInf: serviceLevel.length() == 0 && purpose is () ? () : {
                                ClrChanl: isRTGS ? "RTGS" : (),
                                SvcLvl: serviceLevel.length() == 0 ? () : serviceLevel,
                                CtgyPurp: purpose,
                                LclInstrm: lclInstrm is () ? () : lclInstrm
                            },
                        IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                        XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                        InstdAmt:  message.block4.MT33B is () ? () : {
                            content: check getInstructedAmount(instrdAmnt = message.block4.MT33B),
                            Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, ())
                        },
                        DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content,
                                message.block4.MT52D?.Nm, message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (),
                                (), message.block4.MT52D?.AdrsLine) ?: {FinInstnId: {BICFI: sender}},
                        DbtrAgtAcct: getCashAccount(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
                        ChrgBr: chargeBearer,
                        Dbtr: getDebtorOrCreditor(message.block4.MT50A?.IdnCd, message.block4.MT50A?.Acc,
                                message.block4.MT50K?.Acc, (), message.block4.MT50F?.PrtyIdn,
                                message.block4.MT50F?.Nm, message.block4.MT50K?.Nm,
                                message.block4.MT50F?.AdrsLine, message.block4.MT50K?.AdrsLine,
                                message.block4.MT50F?.CntyNTw, true, message.block4.MT77B?.Nrtv),
                        DbtrAcct: getCashAccount2(message.block4.MT50A?.Acc, message.block4.MT50K?.Acc, (),
                                message.block4.MT50F?.PrtyIdn),
                        PrvsInstgAgt1: prvsInstgAgts.length() > 0 ? prvsInstgAgts[0] : (),
                        PrvsInstgAgt2: prvsInstgAgts.length() > 1 ? prvsInstgAgts[1] : (),
                        PrvsInstgAgt3: prvsInstgAgts.length() > 2 ? prvsInstgAgts[2] : (),
                        IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content,
                                message.block4.MT56D?.Nm, message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn,
                                message.block4.MT56D?.PrtyIdn, (), message.block4.MT56D?.AdrsLine),
                        IntrmyAgt1Acct: getCashAccount(message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn,
                                message.block4.MT56D?.PrtyIdn),
                        IntrmyAgt2: (check getMT1XXSenderToReceiverInformation(message.block4.MT72))[3],
                        ChrgsInf: check getChargesInformation(message.block4.MT71F, message.block4.MT71G, receiver, 
                                "CRED" == chargeBearer),
                        RgltryRptg: getRegulatoryReporting(message.block4.MT77B?.Nrtv?.content),
                        RmtInf: remmitanceInfo == "" ? () : {Ustrd: [remmitanceInfo], Strd: []},
                        InstrForNxtAgt: instrFrNxtAgt,
                        InstrForCdtrAgt: instrFrCdtrAgt,
                        Purp: message.block4.MT26T is () ? () : {
                                Prtry: getMandatoryFields(message.block4.MT26T?.Typ?.content)
                            }
                    }
                ]
            }
        }
    };

# Transforms the given SWIFT MT103 message to its corresponding ISO 20022 Pacs.004 format.
#
# This function extracts various fields from the SWIFT MT103 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs004Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103ToPacs004(swiftmt:MT103Message message)
    returns pacsIsoRecord:Pacs004Envelope|error => let
    [string?, string?, string?] [_, crdtTime, dbitTime] = getTimeIndication(message.block4.MT13C),
    string? sender = getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal),
    string? receiver = getMessageReceiver(message.block1?.logicalTerminal, message.block2.receiverAddress),
    pacsIsoRecord:ChargeBearerType1Code chargeBearer = check getDetailsChargesCd(message.block4.MT71A.Cd)
        .ensureType(pacsIsoRecord:ChargeBearerType1Code),
    pacsIsoRecord:Charges16[]? charges = check getChargesInformation(message.block4.MT71F, message.block4.MT71G, 
        receiver, "CRED" == chargeBearer),
    [string?, string?, pacsIsoRecord:PaymentReturnReason7[], pacsIsoRecord:Charges16[]] [instructionId, endToEndId,
        returnReasonArray, sndRcvrInfoChrgs] = check get103Or202RETNSndRcvrInfoForPacs004(message.block4.MT72)
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
                        BICFI: receiver
                    }
                }
            },
            BizMsgIdr: message.block4.MT20.msgId.content,
            MsgDefIdr: "pacs.004.001.09",
            BizSvc: "swift.cbprplus.03",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            PmtRtr: {
                GrpHdr: {
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string),
                    SttlmInf: {
                        SttlmMtd: getCBPRPlusMTtoMXSettlementMethod(message.block4.MT53A, message.block4.MT53B, (), 
                                message.block4.MT54A, (), (), sender, receiver),
                        SttlmAcct: getCashAccount(message.block4.MT53B?.PrtyIdn, ())
                    },
                    NbOfTxs: DEFAULT_NUM_OF_TX,
                    MsgId: message.block4.MT20.msgId.content
                },
                TxInf: [
                    {
                        InstgAgt: {
                            FinInstnId: {
                                BICFI: getMessageSender(message.block1?.logicalTerminal, message.block2.MIRLogicalTerminal)
                            }
                        },
                        InstdAgt: {
                            FinInstnId: {
                                BICFI: receiver
                            }
                        },
                        RtrId: message.block4.MT20.msgId.content,
                        OrgnlUETR: message.block3?.NdToNdTxRef?.value,
                        OrgnlInstrId: instructionId,
                        OrgnlEndToEndId: endToEndId,
                        RtrdIntrBkSttlmAmt: {
                            content: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                            Ccy: message.block4.MT32A.Ccy.content
                        },
                        IntrBkSttlmDt: convertToISOStandardDate(message.block4.MT32A.Dt),
                        XchgRate: check convertToDecimal(message.block4.MT36?.Rt),
                        SttlmTmIndctn: crdtTime is () && dbitTime is () ? () : {
                                CdtDtTm: crdtTime,
                                DbtDtTm: dbitTime
                            },
                        RtrdInstdAmt: {
                            content: check getInstructedAmount(instrdAmnt = message.block4.MT33B,
                                    stlmntAmnt = message.block4.MT32A),
                            Ccy: getCurrency(message.block4.MT33B?.Ccy?.content, message.block4.MT32A.Ccy.content)
                        },
                        ChrgBr: chargeBearer,
                        ChrgsInf: getChargesInfo(charges, sndRcvrInfoChrgs),
                        RtrChain: {
                            Cdtr: getCreditorForPacs004(message.block4.MT59, message.block4.MT59A, message.block4.MT59F,
                                    message.block4.MT77B?.Nrtv?.content),
                            CdtrAgt: getFinancialInstitution(message.block4.MT57A?.IdnCd?.content, message.block4.MT57D?.Nm,
                                    message.block4.MT57A?.PrtyIdn, message.block4.MT57B?.PrtyIdn, message.block4.MT57C?.PrtyIdn,
                                    message.block4.MT57D?.PrtyIdn, message.block4.MT57D?.AdrsLine,
                                    message.block4.MT57B?.Lctn?.content),
                            DbtrAgt: getFinancialInstitution(message.block4.MT52A?.IdnCd?.content, message.block4.MT52D?.Nm,
                                    message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn, (), (),
                                    message.block4.MT52D?.AdrsLine),
                            Dbtr: getDebtorForPacs004(message.block4.MT50A, message.block4.MT50F, message.block4.MT50K,
                                    message.block4.MT77B?.Nrtv?.content),
                            IntrmyAgt1: getFinancialInstitution(message.block4.MT56A?.IdnCd?.content, message.block4.MT56D?.Nm,
                                    message.block4.MT56A?.PrtyIdn, message.block4.MT56C?.PrtyIdn, message.block4.MT56D?.PrtyIdn,
                                    (), message.block4.MT56D?.AdrsLine)
                        },
                        RtrRsnInf: returnReasonArray.length() == 0 ? () : returnReasonArray
                    }
                ]
            }
        }
    };

# Transforms the given SWIFT MT103 message to its corresponding ISO 20022 Pacs.002 format.
#
# This function extracts various fields from the SWIFT MT103 message and maps them to 
# the appropriate ISO 20022 structure.
#
# + message - The parsed MT103 message as a record value.
# + return - Returns the transformed ISO 20022 `Pacs002Document` structure.
# An error is returned if there is any failure in transforming the SWIFT message to ISO 20022 format.
isolated function transformMT103ToPacs002(swiftmt:MT103Message message)
    returns pacsIsoRecord:Pacs002Envelope|error => let
    [string?, string?, pacsIsoRecord:StatusReasonInformation14[]] [instructionId, endToEndId,
        statusReasonArray] = check get103REJTSndRcvrInfoForPacs004(message.block4.MT72)
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
            MsgDefIdr: "pacs.002.001.10",
            BizSvc: "swift.cbprplus.03",
            CreDt: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                    true).ensureType(string)
        },
        Document: {
            FIToFIPmtStsRpt: {
                GrpHdr: {
                    MsgId: message.block4.MT20.msgId.content,
                    CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime,
                            true).ensureType(string)
                },
                TxInfAndSts: [
                    {
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
                        OrgnlGrpInf: {
                            OrgnlMsgId: instructionId is () ? "NOTPROVIDED" : instructionId,
                            OrgnlMsgNmId: "MT103"
                        },
                        OrgnlInstrId: instructionId is () ? "NOTPROVIDED" : instructionId,
                        OrgnlUETR: message.block3?.NdToNdTxRef?.value,
                        OrgnlEndToEndId: endToEndId is () ? "NOTPROVIDED" : endToEndId,
                        TxSts: "RJCT",
                        StsRsnInf: statusReasonArray.length() == 0 ? () : statusReasonArray
                    }
                ]
            }
        }
    };

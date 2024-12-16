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

import ballerina/uuid;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms an MT201 SWIFT message into an ISO 20022 PACS.009 document.
# The relevant fields from the MT201 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT201 message as a record value.
# + return - Returns a `Pacs009Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT201ToPacs009(swiftmt:MT201Message message) returns pacsIsoRecord:Pacs009Document|error => {
    FICdtTrf: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            CtrlSum: check convertToDecimal(message.block4.MT19.Amnt),
            SttlmInf: {
                SttlmMtd: getSettlementMethod(mt53B = message.block4.MT53B)
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
            MsgId: uuid:createType4AsString().substring(0, 35)
        },
        CdtTrfTxInf: check getCreditTransferTransactionInfo(message.block4, message.block3)
    }
};

# This function extracts credit transfer transaction information from an MT201 SWIFT message
# and maps it to an array of ISO 20022 CreditTransferTransaction62 records.
#
# + block4 - The parsed block4 of MT201 SWIFT message containing multiple transactions.
# + block3 - The parsed block3 of MT201 SWIFT message containing end to end id.
# + return - Returns an array of `CreditTransferTransaction62` objects if the extraction is successful,
# otherwise returns an error.
isolated function getCreditTransferTransactionInfo(swiftmt:MT201Block4 block4, swiftmt:Block3? block3) returns pacsIsoRecord:CreditTransferTransaction62[]|error {
    pacsIsoRecord:CreditTransferTransaction62[] cdtTrfTxInfArray = [];
    foreach swiftmt:MT201Transaction transaxion in block4.Transaction {
        swiftmt:MT72? sndToRcvrInfo = getMT201RepeatingFields(block4, transaxion.MT72, "72");
        cdtTrfTxInfArray.push({
            Cdtr: {
                FinInstnId: {
                    BICFI: transaxion.MT57A?.IdnCd?.content,
                    LEI: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[0],
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(transaxion.MT57D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(transaxion.MT57D?.AdrsLine, address3 = transaxion.MT57B?.Lctn?.content)
                    }
                }
            },
            CdtrAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT57A?.PrtyIdn, transaxion.MT57B?.PrtyIdn, transaxion.MT57D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT57A?.PrtyIdn, prtyIdn2 = transaxion.MT57B?.PrtyIdn, prtyIdn3 = transaxion.MT57D?.PrtyIdn)
                        }
                    }
                }
            },
            IntrBkSttlmAmt: {
                ActiveCurrencyAndAmount_SimpleType: {
                    ActiveCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(transaxion.MT32B.Amnt),
                    Ccy: transaxion.MT32B.Ccy.content
                }
            },
            IntrBkSttlmDt: convertToISOStandardDate(block4.MT30.Dt),
            PmtId: {
                EndToEndId: "",
                InstrId: transaxion.MT20.msgId.content,
                UETR: block3?.NdToNdTxRef?.value
            },
            Dbtr: {
                FinInstnId: {
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(block4.MT53B?.PrtyIdn)[0]
                        }
                    },
                    PstlAdr: {
                        AdrLine: getAddressLine((), address3 = block4.MT53B?.Lctn?.content)
                    }
                }
            },
            DbtrAcct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(block4.MT53B?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(block4.MT53B?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = block4.MT53B?.PrtyIdn)
                        }
                    }
                }
            },
            IntrmyAgt1: {
                FinInstnId: {
                    BICFI: transaxion.MT56A?.IdnCd?.content,
                    ClrSysMmbId: {
                        MmbId: "", 
                        ClrSysId: {
                            Cd: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[0]
                        }
                    },
                    Nm: getName(transaxion.MT56D?.Nm),
                    PstlAdr: {
                        AdrLine: getAddressLine(transaxion.MT56D?.AdrsLine)
                    }
                }
            },
            IntrmyAgt1Acct: {
                Id: {
                    IBAN: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[1],
                    Othr: {
                        Id: getPartyIdentifierOrAccount2(transaxion.MT56A?.PrtyIdn, transaxion.MT56D?.PrtyIdn)[2],
                        SchmeNm: {
                            Cd: getSchemaCode(prtyIdn1 = transaxion.MT56A?.PrtyIdn, prtyIdn2 = transaxion.MT56D?.PrtyIdn)
                        }
                    }
                }
            },
            InstrForNxtAgt: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo, 2))[1],
            InstrForCdtrAgt: (check getMT2XXSenderToReceiverInfo(sndToRcvrInfo, 2))[0]
        });
    }
    return cdtTrfTxInfArray;
}
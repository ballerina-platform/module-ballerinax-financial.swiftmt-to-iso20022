// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
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

# This function transforms an MT900 SWIFT message into an ISO 20022 CAMT.054 document.
# The MT900 message contains debit confirmation details, which are mapped to a notification
# in the CAMT.054 format, including account information, transaction details, and amounts.
#
# + message - The parsed MT900 message as a record value.
# + return - Returns a `Camt054Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT900ToCamt054(swiftmt:MT900Message message) returns camtIsoRecord:Camt054Document|error => {
    BkToCstmrDbtCdtNtfctn: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            MsgId: message.block4.MT20.msgId.content
        },
        Ntfctn: [
            {
                Id: message.block4.MT20.msgId.content,
                Acct: {
                    Id: {
                        IBAN: validateAccountNumber(message.block4.MT25?.Acc, acc2 = message.block4.MT25P?.Acc)[0],
                        Othr: {
                            Id: validateAccountNumber(message.block4.MT25?.Acc, acc2 = message.block4.MT25P?.Acc)[1],
                            SchmeNm: {
                                Cd: getSchemaCode(message.block4.MT25?.Acc, message.block4.MT25P?.Acc)
                            }
                        }
                    },
                    Ownr: {
                        Id: {
                            OrgId: {
                                AnyBIC: message.block4.MT25P?.IdnCd?.content
                            }
                        }
                    }
                },
                CreDtTm: convertToISOStandardDateTime(message.block4.MT13D?.Dt, message.block4.MT13D?.Tm),
                Ntry: [
                    {
                        Amt: {
                            ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                                ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                                Ccy: message.block4.MT32A.Ccy.content
                            }
                        },
                        CdtDbtInd: camtIsoRecord:DBIT,
                        ValDt: {
                            Dt: convertToISOStandardDate(message.block4.MT32A.Dt)
                        },
                        Sts: {},
                        BkTxCd: {},
                        NtryDtls: [
                            {
                                TxDtls: [
                                    {
                                        Amt: {
                                            ActiveOrHistoricCurrencyAndAmount_SimpleType: {
                                                ActiveOrHistoricCurrencyAndAmount_SimpleType: check convertToDecimalMandatory(message.block4.MT32A.Amnt),
                                                Ccy: message.block4.MT32A.Ccy.content
                                            }
                                        },
                                        CdtDbtInd: camtIsoRecord:DBIT,
                                        RltdAgts: {
                                            DbtrAgt: {
                                                FinInstnId: {
                                                    BICFI: message.block4.MT52A?.IdnCd?.content,
                                                    LEI: getPartyIdentifier(message.block4.MT52A?.PrtyIdn, message.block4.MT52D?.PrtyIdn),
                                                    Nm: getName(message.block4.MT52D?.Nm),
                                                    PstlAdr: {
                                                        AdrLine: getAddressLine(message.block4.MT52D?.AdrsLine)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }
};

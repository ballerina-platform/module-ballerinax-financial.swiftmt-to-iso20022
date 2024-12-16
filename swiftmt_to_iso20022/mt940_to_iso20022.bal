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

# This function transforms an MT940 SWIFT message into an ISO 20022 CAMT.053 document.
# The relevant fields from the MT940 message are extracted and mapped to the corresponding ISO 20022 structure.
#
# + message - The parsed MT940 message as a record value.
# + return - Returns a `Camt053Document` object if the transformation is successful, otherwise returns an error.
isolated function transformMT940ToCamt053(swiftmt:MT940Message message) returns camtIsoRecord:Camt053Document|error => {
    BkToCstmrStmt: {
        GrpHdr: {
            CreDtTm: check convertToISOStandardDateTime(message.block2.MIRDate, message.block2.senderInputTime, true).ensureType(string),
            MsgId: message.block4.MT20.msgId.content
        },
        Stmt: [
            {
                Id: message.block4.MT20.msgId.content,
                Acct: {
                    Id: {
                        IBAN: validateAccountNumber(message.block4.MT25P?.Acc)[0],
                        Othr: {
                            Id: validateAccountNumber(message.block4.MT25P?.Acc)[1]
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
                ElctrncSeqNb: message.block4.MT28C.SeqNo?.content,
                Bal: check getBalance(message.block4.MT60F, message.block4.MT62F, message.block4.MT64, message.block4.MT60M, message.block4.MT62M, message.block4.MT65),
                Ntry: check getEntries(message.block4.MT61)
            }
        ]
    }
};

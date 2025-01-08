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

# Removes specific XML tags based on the conditions provided, primarily for testing purposes.
#
# This function processes an input XML document and removes certain timestamp and message ID tags 
# depending on the given parameters. The goal is to produce a sanitized version of the XML for 
# test comparisons by ignoring dynamically changing elements like timestamps or optional fields.
#
# + actual - The input XML document to be sanitized.
# + isMessageIdPresent - A flag indicating whether the `MsgId` tag should be retained. Defaults to `true`.
# + return - Returns the modified XML document with the specified tags removed or returns an error if the 
# operation on the XML fails due to structural issues.
isolated function removeTagsForTest(xml actual, boolean isMessageIdPresent = true) returns xml {
    xml childXml = xml ``;
    foreach xml:Element tag in actual.elementChildren() {
        if tag.getName().includes("Document") {
            foreach xml:Element mainChild in tag.elementChildren().elementChildren(){
                if mainChild.getName().includes("GrpHdr") {
                    foreach xml:Element subChild in mainChild.elementChildren(){
                        if subChild.getName().includes("CreDtTm") || (subChild.getName().includes("MsgId") && !isMessageIdPresent) {
                            continue;
                        }
                        childXml += subChild;
                    }
                    mainChild.setChildren(childXml);
                    childXml = xml ``;
                }
            }
            break;
        }
        foreach xml:Element child in tag.elementChildren() {
            if child.getName().includes("CreDt") || (child.getName().includes("BizMsgIdr") && !isMessageIdPresent){
                continue;
            }
            childXml += child;
        }
        tag.setChildren(childXml);
        childXml = xml ``;
    }
    return actual;
}

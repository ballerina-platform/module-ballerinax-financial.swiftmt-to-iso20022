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

import ballerina/data.xmldata;
import ballerinax/financial.swift.mt as swiftmt;

# Converts a SWIFT message in string format to its corresponding ISO 20022 XML format.
#
# The function uses a map of transformation functions corresponding to different SWIFT MT message types 
# and applies the appropriate transformation based on the parsed message type.
#
# + finMessage - The SWIFT message string that needs to be transformed to ISO 20022 XML.
# + return - Returns the transformed ISO 20022 XML or an error if the transformation fails.
public isolated function toIso20022Xml(string finMessage) returns xml|error {
    record {} parsedMessage = check swiftmt:parseSwiftMt(finMessage);
    xml iso20022Xml = xml ``;
    // MT104, MT107, and MTn96 messages are handled separately to identify the type of instruction found within the 
    //message and to determine the appropriate action, whether converting it to ISO 20022 XML or returning an error 
    //message if the instruction is not supported. For eaxample if the MT 107 message has RTND instruction code, an
    //error will be thrown as the returned mapping for MT 107 is still not supported.
    if parsedMessage is swiftmt:MT104Message {
        iso20022Xml = check getMT104TransformFunction(parsedMessage);
    } else if parsedMessage is swiftmt:MT107Message {
        iso20022Xml = check getMT107TransformFunction(parsedMessage);
    } else if parsedMessage is swiftmt:MTn96Message {
        iso20022Xml = check getMTn96TransformFunction(parsedMessage);
    } 
    // The following conditions are used to identify the message type and the instruction code within the message in
    //order to call the coressponding function. 
    else if parsedMessage is swiftmt:MT103Message && parsedMessage.block4.MT72?.Cd?.content.toString().includes("/RETN/99"){
        iso20022Xml = check xmldata:toXml(check transformMT103ToPacs004(parsedMessage), {textFieldName: "content"});
    } else if parsedMessage is swiftmt:MT103Message && parsedMessage.block4.MT72?.Cd?.content.toString().includes("/REJT/"){
        iso20022Xml = check xmldata:toXml(check transformMT103ToPacs002(parsedMessage), {textFieldName: "content"});
    } else if parsedMessage is swiftmt:MT202Message && parsedMessage.block4.MT72?.Cd?.content.toString().includes("/RETN/99"){
        iso20022Xml = check xmldata:toXml(check transformMT202ToPacs004(parsedMessage), {textFieldName: "content"});
    } else {
        xml swiftMessageXml = check xmldata:toXml(parsedMessage);
        string messageType = (swiftMessageXml/**/<messageType>).data();
        string validationFlag = (swiftMessageXml/**/<ValidationFlag>/<value>).data();
        if validationFlag.length() > 0 {
            isolated function? func = transformFunctionMap[messageType + validationFlag];
            if func is () {
                return error("This SWIFT MT to ISO 20022 conversion is not supported.");
            }
            iso20022Xml = check xmldata:toXml(check function:call(func, parsedMessage).ensureType(), {textFieldName: "content"});
        } else {
            isolated function? func = transformFunctionMap[messageType];
            if func is () {
                return error("This SWIFT MT to ISO 20022 conversion is not supported.");
            }
            iso20022Xml = check xmldata:toXml(check function:call(func, parsedMessage).ensureType(), {textFieldName: "content"});
        }
    }
    xml:Element messageTypeXml = check (iso20022Xml/**/<AppHdr>/<MsgDefIdr>).ensureType();
    string isoMessageType = "urn:iso:std:iso:20022:tech:xsd:" + messageTypeXml.data();
    xml:Element appHdr = xml:createElement("AppHdr", {"xmlns": "urn:iso:std:iso:20022:tech:xsd:head.001.001.02"},
        (iso20022Xml/**/<AppHdr>).elementChildren());
    xml:Element document = xml:createElement("Document", {"xmlns": isoMessageType},
        (iso20022Xml/**/<Document>).elementChildren());
    xml:Element envelope = xml `<Envelope xmlns="urn:swift:xsd:envelope" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></Envelope>`;
    envelope.setChildren(appHdr + document);
    xml finalXml = xml:createComment("?xml version=\"1.0\" encoding=\"UTF-8\"?") + envelope;
    return finalXml;
} 

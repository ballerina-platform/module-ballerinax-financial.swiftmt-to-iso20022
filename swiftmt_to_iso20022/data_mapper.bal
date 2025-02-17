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
    
    // Transform message based on type
    xml iso20022Xml = check transformMessage(parsedMessage);
    
    // Clean and format final XML
    iso20022Xml = removeEmptyParents(iso20022Xml);
    return check createEnvelopedXml(iso20022Xml);
}

isolated function transformMessage(record {} parsedMessage) returns xml|error {
    return typeBasedTransform(parsedMessage) ?: 
           instructionBasedTransform(parsedMessage) ?: 
           generalTransform(parsedMessage);
}

isolated function typeBasedTransform(record {} message) returns xml|error? {
    if message is swiftmt:MT104Message {
        return check getMT104TransformFunction(message);
    } 
    if message is swiftmt:MT107Message {
        return check getMT107TransformFunction(message);
    } 
    if message is swiftmt:MTn96Message {
        return check getMTn96TransformFunction(message);
    } 
    return ();
}

isolated function instructionBasedTransform(record {} message) returns xml|error? {
    if message is swiftmt:MT103Message {
        if message.block4.MT72?.Cd?.content.toString().includes("/RETN/99") {
            return check xmldata:toXml(check transformMT103ToPacs004(message), {textFieldName: "content"});
        }
        if message.block4.MT72?.Cd?.content.toString().includes("/REJT/") {
            return check xmldata:toXml(check transformMT103ToPacs002(message), {textFieldName: "content"});
        }
    }
    if message is swiftmt:MT202Message && message.block4.MT72?.Cd?.content.toString().includes("/RETN/99") {
        return check xmldata:toXml(check transformMT202ToPacs004(message), {textFieldName: "content"});
    }
    return ();
}

isolated function generalTransform(record {} message) returns xml|error {
    xml swiftMessageXml = check xmldata:toXml(message);
    string messageType = (swiftMessageXml/**/<messageType>).data();
    string validationFlag = (swiftMessageXml/**/<ValidationFlag>/<value>).data();
    
    isolated function? func = validationFlag.length() > 0 ? 
        transformFunctionMap[messageType + validationFlag] : 
        transformFunctionMap[messageType];
    
    if func is () {
        return error("This SWIFT MT to ISO 20022 conversion is not supported.");
    }
    
    return check xmldata:toXml(check function:call(func, message).ensureType(), {textFieldName: "content"});
}

isolated function createEnvelopedXml(xml messageXml) returns xml|error {
    xml:Element messageTypeXml = check (messageXml/**/<AppHdr>/<MsgDefIdr>).ensureType();
    string isoMessageType = string `${XML_NAMESPACE_ISO}:${messageTypeXml.data()}`;
    
    xml:Element appHdr = xml:createElement("AppHdr", 
        {"xmlns": string `${XML_NAMESPACE_ISO}:${APP_HDR_VERSION}`},
        (messageXml/**/<AppHdr>).elementChildren()
    );
    
    xml:Element document = xml:createElement("Document", 
        {"xmlns": isoMessageType},
        (messageXml/**/<Document>).elementChildren()
    );
    
    xml:Element envelope = xml `<Envelope xmlns="urn:swift:xsd:envelope" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></Envelope>`;
    envelope.setChildren(appHdr + document);
    xml finalXml = xml:createComment("?xml version=\"1.0\" encoding=\"UTF-8\"?") + envelope;
    
    return finalXml;
} 

isolated function removeEmptyParents(xml node) returns xml {
    if node is xml:Element {
        xml children = node.getChildren();
        xml filteredChildren = xml ``;

        // Recursively process child elements
        foreach xml child in children {
            xml updatedChild = removeEmptyParents(child);
            if updatedChild != xml `` { 
                filteredChildren = filteredChildren.concat(updatedChild);
            }
        }

        if filteredChildren == xml `` && node.data() == "" {
            return xml ``; 
        }
        return xml:createElement(node.getName(), node.getAttributes(), filteredChildren);
    }
    return node; 
}

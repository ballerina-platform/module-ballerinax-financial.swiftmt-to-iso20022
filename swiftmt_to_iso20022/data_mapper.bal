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

configurable boolean isAddPrefix = true;

# Converts a SWIFT message in string format to its corresponding ISO 20022 XML format.
#
# The function uses a map of transformation functions corresponding to different SWIFT MT message types 
# and applies the appropriate transformation based on the parsed message type.
#
# + finMessage - The SWIFT message string that needs to be transformed to ISO 20022 XML.
# + return - Returns the transformed ISO 20022 XML or an error if the transformation fails.
public isolated function toIso20022Xml(string finMessage) returns xml|error {
    record {} parsedMessage = check swiftmt:parse(finMessage);
    
    // Transform message based on type
    xml iso20022Xml = check transformMessage(parsedMessage);
    xml:Element messageTypeXml = check (iso20022Xml/**/<AppHdr>/<MsgDefIdr>).ensureType();
    string isoMessageType = messageTypeXml.data().substring(0, 4);
    
    // Clean and format final XML
    iso20022Xml = check createEnvelopedXml(iso20022Xml);
    iso20022Xml = check removeEmptyParents(iso20022Xml, documentPrefix = isoMessageType);
    xml finalXml = xml:createComment("?xml version=\"1.0\" encoding=\"UTF-8\"?") + iso20022Xml;
    return finalXml;
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
    xml:Element appHdr = xml `<AppHdr/>`;
    xml:Element document = xml `<Document/>`;

    if isAddPrefix {
        appHdr = xml:createElement("AppHdr", 
            {"{http://www.w3.org/2000/xmlns/}head": string `${XML_NAMESPACE_ISO}:${APP_HDR_VERSION}`},
            (messageXml/**/<AppHdr>).elementChildren()
        );

        document = xml:createElement("Document", 
            {[string `{http://www.w3.org/2000/xmlns/}${messageTypeXml.data().substring(0, 4)}`]: isoMessageType},
            (messageXml/**/<Document>).elementChildren()
        );
    } else {
        appHdr = xml:createElement("AppHdr", {"xmlns": string `${XML_NAMESPACE_ISO}:${APP_HDR_VERSION}`},
            (messageXml/**/<AppHdr>).elementChildren()
        );

        document = xml:createElement("Document", {"xmlns": isoMessageType},
            (messageXml/**/<Document>).elementChildren()
        );
    }    
    
    xml:Element envelope = xml:createElement("Envelope", {"xmlns": "urn:swift:xsd:envelope",
    "{http://www.w3.org/2000/xmlns/}xsi": "http://www.w3.org/2001/XMLSchema-instance"},
            appHdr + document);
    
    return envelope;
} 

# Adds the appropriate prefix to the XML element based on the context
#
# + name - The name of the XML element
# + attributes - The attributes of the XML element
# + children - The children of the XML element
# + appHdr - Indicates if the element is within the AppHdr
# + document - Indicates if the element is within the Document
# + documentPrefix - The prefix to add to elements within the Document
# + return - The XML element with the appropriate prefix
isolated function addPrefixToElement(string name, map<string> attributes, xml children, boolean appHdr, boolean document, string documentPrefix) returns xml {
    if isAddPrefix {
        if appHdr {
            xml:Element element = xml:createElement(name, attributes, children);
            element.setName("head:" + name);
            return element;
        } 
        if document {
            xml:Element element = xml:createElement(name, attributes, children);
            element.setName(documentPrefix + ":" + name);
            return element;
        }
    }
    return xml:createElement(name, attributes, children);
}

# Recursively removes empty parent elements from the XML and adds prefixes based on the context
#
# + node - The XML node to process
# + isAppHdr - Indicates if the current node is within the AppHdr
# + isDocument - Indicates if the current node is within the Document
# + documentPrefix - The prefix to add to elements within the Document
# + return - The processed XML node or an error
isolated function removeEmptyParents(xml node, boolean isAppHdr = false, boolean isDocument = false, string documentPrefix = "") returns xml|error { 
    if node is xml:Element {
        xml children = node.getChildren();
        xml filteredChildren = xml ``;
        boolean appHdr = isAppHdr;
        boolean document = isDocument;

        if node.getName().includes("AppHdr") {
            appHdr = true;
        }
        if node.getName().includes("Document") {
            document = true;
            appHdr = false;
        }

        // Recursively process child elements
        foreach xml child in children {
            xml updatedChild = check removeEmptyParents(child, appHdr, document, documentPrefix);
            if updatedChild != xml `` { 
                filteredChildren = filteredChildren + updatedChild;
            }
        }

        if filteredChildren == xml `` && node.data() == "" {
            return xml ``; 
        }

        string name = node.getName();
        return addPrefixToElement(name, node.getAttributes(), filteredChildren, appHdr, document, documentPrefix);
    }
    return node; 
}

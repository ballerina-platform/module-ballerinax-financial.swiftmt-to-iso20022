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
    record {} customizedMessage = check swiftmt:parseSwiftMt(finMessage);
    // MT104, MT107, and MTn96 messages are handled separately to identify the type of instruction found within the 
    //message and to determine the appropriate action, whether converting it to ISO 20022 XML or returning an error 
    //message if the instruction is not supported. For eaxample if the MT 107 message has RTND instruction code, an
    //error will be thrown as the returned mapping for MT 107 is still not supported.
    if customizedMessage is swiftmt:MT104Message {
        return getMT104TransformFunction(customizedMessage);
    }
    if customizedMessage is swiftmt:MT107Message {
        return getMT107TransformFunction(customizedMessage);
    }
    if customizedMessage is swiftmt:MTn96Message {
        return getMTn96TransformFunction(customizedMessage);
    }
    xml swiftMessageXml = check xmldata:toXml(customizedMessage);
    string messageType = (swiftMessageXml/**/<messageType>).data();
    string validationFlag = (swiftMessageXml/**/<ValidationFlag>/<value>).data();
    if validationFlag.length() > 0 {
        isolated function? func = transformFunctionMap[messageType + validationFlag];
        if func is () {
            return error("This SWIFT MT to ISO 20022 conversion is not supported.");
        }
        return xmldata:toXml(check function:call(func, customizedMessage).ensureType(), {textFieldName: "content"});
    }
    isolated function? func = transformFunctionMap[messageType];
    if func is () {
        return error("This SWIFT MT to ISO 20022 conversion is not supported.");
    }
    return xmldata:toXml(check function:call(func, customizedMessage).ensureType(), {textFieldName: "content"});
}

## Overview

The SWIFT MT to ISO 20022 data mapper library is a comprehensive toolkit designed to convert SWIFT MT FIN messages into ISO 20022 XML. It simplifies the process of mapping SWIFT MT fields to their corresponding ISO 20022 elements, leveraging predefined records and parsers from the SWIFT MT and ISO 20022 libraries. This enables developers to seamlessly convert financial messages from the flat, text-based SWIFT format into the structured ISO 20022 XML standard, ensuring accurate and efficient data conversion.

### Key Features

- Convert SWIFT MT 1XX category messages to ISO 20022
- Convert SWIFT MT 2XX category messages to ISO 20022
- Convert SWIFT MT 9XX category messages to ISO 20022
- Convert SWIFT MT nXX category messages to ISO 20022
- Support for XML namespace prefixing in generated ISO 20022 messages

## Usage

### Conversion of SWIFT fin message to ISO 20022 Xml Standard

```ballerina
import ballerina/io;
import ballerinax/financial.swiftmtToIso20022 as mtToMx;

public function main() returns error? {
    string finMessage = string `{1:F01CHASUS33AXXX0000000000}
{2:I900CRESCHZZXXXXN}
{4:
:20:C11126A1378
:21:5482ABC
:25:9-9876543
:32A:090123USD233530,
-}`;
    io:println(mtToMx:toIso20022Xml(finMessage));
}
```

### Conversion of SWIFT fin message to ISO 20022 Xml Standard with Prefix

The library supports XML namespace prefixing for the generated ISO 20022 messages. When enabled, each XML element includes the appropriate namespace prefix based on the message type (such as "camt", "pain", or "pacs"). For example, in a pacs.008.001.08 message, elements in the Business Application Header will have the "head" prefix, while elements in the Document section will have the "pacs" prefix. 

By default, namespace prefixing is enabled. To disable this feature, follow these steps:

#### Step 1: Create a Configuration File

Create a configuration file in your working folder and name it `Config.Toml`

#### Step 2: Add Configuration Settings

Add the following configuration settings to the `Config.Toml` file:

```ballerina
[ballerinax.financial.swiftmtToIso20022]
isAddPrefix = false
```

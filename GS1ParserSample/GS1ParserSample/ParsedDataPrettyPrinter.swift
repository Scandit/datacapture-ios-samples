/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import ScanditParser

final class ParsedDataPrettyPrinter {

    private static let indentSize = 4

    func string(from parsedData: ParsedData) -> String {
        parsedData.fields.map(string(from:)).joined()
    }

    private func string(from field: ParsedField) -> String {
        string(fromKey: field.name, andValue: field.parsed, indentLevel: 0)
    }

    private func string(fromKey key: String, andValue value: Any?, indentLevel: Int) -> String {
        indent(level: indentLevel)
            .appending(string(fromKey: key))
            .appending(string(fromValue: value, indentLevel: indentLevel))
            .appending("\n")
    }

    private func string(fromKey key: String) -> String {
        "\(key): "
    }

    private func string(fromDictionary dictionary: [String: Any], indentLevel: Int) -> String {
        "{\n"
            .appending(
                dictionary.map {
                    string(fromKey: $0.key, andValue: $0.value, indentLevel: indentLevel + Self.indentSize)
                }
                .joined()
            )
            .appending(indent(level: indentLevel))
            .appending("}")
    }

    private func string(fromArray array: [Any], indentLevel: Int) -> String {
        "[\n"
            .appending(
                array.map {
                    indent(level: indentLevel + Self.indentSize)
                        .appending(string(fromValue: $0, indentLevel: indentLevel))
                }
                .joined(separator: ",\n")
            )
            .appending("\n")
            .appending(indent(level: indentLevel))
            .appending("]")
    }

    private func string(fromValue value: Any?, indentLevel: Int) -> String {
        if let string = value as? String {
            return string
        } else if let bool = value as? Bool {
            return bool.description
        } else if let number = value as? NSNumber {
            return number.stringValue
        } else if let array = value as? [Any] {
            return string(fromArray: array, indentLevel: indentLevel)
        } else if let dictionary = value as? [String: Any] {
            return string(fromDictionary: dictionary, indentLevel: indentLevel)
        } else {
            return "null"
        }
    }

    private func indent(level: Int) -> String {
        String(repeating: " ", count: level)
    }

}

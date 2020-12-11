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

import UIKit
import ScanditBarcodeCapture

class Row {
    enum Kind {
        case option
        case `switch`
        case valueWithUnit
        case float
        case choice
        case slider(minimum: Float, maximum: Float, decimalPlaces: Int)
        case symbology
        case action
    }

    let title: String
    let kind: Kind
    var getValue: (() -> Any?)?
    var didChangeValue: ((Any) -> Void)?
    var didSelect: ((Row, IndexPath) -> Void)?

    init<Value>(title: String,
                kind: Kind,
                getValue: (() -> Value?)?,
                didChangeValue: ((Value) -> Void)? = nil,
                didSelect: ((Row, IndexPath) -> Void)? = nil) {
        self.title = title
        self.kind = kind
        self.getValue = getValue
        self.didChangeValue = { didChangeValue?($0 as! Value)}
        self.didSelect = didSelect
    }

    init(title: String, kind: Kind, didSelect: ((Row, IndexPath) -> Void)? = nil) {
        self.title = title
        self.kind = kind
        self.getValue = nil
        self.didChangeValue = nil
        self.didSelect = didSelect
    }
}

extension Row {
    var cellClass: UITableViewCell.Type {
        switch self.kind {
        case .switch:
            return SwitchCell.self
        case .float:
            return FloatInputCell.self
        case .slider:
            return SliderCell.self
        default:
            return BasicCell.self
        }
    }
}

extension Row {
    static let defaultNumberFormatter = NumberFormatter(maximumFractionDigits: 2)

    var accessory: UITableViewCell.AccessoryType {
        switch kind {
        case .valueWithUnit, .choice, .symbology:
            return .disclosureIndicator
        case .option:
            guard let value = getValue?() as? Bool else {
                return .none
            }
            return value ? .checkmark : .none
        default:
            return .none
        }
    }

    var detailText: String? {
        switch kind {
        case .valueWithUnit:
            guard let getValue = getValue, let value = getValue() as? FloatWithUnit else {
                return nil
            }
            return "\(Row.defaultNumberFormatter.string(from: value.value)!) (\(value.unit))"
        case .choice:
            return getValue?().valueString(roundedTo: 2)
        case .slider(_, _, let decimalPlaces):
            return getValue?().valueString(roundedTo: decimalPlaces)
        case .symbology:
            guard let getValue = getValue, let symbologySettings = getValue() as? SymbologySettings else {
                return nil
            }
            return symbologySettings.isEnabled ? "On" : "Off"
        default:
            return nil
        }
    }
}

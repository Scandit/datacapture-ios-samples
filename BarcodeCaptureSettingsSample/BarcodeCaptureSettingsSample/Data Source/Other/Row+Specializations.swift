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

import ScanditBarcodeCapture

extension Row {
    static func valueWithUnit(title: String,
                              getValue: @escaping (() -> FloatWithUnit),
                              didChangeValue: @escaping ((FloatWithUnit) -> Void),
                              dataSourceDelegate: DataSourceDelegate?) -> Row {
        return Row(title: title,
                   kind: .valueWithUnit,
                   getValue: getValue,
                   didChangeValue: { [weak dataSourceDelegate] value in
                    didChangeValue(value)
                    dataSourceDelegate?.didChangeData() },
                   didSelect: { [weak dataSourceDelegate] row, _ in
                    dataSourceDelegate?.getFloatWithUnit(title: row.title,
                                                         currentValue: getValue(),
                                                         completion: { row.didChangeValue!($0) })
        })
    }

    static func option(title: String,
                       getValue: @escaping (() -> Any?),
                       didSelect: @escaping ((Row, IndexPath) -> Void),
                       dataSourceDelegate: DataSourceDelegate?) -> Row {
        return Row(title: title,
                   kind: .option,
                   getValue: getValue,
                   didChangeValue: nil,
                   didSelect: { [weak dataSourceDelegate] row, indexPath in
                    didSelect(row, indexPath)
                    dataSourceDelegate?.didChangeData()})
    }

    static func option(title: String,
                       getValue: @escaping (() -> Bool),
                       didChangeValue: @escaping ((Bool) -> Void),
                       dataSourceDelegate: DataSourceDelegate?) -> Row {
        return Row(title: title,
                   kind: .option,
                   getValue: getValue,
                   didChangeValue: { [weak dataSourceDelegate] in
                    didChangeValue($0)
                    dataSourceDelegate?.didChangeData() },
                   didSelect: { row, _ in row.didChangeValue!(!(row.getValue!() as! Bool)) })
    }

    static func action(title: String,
                       didSelect: ((Row, IndexPath) -> Void)? = nil) -> Row {
        return Row(title: title,
                   kind: .action,
                   didSelect: didSelect)
    }

    static func choice<Choice: CustomStringConvertible>(title: String,
                                                        options: [Choice],
                                                        getValue: @escaping (() -> Choice),
                                                        didChangeValue: @escaping ((Choice) -> Void),
                                                        dataSourceDelegate: DataSourceDelegate?) -> Row {
        return Row(title: title,
                   kind: .choice,
                   getValue: getValue,
                   didChangeValue: { [weak dataSourceDelegate] value in
                    didChangeValue(value)
                    dataSourceDelegate?.didChangeData() },
                   didSelect: { [weak dataSourceDelegate] row, _ in
                    dataSourceDelegate?.presentChoice(title: row.title,
                                                      options: options,
                                                      chosen: getValue(),
                                                      didChooseValue: { row.didChangeValue!($0) })
        })
    }

    static func symbology(getValue: @escaping (() -> SymbologySettings),
                          didChangeValue: @escaping ((SymbologySettings) -> Void),
                          dataSourceDelegate: DataSourceDelegate?) -> Row {
        return Row(title: getValue().symbology.readableName,
                   kind: .symbology,
                   getValue: getValue,
                   didChangeValue: { [weak dataSourceDelegate] value in
                    didChangeValue(value)
                    dataSourceDelegate?.didChangeData() },
                   didSelect: { [weak dataSourceDelegate] row, _ in
                    dataSourceDelegate?.presentSymbologySettings(currentSettings: row.getValue!() as! SymbologySettings,
                                                                 didChangeValue: { row.didChangeValue!($0) })
        })
    }
}

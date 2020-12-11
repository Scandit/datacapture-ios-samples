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

class SelectionTypeDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    var sections: [Section] {
        get {
            if SettingsManager.current.selectionType is BarcodeSelectionTapSelection {
                return [selectionType, freezeBehavior, tapBehavior]
            } else if SettingsManager.current.selectionType is BarcodeSelectionAimerSelection {
                return [selectionType, selectionStrategy]
            } else {
                fatalError()
            }
        }
    }

    lazy var selectionType: Section = {
        let rows = [
            Row.option(title: "Tap to Select",
                       getValue: {
                        SettingsManager.current.selectionType is BarcodeSelectionTapSelection
                       },
                       didSelect: { _, _ in SettingsManager.current.selectionType = BarcodeSelectionTapSelection() },
                       dataSourceDelegate: self.delegate),
            Row.option(title: "Aim to Select",
                       getValue: {
                        SettingsManager.current.selectionType is BarcodeSelectionAimerSelection
                       },
                       didSelect: { _, _ in SettingsManager.current.selectionType = BarcodeSelectionAimerSelection() },
                       dataSourceDelegate: self.delegate)
        ]
        return Section(title: "Selection Type", rows: rows)
    }()

    lazy var freezeBehavior: Section = {
        let rows = [
            Row.option(title: "Manual",
                       getValue: {
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        return selectionType.freezeBehavior == .manual
                       },
                       didSelect: { _, _ in
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        selectionType.freezeBehavior = .manual
                        SettingsManager.current.selectionType = selectionType
                       },
                       dataSourceDelegate: self.delegate),
            Row.option(title: "Manual and Automatic",
                       getValue: {
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        return selectionType.freezeBehavior == .manualAndAutomatic
                       },
                       didSelect: { _, _ in
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        selectionType.freezeBehavior = .manualAndAutomatic
                        SettingsManager.current.selectionType = selectionType
                       },
                       dataSourceDelegate: self.delegate)
        ]
        return Section(title: "Freeze Behavior", rows: rows)
    }()

    lazy var tapBehavior: Section = {
        let rows = [
            Row.option(title: "Toggle Selection",
                       getValue: {
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        return selectionType.tapBehavior == .toggleSelection
                       },
                       didSelect: { _, _ in
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        selectionType.tapBehavior = .toggleSelection
                        SettingsManager.current.selectionType = selectionType
                       },
                       dataSourceDelegate: self.delegate),
            Row.option(title: "Repeat Selection",
                       getValue: {
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        return selectionType.tapBehavior == .repeatSelection
                       },
                       didSelect: { _, _ in
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionTapSelection else { fatalError() }
                        selectionType.tapBehavior = .repeatSelection
                        SettingsManager.current.selectionType = selectionType
                       },
                       dataSourceDelegate: self.delegate)
        ]
        return Section(title: "Tap Behavior", rows: rows)
    }()

    lazy var selectionStrategy: Section = {
        let rows = [
            Row.option(title: "Auto",
                       getValue: {
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionAimerSelection else {
                            return false
                        }
                        return type(of: selectionType.selectionStrategy) == BarcodeSelectionAutoSelectionStrategy.self
                       },
                       didSelect: { _, _ in
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionAimerSelection else { fatalError() }
                        selectionType.selectionStrategy = BarcodeSelectionAutoSelectionStrategy()
                        SettingsManager.current.selectionType = selectionType
                       },
                       dataSourceDelegate: self.delegate),
            Row.option(title: "Manual",
                       getValue: {
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionAimerSelection else { fatalError() }
                        return type(of: selectionType.selectionStrategy) == BarcodeSelectionManualSelectionStrategy.self
                       },
                       didSelect: { _, _ in
                        guard let selectionType = SettingsManager.current.selectionType
                                as? BarcodeSelectionAimerSelection else { fatalError() }
                        selectionType.selectionStrategy = BarcodeSelectionManualSelectionStrategy()
                        SettingsManager.current.selectionType = selectionType
                       },
                       dataSourceDelegate: self.delegate)
        ]
        return Section(title: "Selection Strategy", rows: rows)
    }()
}

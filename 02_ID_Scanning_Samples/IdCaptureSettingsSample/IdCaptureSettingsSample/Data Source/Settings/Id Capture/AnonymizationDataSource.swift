//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
// See the License for the specific language governing permissions and
// limitations under the License.
//

import ScanditIdCapture

class AnonymizationDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        let modeRows: [Row] = IdAnonymizationMode.allCases.map { mode in
            Row.option(
                title: mode.description,
                getValue: { SettingsManager.current.anonymizationMode == mode },
                didSelect: { _, _ in SettingsManager.current.anonymizationMode = mode },
                dataSourceDelegate: self.delegate
            )
        }

        let fieldRows: [Row] = IdFieldType.allCases.map { fieldType in
            Row(
                title: fieldType.description,
                kind: .switch,
                getValue: { SettingsManager.current.anonymizedFields.contains(fieldType) },
                didChangeValue: { value, _, _ in
                    if value {
                        SettingsManager.current.anonymizedFields.insert(fieldType)
                    } else {
                        SettingsManager.current.anonymizedFields.remove(fieldType)
                    }
                }
            )
        }

        return [
            Section(title: "Mode", rows: modeRows),
            Section(title: "Anonymized Fields", rows: fieldRows),
        ]
    }()
}

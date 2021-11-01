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

import ScanditIdCapture

class SupportedDocumentsDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        let rows = SDCAllIdDocumentTypes()
            .map { IdDocumentType(rawValue: $0.uintValue) }
            .map { documentType in
                Row(title: documentType.description,
                    kind: .switch,
                    getValue: { SettingsManager.current.supportedDocuments.contains(documentType) },
                    didChangeValue: { newValue in
                        if newValue {
                            SettingsManager.current.supportedDocuments.insert(documentType)
                        } else {
                            SettingsManager.current.supportedDocuments.remove(documentType)
                        }
                    })
        }
        return [
            Section(rows: rows)
        ]
    }()
}

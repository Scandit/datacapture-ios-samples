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

class DocumentTypeDataSource: DataSource {
    weak var delegate: DataSourceDelegate?
    let modelPath: DocumentSelectionMenuModel

    init(delegate: DataSourceDelegate, keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>) {
        self.delegate = delegate
        self.modelPath = DocumentSelectionMenuModel(selectionKeyPath: keyPath)
    }

    func supportingText(documentType: IdCaptureDocumentType) -> String {
        if documentType == .regionSpecific {
            var text = "Subtypes\n"
            let subtypes = modelPath.subtypes()
            text.append(subtypes.supportingText)
            return text
        }
        var text = "Regions\n"
        let regions = modelPath.regions(documentType: documentType)
        text.append(regions.supportingText)
        return text
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        let rows = IdCaptureDocumentType.allCases
            .map { documentType in
                let row = Row(title: documentType.description,
                              kind: .subtitledSwitch,
                              getValue: { self.modelPath.contains(documentType: documentType) },
                              didChangeValue: { [weak delegate] value, row, indexPath in
                                  self.modelPath.updateSelectionFromSwitch(documentType: documentType, insert: value)
                                  row.supportingText = self.supportingText(documentType: documentType)
                                  delegate?.didChangeData(at: [indexPath])
                              },
                              didSelect: { [weak delegate] row, indexPath in
                                guard self.modelPath.contains(documentType: documentType) else { return }
                                delegate?.present(viewController: {
                                    let updateClosure = { [weak self] in
                                        guard let self = self else { return }
                                        row.supportingText = self.supportingText(documentType: documentType)
                                        delegate?.didChangeData(at: [indexPath])
                                    }

                                    switch documentType {
                                    case .regionSpecific:
                                        return RegionSpecificSubtypeTableViewController(keyPath: self.modelPath.keyPath,
                                                                                        updateParentCell: updateClosure)
                                    default:
                                        return RegionsTableViewController(keyPath: self.modelPath.keyPath,
                                                                          documentType: documentType,
                                                                          updateParentCell: updateClosure)
                                    }
                                })
                })
                row.supportingText = supportingText(documentType: documentType)
                return row
        }
        return [
            Section(rows: rows)
        ]
    }()
}

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

class SearchingDocumentSelectionDataSource<Element: CaseIterable & CustomStringConvertible>: DataSource {
    var searchText: String?
    weak var delegate: DataSourceDelegate?
    let modelPath: DocumentSelectionMenuModel
    let documentType: IdCaptureDocumentType
    let updateParentCell: () -> Void

    init(
        delegate: DataSourceDelegate,
        keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>,
        documentType: IdCaptureDocumentType,
        updateParentCell: @escaping () -> Void
    ) {
        self.delegate = delegate
        self.modelPath = DocumentSelectionMenuModel(selectionKeyPath: keyPath)
        self.documentType = documentType
        self.updateParentCell = updateParentCell
    }

    func didChange() {
        delegate?.didChangeData()
        self.updateParentCell()
    }

    func document(from element: Element) -> IdCaptureDocument {
        fatalError("Should be implemented by subclass")
    }

    func contains(element: Element) -> Bool {
        fatalError("Should be implemented by subclass")
    }

    func elements() -> [Element] {
        let elements = Element.allCases.filter {
            guard let searchText = searchText else { return true }
            guard !searchText.isEmpty else { return true }
            let match = $0.description.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return match != nil
        }
        return elements
    }

    // MARK: - Sections

    var sections: [Section] {
        let rows = elements()
            .map { element in
                Row(
                    title: element.description,
                    kind: .switch,
                    getValue: { self.contains(element: element) },
                    didChangeValue: { value, _, _ in
                        let document = self.document(from: element)
                        self.modelPath.updateSelection(document: document, insert: value)
                        self.didChange()
                    }
                )
            }
        return [
            Section(rows: rows)
        ]
    }
}

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

class RegionsTableViewController: SearchingSettingsTableViewController {
    let keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>
    let documentType: IdCaptureDocumentType
    let updateParentCell: () -> Void

    init(keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>,
         documentType: IdCaptureDocumentType,
         updateParentCell: @escaping () -> Void) {
        self.keyPath = keyPath
        self.documentType = documentType
        self.updateParentCell = updateParentCell
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hasSelection() -> Bool {
        guard let dataSource = dataSource as? DocumentRegionDataSource else { return false }
        return dataSource.modelPath.contains(documentType: documentType)
    }

    override func search(text: String?) -> Bool {
        guard let dataSource = dataSource as? DocumentRegionDataSource,
              text != dataSource.searchText else { return false }
        dataSource.searchText = text
        return true
    }

    override func setupDataSource() {
        dataSource = DocumentRegionDataSource(delegate: self,
                                              keyPath: keyPath,
                                              documentType: documentType,
                                              updateParentCell: updateParentCell)
    }
}

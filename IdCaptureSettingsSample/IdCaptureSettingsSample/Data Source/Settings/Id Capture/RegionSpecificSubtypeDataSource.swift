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

class RegionSpecificSubtypeDataSource: SearchingDocumentSelectionDataSource<RegionSpecificSubtype> {
    init(delegate: DataSourceDelegate,
         keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>,
         updateParentCell: @escaping () -> Void) {
        super.init(delegate: delegate,
                   keyPath: keyPath,
                   documentType: .regionSpecific,
                   updateParentCell: updateParentCell)
    }

    override func document(from element: RegionSpecificSubtype) -> IdCaptureDocument {
        RegionSpecific(subtype: element)
    }

    override func contains(element: RegionSpecificSubtype) -> Bool {
        self.modelPath.contains(subtype: element)
    }

    override func elements() -> [RegionSpecificSubtype] {
        return super.elements().sortedAlphabetically
    }

    var allSelected: Bool {
        RegionSpecificSubtype.allCases.count == self.modelPath.subtypes().count
    }

    func updateSelectionAll(insert: Bool) {
        let documents = RegionSpecificSubtype.allCases.map { document(from: $0) }
        self.modelPath.updateSelection(documents: documents, insert: insert)
        didChange()
    }
}

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

class DocumentSelectionMenuModel {
    let keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>

    init(selectionKeyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>) {
        self.keyPath = selectionKeyPath
    }

    func documents(ofType documentType: IdCaptureDocumentType) -> [IdCaptureDocument] {
        let allDocuments = SettingsManager.current[keyPath: self.keyPath]
        return  allDocuments.filter { $0.documentType == documentType }
    }

    func subtypes() -> [RegionSpecificSubtype] {
        let regionSpecifics = documents(ofType: .regionSpecific).compactMap { $0 as? RegionSpecific }
        if regionSpecifics.isEmpty {
            return []
        }
        return regionSpecifics.map { $0.subtype }.sortedAlphabetically
    }

    func regions(documentType: IdCaptureDocumentType) -> [IdCaptureRegion] {
        return documents(ofType: documentType).map { $0.region}.humanSorted
    }

    func contains(documentType: IdCaptureDocumentType) -> Bool {
        SettingsManager.current[keyPath: self.keyPath].contains(documentType: documentType)
    }

    func contains(documentType: IdCaptureDocumentType, region: IdCaptureRegion) -> Bool {
        let regions = documents(ofType: documentType).map { $0.region}
        return regions.contains(region)
    }

    func contains(subtype: RegionSpecificSubtype) -> Bool {
        return subtypes().contains(subtype)
    }

    func insertSelection(documents: [IdCaptureDocument]) {
        var currentDocuments = Set(SettingsManager.current[keyPath: self.keyPath])
        currentDocuments.formUnion(documents)
        var current = SettingsManager.current
        current[keyPath: self.keyPath] = Array(currentDocuments)
    }

    func removeSelection(documents: [IdCaptureDocument]) {
        var currentDocuments = Set(SettingsManager.current[keyPath: self.keyPath])
        currentDocuments.subtract(documents)
        var current = SettingsManager.current
        current[keyPath: self.keyPath] = Array(currentDocuments)
    }

    func updateSelection(documents: [IdCaptureDocument], insert: Bool) {
        if insert {
            insertSelection(documents: documents)
        } else {
            removeSelection(documents: documents)
        }
    }

    func updateSelection(document: IdCaptureDocument, insert: Bool) {
        updateSelection(documents: [document], insert: insert)
    }

    func updateSelectionFromSwitch(documentType: IdCaptureDocumentType, insert: Bool) {
        if insert {
            // In this sample the RegionSpecific switch enables all RegionSpecific IDs
            if documentType == .regionSpecific {
                let documents = RegionSpecificSubtype.allCases.map {
                    RegionSpecific(subtype: $0)
                }
                insertSelection(documents: documents)
            } else {
                let document = documentType.document(region: .any)
                updateSelection(document: document, insert: true)
            }
        } else {
            removeAll(documentType: documentType)
        }
    }

    func removeAll(documentType: IdCaptureDocumentType) {
        let documents = Set(SettingsManager.current[keyPath: self.keyPath])
        var current = SettingsManager.current
        current[keyPath: self.keyPath] = documents.filter { $0.documentType != documentType}
    }
}

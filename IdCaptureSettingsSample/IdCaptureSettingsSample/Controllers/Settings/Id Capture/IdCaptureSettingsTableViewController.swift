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

class IdCaptureSettingsTableViewController: UITableViewController {
    @IBOutlet weak var acceptedDocumentsCell: UITableViewCell!
    @IBOutlet weak var rejectedDocumentsCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedDocumentsCell.detailTextLabel?.numberOfLines = 0
        rejectedDocumentsCell.detailTextLabel?.numberOfLines = 0
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        let acceptedString = documentSelectionDetailsString(documents: SettingsManager.current.acceptedDocuments)
        acceptedDocumentsCell.detailTextLabel?.text = acceptedString
        let rejectedString = documentSelectionDetailsString(documents: SettingsManager.current.rejectedDocuments)
        rejectedDocumentsCell.detailTextLabel?.text = rejectedString
        tableView.reloadData()
    }

    func documentSelectionDetailsString(documents: [IdCaptureDocument]) -> String {
        var selectedDocumentStrings = [String]()
        IdCaptureDocumentType.allCases.forEach { documentType in
            let documentsOfType = documents.filter { $0.documentType == documentType }
            if !documentsOfType.isEmpty {
                if documentType == .regionSpecific {
                    let regionSpecifics = documentsOfType.compactMap { $0 as? RegionSpecific }
                    let subtypes = regionSpecifics.map { $0.subtype }
                    let supportingText = subtypes.sortedAlphabetically.supportingText
                    selectedDocumentStrings.append("\(documentType.description)(\(supportingText))")
                } else {
                    let regions = documentsOfType.map { $0.region}
                    selectedDocumentStrings.append("\(documentType.description)(\(regions.humanSorted.supportingText))")
                }
            }
        }
        return selectedDocumentStrings.joined(separator: ", ")
    }
}

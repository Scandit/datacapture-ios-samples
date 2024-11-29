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

import UIKit
import ScanditIdCapture

enum Section: Int, CaseIterable {
    case title
    case result
    case avatar
    case fields
}

enum Field: Int, CaseIterable {
    case fullName
    case sex
    case nationality
    case dateOfBirth
    case address
    case documentNumber
    case documentAdditionalNumber
    case dateOfExpiry
    case issuingCountry
    case dateOfIssue

    var title: String {
        switch self {
        case .fullName: return "FULL NAME"
        case .sex: return "SEX"
        case .nationality: return "NATIONALITY"
        case .dateOfBirth: return "DATE OF BIRTH"
        case .address: return "ADDRESS"
        case .documentNumber: return "DOCUMENT NUMBER"
        case .documentAdditionalNumber: return "DOCUMENT ADDITIONAL NUMBER"
        case .dateOfExpiry: return "DATE OF EXPIRY"
        case .issuingCountry: return "ISSUING COUNTRY"
        case .dateOfIssue: return "DATE OF ISSUE"
        }
    }

    func value(in capturedId: CapturedId) -> String {
        switch self {
        case .fullName: return capturedId.fullName
        case .sex: return capturedId.sex.valueOrNil
        case .nationality: return capturedId.nationality.valueOrNil
        case .dateOfBirth: return capturedId.dateOfBirth.valueOrNil
        case .address: return capturedId.address.valueOrNil
        case .documentNumber: return capturedId.documentNumber.valueOrNil
        case .documentAdditionalNumber: return capturedId.documentAdditionalNumber.valueOrNil
        case .dateOfExpiry: return capturedId.dateOfExpiry.valueOrNil
        case .issuingCountry: return capturedId.issuingCountry.description
        case .dateOfIssue: return capturedId.dateOfIssue.valueOrNil
        }
    }
}

extension DLScanningResultViewController.Result {
    init(status: Status, message: String) {
        self.status = status
        self.message = message
        self.image = nil
        self.altText = nil
    }
}

final class DLScanningResultViewController: UITableViewController {
    struct Result {
        enum Status {
            case success
            case info
            case error
        }

        let status: Status
        let message: String
        let image: UIImage?
        let altText: String?
    }

    private var capturedId: CapturedId?
    private var results: [Result] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadSections(IndexSet(integer: Section.result.rawValue), with: .automatic)
            }
        }
    }

    func prepare(_ capturedId: CapturedId, _ result: DLScanningVerificationResult) {
        self.capturedId = capturedId
        results = makeVerificationResults(result)
        if isViewLoaded { tableView.reloadData() }
    }

    private func makeVerificationResults(_ result: DLScanningVerificationResult) -> [Result] {
        var results = [Result]()
        let status = result.status

        guard status != .expired else {
            results.append(Result(status: .error, message: "Document has expired."))
            return results
        }

        results.append(Result(status: .success, message: "Document has not expired."))

        if status == .forged {
            results.append(Result(status: .error, message: "Document barcode is forged."))
        } else if status == .likelyForged {
            results.append(Result(status: .success, message: "Document barcode is likely forged."))
        } else {
            results.append(Result(status: .success, message: "Document barcode is authentic."))
        }

        return results
    }
}

extension DLScanningResultViewController /*: UITableViewDataSource */ {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        guard capturedId != nil else { return 0 }
        switch section {
        case .title: return 1
        case .result: return results.count
        case .avatar: return capturedId?.images.face != nil ? 1 : 0
        case .fields: return Field.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        switch section {
        case .title: return Self.makeTitleCell(tableView, indexPath: indexPath)
        case .result: return Self.makeResultCell(tableView, indexPath: indexPath, result: results[indexPath.row])
        case .avatar: return Self.makeAvatarCell(tableView, indexPath: indexPath, capturedId: capturedId!)
        case .fields: return Self.makeFieldCell(tableView, indexPath: indexPath, capturedId: capturedId!)
        }
    }
}

extension DLScanningResultViewController {
    static func makeFieldCell(
        _ tableView: UITableView,
        indexPath: IndexPath,
        capturedId: CapturedId
    ) -> UITableViewCell {
        guard let field = Field(rawValue: indexPath.row) else { fatalError() }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FieldTableViewCell.cellIdentifier,
            for: indexPath) as? FieldTableViewCell else { fatalError() }

        cell.titleLabel.text = field.title
        cell.valueLabel.text = field.value(in: capturedId)
        return cell
    }

    static func makeAvatarCell(
        _ tableView: UITableView,
        indexPath: IndexPath,
        capturedId: CapturedId
    ) -> UITableViewCell {
        guard let image = capturedId.images.face else { fatalError() }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AvatarTableViewCell.cellIdentifier,
            for: indexPath) as? AvatarTableViewCell else { fatalError() }

        cell.avatarView.image = image
        return cell
    }

    static func makeResultCell(
        _ tableView: UITableView,
        indexPath: IndexPath,
        result: Result
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ResultCell.cellIdentifier,
            for: indexPath) as? ResultCell else { fatalError() }

        cell.result = result
        return cell
    }

    static func makeTitleCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TitleTableViewCell.cellIdentifier,
            for: indexPath) as? TitleTableViewCell else { fatalError() }

        return cell
    }
}

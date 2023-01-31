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

import UIKit
import ScanditIdCapture

private extension CapturedId {
    var dateOfBirthString: String {
        guard let date = dateOfBirth?.date else { return "" }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

    var isExpired: Bool {
        guard let expiryDate = dateOfExpiry?.date else { return false }
        return expiryDate < Date()
    }
}

enum Section: Int, CaseIterable {
    case result
    case avatar
    case fields
}

enum Field: Int, CaseIterable {
    case fullName
    case gender
    case dateOfBirth
    case nationality
    case issuingCountry
    case documentNumber

    var title: String {
        switch self {
        case .fullName: return "FULL NAME"
        case .gender: return "SEX / GENDER"
        case .dateOfBirth: return "DATE OF BIRTH"
        case .nationality: return "NATIONALITY"
        case .issuingCountry: return "ISSUING COUNTRY"
        case .documentNumber: return "DOCUMENT NUMBER"
        }
    }

    func value(in capturedId: CapturedId) -> String {
        switch self {
        case .fullName: return capturedId.fullName
        case .gender: return capturedId.sex ?? ""
        case .dateOfBirth: return capturedId.dateOfBirthString
        case .nationality: return capturedId.nationality ?? ""
        case .issuingCountry: return capturedId.issuingCountry ?? ""
        case .documentNumber: return capturedId.documentNumber ?? ""
        }
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
        results = makeverificationResults(result)
        if isViewLoaded { tableView.reloadData() }
    }

    private func makeverificationResults(_ result: DLScanningVerificationResult) -> [Result] {
        var results = [Result]()
        guard result != .frontBackDoesNotMatch else {
            results.append(Result(status: .error, message: "Information on front and back does not match."))
            return results
        }

        results.append(Result(status: .success, message: "Information on front and back matches."))

        guard result != .expired else {
            results.append(Result(status: .error, message: "This document is expired."))
            return results
        }

        if result == .cloudVerificationFailed {
            results.append(Result(status: .error, message: "Cloud verification failed."))
        } else {
            results.append(Result(status: .success, message: "Cloud verification successful."))
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
        case .result: return results.count
        case .avatar: return capturedId!.idImage(of: .face) != nil ? 1 : 0
        case .fields: return Field.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        switch section {
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
        guard let image = capturedId.idImage(of: .face) else { fatalError() }
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
}

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
import UIKit

private protocol CellProvider {
    func dequeueAndConfigureCell(from tableView: UITableView) -> UITableViewCell
}

private struct FieldCellProvider: CellProvider {
    let title: String
    let value: String?
    /// Accessibility identifier set on the value label so UI tests can assert on it.
    let accessibilityIdentifier: String

    func dequeueAndConfigureCell(from tableView: UITableView) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: FieldCell.reuseIdentifier
            ) as? FieldCell ?? FieldCell()
        cell.configure(title: title, value: value, valueAccessibilityIdentifier: accessibilityIdentifier)
        return cell
    }
}

/// Builds the rows shown for a captured document.
private struct ResultPresenter {
    let rows: [CellProvider]

    init(capturedId: CapturedId) {
        var rows: [CellProvider] = [
            FieldCellProvider(
                title: "Full Name",
                value: capturedId.fullName,
                accessibilityIdentifier: "result.fullName"
            ),
            FieldCellProvider(
                title: "Date of Birth",
                value: capturedId.dateOfBirth.map { "\($0)" },
                accessibilityIdentifier: "result.dateOfBirth"
            ),
            FieldCellProvider(
                title: "Date of Expiry",
                value: capturedId.dateOfExpiry.map { "\($0)" },
                accessibilityIdentifier: "result.dateOfExpiry"
            ),
            FieldCellProvider(
                title: "Document Number",
                value: capturedId.documentNumber,
                accessibilityIdentifier: "result.documentNumber"
            ),
            FieldCellProvider(
                title: "Nationality",
                value: capturedId.nationality,
                accessibilityIdentifier: "result.nationality"
            ),
            FieldCellProvider(
                title: "Document Type",
                value: capturedId.document.map { "\($0.documentType)" },
                accessibilityIdentifier: "result.documentType"
            ),
        ]
        // The raw machine-readable zone, shown only when present.
        if let mrz = capturedId.mrzResult?.capturedMrz, !mrz.isEmpty {
            rows.append(
                FieldCellProvider(title: "MRZ", value: mrz, accessibilityIdentifier: "result.mrz")
            )
        }
        self.rows = rows
    }
}

/// Shows the fields extracted from a captured document as a simple scrollable list.
final class ResultViewController: UIViewController {

    private let presenter: ResultPresenter
    private lazy var tableView = UITableView(frame: view.bounds, style: .plain)

    init(capturedId: CapturedId) {
        presenter = ResultPresenter(capturedId: capturedId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recognized Document"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        presenter.rows[indexPath.row].dequeueAndConfigureCell(from: tableView)
    }
}

/// A cell rendering a bold title above its value.
private final class FieldCell: UITableViewCell {

    static let reuseIdentifier = "FieldCell"
    private static let emptyPlaceholder = "<empty>"

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    convenience init() {
        self.init(style: .default, reuseIdentifier: FieldCell.reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configure(title: String, value: String?, valueAccessibilityIdentifier: String) {
        titleLabel.text = title
        let resolved: String
        if let value, !value.isEmpty {
            resolved = value
        } else {
            resolved = FieldCell.emptyPlaceholder
        }
        valueLabel.text = resolved
        valueLabel.accessibilityIdentifier = valueAccessibilityIdentifier
    }
}

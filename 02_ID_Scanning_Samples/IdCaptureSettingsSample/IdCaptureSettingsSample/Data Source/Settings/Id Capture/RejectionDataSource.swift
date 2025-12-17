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

class RejectionDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        [
            Section(rows: [
                Row(
                    title: "Reject Expired IDs",
                    kind: .switch,
                    getValue: { SettingsManager.current.rejectExpiredIds },
                    didChangeValue: { value, _, _ in
                        SettingsManager.current.rejectExpiredIds = value
                    }
                ),
                Row(
                    title: "Reject Not Real ID Compliant",
                    kind: .switch,
                    getValue: { SettingsManager.current.rejectNotRealIdCompliant },
                    didChangeValue: { value, _, _ in
                        SettingsManager.current.rejectNotRealIdCompliant = value
                    }
                ),
                Row(
                    title: "Reject Forged Aamva Barcodes",
                    kind: .switch,
                    getValue: { SettingsManager.current.rejectForgedAamvaBarcodes },
                    didChangeValue: { value, _, _ in
                        SettingsManager.current.rejectForgedAamvaBarcodes = value
                    }
                ),
                Row(
                    title: "Reject Inconsistent Data",
                    kind: .switch,
                    getValue: { SettingsManager.current.rejectInconsistentData },
                    didChangeValue: { value, _, _ in
                        SettingsManager.current.rejectInconsistentData = value
                    }
                ),
                Row.action(
                    title: "Reject Holder Below Age",
                    getValue: {
                        if let age = SettingsManager.current.rejectHolderBelowAge?.intValue {
                            return String(age)
                        }
                        return "OFF"
                    },
                    didSelect: { [weak delegate] _, _ in
                        delegate?.present(viewController: { RejectHolderBelowAgeTableViewController() })
                    }
                ),
                Row.action(
                    title: "Reject IDs Expiring In Days",
                    getValue: {
                        if let age = SettingsManager.current.rejectIdsExpiringInDays?.intValue {
                            return String(age)
                        }
                        return "OFF"
                    },
                    didSelect: { [weak delegate] _, _ in
                        delegate?.present(viewController: { RejectIdsExpiringInTableViewController() })
                    }
                ),
                Row(
                    title: "Reject Voided IDs",
                    kind: .switch,
                    getValue: { SettingsManager.current.rejectVoidedIds },
                    didChangeValue: { value, _, _ in
                        SettingsManager.current.rejectVoidedIds = value
                    }
                ),
                Row(
                    title: "Rejection Timeout (s)",
                    kind: .integer,
                    getValue: { SettingsManager.current.rejectionTimeoutSeconds },
                    didChangeValue: { value, _, _ in
                        SettingsManager.current.rejectionTimeoutSeconds = value
                    }
                ),
            ])
        ]
    }()
}

class OptionalNumberDataSource: DataSource {
    weak var delegate: DataSourceDelegate?
    let defaultValue: CGFloat
    let valueText: String
    let keyPath: ReferenceWritableKeyPath<SettingsManager, NSNumber?>
    init(
        delegate: DataSourceDelegate,
        keyPath: ReferenceWritableKeyPath<SettingsManager, NSNumber?>,
        valueText: String,
        defaultValue: CGFloat = 0.0
    ) {
        self.delegate = delegate
        self.keyPath = keyPath
        self.valueText = valueText
        self.defaultValue = defaultValue
    }

    // MARK: - Sections

    var sections: [Section] {
        if SettingsManager.current[keyPath: self.keyPath] == nil {
            return [enableSwitch]
        }
        return [enableSwitch, valueEntry]
    }

    lazy var enableSwitch: Section = {
        let rows: [Row] = [
            Row(
                title: "Enabled",
                kind: .switch,
                getValue: {
                    SettingsManager.current[keyPath: self.keyPath] != nil
                },
                didChangeValue: { [weak self] value, _, _ in
                    guard let self else { return }
                    let number = value ? NSNumber(value: self.defaultValue) : nil
                    SettingsManager.current[keyPath: self.keyPath] = number
                    self.updateSettings()
                }
            )
        ]
        return Section(rows: rows)
    }()

    lazy var valueEntry: Section = {
        Section(rows: [
            Row(
                title: self.valueText,
                kind: .float,
                getValue: {
                    if let floatValue = SettingsManager.current[keyPath: self.keyPath]?.floatValue {
                        return CGFloat(floatValue)
                    }
                    return self.defaultValue
                },
                didChangeValue: { value, _, _ in
                    SettingsManager.current[keyPath: self.keyPath] = NSNumber(value: CGFloat(value))
                }
            )
        ])
    }()

    private func updateSettings() {
        delegate?.didChangeData()
    }
}

class RejectHolderBelowAgeTableViewController: SettingsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reject Holder Below Age"
    }

    override func setupDataSource() {
        dataSource = OptionalNumberDataSource(
            delegate: self,
            keyPath: \.rejectHolderBelowAge,
            valueText: "Age in years",
            defaultValue: 21.0
        )
    }
}

class RejectIdsExpiringInTableViewController: SettingsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reject IDs Expiring In Days"
    }

    override func setupDataSource() {
        dataSource = OptionalNumberDataSource(
            delegate: self,
            keyPath: \.rejectIdsExpiringInDays,
            valueText: "Days",
            defaultValue: 30.0
        )
    }
}

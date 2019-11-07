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
import ScanditCaptureCore

class FloatWithUnitChooserViewController: UITableViewController, FloatInputCellDelegate {

    enum Section: Int, CaseIterable {
        case value, unit
    }

    typealias Value = FloatWithUnit
    typealias DidChooseValueHandler = (Value) -> Void

    private var valueWithUnit: Value
    private let didChooseValue: DidChooseValueHandler

    init(title: String?, value: Value?, didChooseValue: @escaping DidChooseValueHandler) {
        let defaultValue = FloatWithUnit(value: 0, unit: .fraction)
        self.valueWithUnit = value ?? defaultValue
        self.didChooseValue = didChooseValue
        super.init(style: .grouped)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.register(FloatInputCell.self, forCellReuseIdentifier: FloatInputCell.reuseIdentifier)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        didChooseValue(valueWithUnit)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .value:
            return 1
        case .unit:
            return MeasureUnit.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .value:
            let cell: FloatInputCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = "Value"
            cell.value = valueWithUnit.value
            cell.delegate = self
            return cell
        case .unit:
            let cell: UITableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let unit = MeasureUnit.allCases[indexPath.row]
            cell.textLabel?.text = unit.description
            cell.accessoryType = unit == valueWithUnit.unit ? .checkmark : .none
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .value:
            let cell = tableView.cellForRow(at: indexPath) as! FloatInputCell
            cell.startEditing()
        case .unit:
            let unit = MeasureUnit.allCases[indexPath.row]
            valueWithUnit.unit = unit
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func didChange(value: CGFloat, forCell cell: FloatInputCell) {
        valueWithUnit.value = value
    }

}

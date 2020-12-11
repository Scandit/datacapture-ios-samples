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
import ScanditBarcodeCapture

class SettingsTableViewController: UITableViewController, DataSourceDelegate {

    var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()

        setupDataSource()
    }

    func registerCells() {
        tableView.register(BasicCell.self)
        tableView.register(SwitchCell.self)
        tableView.register(FloatInputCell.self)
        tableView.registerNib(SliderCell.self)
    }

    func setupDataSource() {
        fatalError("Should be implemented by subclass")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource.sections.row(forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellClass.reuseIdentifier, for: indexPath)

        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.detailText
        cell.accessoryType = row.accessory

        if let cell = cell as? SwitchCell {
            cell.delegate = self
            cell.isOn = row.getValue!() as! Bool
        }

        if let cell = cell as? FloatInputCell {
            cell.delegate = self
            cell.value = row.getValue!() as! CGFloat
        }

        if let cell = cell as? SliderCell, case .slider(let min, let max, let decimalPlaces) = row.kind {
            cell.delegate = self
            cell.minimumValue = min
            cell.maximumValue = max
            cell.maximumNumberOfDecimalPlaces = decimalPlaces
            cell.value = row.getValue!() as! CGFloat
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = dataSource.sections[indexPath.section].rows[indexPath.row]
        row.didSelect?(row, indexPath)

        if let cell = tableView.cellForRow(at: indexPath) as? FloatInputCell {
            cell.startEditing()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsTableViewController {
    func didChangeData() {
        tableView.reloadData()
    }

    func getFloatWithUnit(title: String?, currentValue: FloatWithUnit, completion: @escaping (FloatWithUnit) -> Void) {
        navigationController?.pushViewController(FloatWithUnitChooserViewController(title: title,
                                                                                    value: currentValue,
                                                                                    didChooseValue: completion),
                                                 animated: true)
    }

    func presentChoice<Choice: CustomStringConvertible>(title: String?,
                                                        options: [Choice],
                                                        chosen: Choice,
                                                        didChooseValue: @escaping (Choice) -> Void) {
        navigationController?.pushViewController(ChoiceViewController(title: title,
                                                                      options: options,
                                                                      chosen: chosen,
                                                                      didChooseValue: didChooseValue),
                                                 animated: true)
    }

    func presentSymbologySettings(currentSettings: SymbologySettings,
                                  didChangeValue: @escaping (SymbologySettings) -> Void) {
        navigationController?.pushViewController(SymbologySettingsViewController(symbologySettings: currentSettings,
                                                                                 didChangeValue: didChangeValue),
                                                 animated: true)
    }
}

extension SettingsTableViewController: SwitchCellDelegate {
    func didChange(value: Bool, forSwitchCell switchCell: SwitchCell) {
        let indexPath = tableView.indexPath(for: switchCell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value)
    }
}

extension SettingsTableViewController: FloatInputCellDelegate {
    func didChange(value: CGFloat, forCell cell: FloatInputCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value)
    }
}

extension SettingsTableViewController: SliderCellDelegate {
    func didChange(value: CGFloat, forCell cell: SliderCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value)
    }
}

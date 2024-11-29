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
import ScanditCaptureCore

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
        tableView.register(SubtitledSwitchCell.self)
        tableView.register(FloatInputCell.self)
        tableView.registerNib(SliderCell.self)
        tableView.register(TextEditCell.self)
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

        if let cell = cell as? SubtitledSwitchCell {
            cell.detailTextLabel?.numberOfLines = 0
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

        if let cell = cell as? TextEditCell {
            cell.delegate = self
            cell.value = row.getValue!() as! String
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

    // MARK: - Data source delegate

    func didChangeData() {
        tableView.reloadData()
    }

    func didChangeData(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
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

    func presentTextEdit(title: String?, currentValue: String, completion: @escaping (String) -> Void) {
        let popup = UIAlertController(title: title, message: "", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.text = currentValue
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            completion(popup.textFields![0].text.valueOrEmpty)
        }
        popup.addAction(cancelAction)
        popup.addAction(saveAction)
        navigationController?.present(popup, animated: true)
    }

    func present(viewController: () -> UIViewController) {
        navigationController?.pushViewController(viewController(),
                                                 animated: true)
    }
}

extension SettingsTableViewController: SwitchCellDelegate {
    func didChange(value: Bool, forSwitchCell switchCell: SwitchCell) {
        let indexPath = tableView.indexPath(for: switchCell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value, row, indexPath)
    }
}

extension SettingsTableViewController: FloatInputCellDelegate {
    func didChange(value: CGFloat, forCell cell: FloatInputCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value, row, indexPath)
    }
}

extension SettingsTableViewController: TextEditCellDelegate {
    func didChange(value: String, forCell cell: TextEditCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value, row, indexPath)
    }
}

extension SettingsTableViewController: SliderCellDelegate {
    func didChange(value: CGFloat, forCell cell: SliderCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let row = dataSource.sections.row(forIndexPath: indexPath)
        row.didChangeValue!(value, row, indexPath)
    }
}

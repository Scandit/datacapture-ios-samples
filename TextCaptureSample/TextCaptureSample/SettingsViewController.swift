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

protocol SettingsViewControllerDelegate: AnyObject {
    func didCancel()
    func didChangeSettings(_ settings: Settings)
}

class SettingsViewController: UITableViewController {

    private struct Constants {
        static let modeSection = 0
        static let scanPositionSection = 1
    }

    var settings: Settings!
    weak var delegate: SettingsViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let currentModeCell = tableView.cellForRow(at: IndexPath(row: settings.mode.rawValue,
                                                                 section: Constants.modeSection))
        currentModeCell?.accessoryType = .checkmark

        let currentScanPositionCell = tableView.cellForRow(at: IndexPath(row: settings.scanPosition.rawValue,
                                                                         section: Constants.scanPositionSection))
        currentScanPositionCell?.accessoryType = .checkmark
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let numberOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        for i in 0..<numberOfRowsInSection {
            guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section)) else { continue }
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark
    }

    @IBAction func cancel(_ sender: Any) {
        delegate?.didCancel()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        // Find selected value in Mode section
        var mode: Settings.Mode!
        let numberOfRowsInModeSection = tableView.numberOfRows(inSection: Constants.modeSection)
        for i in 0..<numberOfRowsInModeSection {
            guard let cell = tableView.cellForRow(at: IndexPath(row: i,
                                                                section: Constants.modeSection)) else { continue }
            if cell.accessoryType == .checkmark {
                mode = Settings.Mode(rawValue: i)!
            }
        }

        // Find selected value in ScanPosition section
        var scanPosition: Settings.ScanPosition!
        let numberOfRowsInScanPositionSection = tableView.numberOfRows(inSection: Constants.scanPositionSection)
        for i in 0..<numberOfRowsInScanPositionSection {
            let indexPath = IndexPath(row: i,
                                      section: Constants.scanPositionSection)
            guard let cell = tableView.cellForRow(at: indexPath) else { continue }

            if cell.accessoryType == .checkmark {
                scanPosition = Settings.ScanPosition(rawValue: i)!
            }
        }

        // Create new Settings
        settings = Settings(mode: mode, scanPosition: scanPosition)

        delegate?.didChangeSettings(settings)
        dismiss(animated: true, completion: nil)
    }
}

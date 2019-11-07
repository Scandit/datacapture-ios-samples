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

import ScanditBarcodeCapture

class SymbologySettingsViewController: SettingsTableViewController {

    let didChangeValue: (SymbologySettings) -> Void
    let settings: SymbologySettings

    init(symbologySettings: SymbologySettings, didChangeValue: @escaping (SymbologySettings) -> Void) {
        self.settings = symbologySettings
        self.didChangeValue = didChangeValue
        super.init(style: .grouped)
        self.title = symbologySettings.symbology.readableName
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupDataSource() {
        dataSource = SymbologySettingsDataSource(delegate: self, symbologySettings: settings)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didChangeValue(settings)
    }

}

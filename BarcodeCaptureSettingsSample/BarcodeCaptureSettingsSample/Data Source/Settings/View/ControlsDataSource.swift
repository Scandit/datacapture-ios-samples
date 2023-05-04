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

import ScanditCaptureCore

class ControlsDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        var sections = [
            Section(rows: [
                Row.init(title: "Torch Button",
                         kind: .switch,
                         getValue: { SettingsManager.current.torchSwitchShown },
                         didChangeValue: { SettingsManager.current.torchSwitchShown = $0 })
            ]),
            Section(rows: [
                Row.init(title: "Camera Switch Button",
                         kind: .switch,
                         getValue: { SettingsManager.current.cameraSwitchShown },
                         didChangeValue: { SettingsManager.current.cameraSwitchShown = $0 })
            ]),
            Section(rows: [
                Row.init(title: "Zoom Switch Button",
                         kind: .switch,
                         getValue: { SettingsManager.current.zoomSwitchShown },
                         didChangeValue: { SettingsManager.current.zoomSwitchShown = $0 })
            ])
        ]
        if Camera.isMacroModeAvailable {
            sections.append(
                Section(rows: [
                    Row.init(title: "Macro Mode Button",
                             kind: .switch,
                             getValue: { SettingsManager.current.macroModeSwitchShown },
                             didChangeValue: { SettingsManager.current.macroModeSwitchShown = $0 })
                ])
            )
        }
        return sections
    }()
}

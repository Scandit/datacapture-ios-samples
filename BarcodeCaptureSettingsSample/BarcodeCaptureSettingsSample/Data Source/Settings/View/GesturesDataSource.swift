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

class GesturesDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        return [
            Section(rows: [
                Row(title: "Tap to Focus",
                    kind: .switch,
                    getValue: { SettingsManager.current.tapToFocus },
                    didChangeValue: { SettingsManager.current.tapToFocus = $0 }),
                Row(title: "Swipe to Zoom",
                    kind: .switch,
                    getValue: { SettingsManager.current.swipeToZoom },
                    didChangeValue: { SettingsManager.current.swipeToZoom = $0 })
            ])]
    }()
}

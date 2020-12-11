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

class ScanAreaDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        return [margins, guide]
    }()

    lazy var margins: Section = {
        return Section(title: "Margins", rows: [
            Row.valueWithUnit(title: "Top",
                              getValue: { SettingsManager.current.scanAreaMargins.top },
                              didChangeValue: { SettingsManager.current.scanAreaMargins.top = $0 },
                              dataSourceDelegate: self.delegate),
            Row.valueWithUnit(title: "Right",
                              getValue: { SettingsManager.current.scanAreaMargins.right },
                              didChangeValue: { SettingsManager.current.scanAreaMargins.right = $0 },
                              dataSourceDelegate: self.delegate),
            Row.valueWithUnit(title: "Bottom",
                              getValue: { SettingsManager.current.scanAreaMargins.bottom },
                              didChangeValue: { SettingsManager.current.scanAreaMargins.bottom = $0 },
                              dataSourceDelegate: self.delegate),
            Row.valueWithUnit(title: "Left",
                              getValue: { SettingsManager.current.scanAreaMargins.left },
                              didChangeValue: { SettingsManager.current.scanAreaMargins.left = $0 },
                              dataSourceDelegate: self.delegate)])
    }()

    lazy var guide: Section = {
        return Section(rows: [
            Row(title: "Should Show Scan Area Guides",
                kind: .switch,
                getValue: { SettingsManager.current.shouldShowScanAreaGuides },
                didChangeValue: { value in SettingsManager.current.shouldShowScanAreaGuides = value })])
    }()

}

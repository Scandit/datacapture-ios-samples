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

class ModePointOfInterestDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    var sections: [Section] {
        if SettingsManager.current.modePointOfInterest == .null {
            return [enabled]
        }
        return [enabled, coordinates]
    }

    lazy var enabled: Section = {
        Section(title: "Enable Barcode Selection Point of Interest", rows: [
            Row(title: "Enable",
                          kind: .switch,
                          getValue: {
                            !SettingsManager.current.modePointOfInterest.isNull
                          },
                          didChangeValue: {
                            if !$0 {
                                SettingsManager.current.modePointOfInterest = .null
                            } else {
                                // Set the capture mode PoI as the capture view PoI
                                SettingsManager.current.modePointOfInterest =
                                    SettingsManager.current.pointOfInterest
                            }
                            self.delegate?.didChangeData()
                          })
        ])
    }()

    lazy var coordinates: Section = {
        Section(rows: [
            Row.valueWithUnit(title: "X",
                              getValue: { SettingsManager.current.modePointOfInterest.x },
                              didChangeValue: {
                                SettingsManager.current.modePointOfInterest.x = $0
                              },
                              dataSourceDelegate: self.delegate),
            Row.valueWithUnit(title: "Y",
                              getValue: { SettingsManager.current.modePointOfInterest.y },
                              didChangeValue: {
                                SettingsManager.current.modePointOfInterest.y = $0
                              },
                              dataSourceDelegate: self.delegate)])
    }()
}

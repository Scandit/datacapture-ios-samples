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

enum HapticAndVibration: CustomStringConvertible, CaseIterable {
    case noVibration
    case defaultVibration
    case selectionHapticFeedback
    case successHapticFeedback

    var description: String {
        switch self {
        case .noVibration:
            return "No Vibration"
        case .defaultVibration:
            return "Default Vibration"
        case .selectionHapticFeedback:
            return "Selection Haptic Feedback"
        case .successHapticFeedback:
            return "Success Haptic Feedback"
        }
    }

    var sdcVibration: Vibration? {
        switch self {
        case .noVibration:
            return nil
        case .defaultVibration:
            return Vibration.default
        case .selectionHapticFeedback:
            return Vibration.selectionHapticFeedback
        case .successHapticFeedback:
            return Vibration.successHapticFeedback
        }
    }
}

class FeedbackDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        let sound = Row(title: "Sound",
                      kind: .switch,
                      getValue: { SettingsManager.current.sound != nil },
                      didChangeValue: { value in
                        let vibration = SettingsManager.current.hapticAndVibration.sdcVibration
                        if value {
                            SettingsManager.current.sound = BarcodeSelectionFeedback.default.selection.sound
                        } else {
                            SettingsManager.current.sound = nil
                        }
                      })
        let vibration = Row.choice(title: "Vibration",
                   options: HapticAndVibration.allCases,
                   getValue: { SettingsManager.current.hapticAndVibration },
                   didChangeValue: {
                    SettingsManager.current.hapticAndVibration = $0
                   },
                   dataSourceDelegate: self.delegate)
        return [Section(rows: [sound, vibration])]
    }()
}

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

class FeedbackDataSource: DataSource {

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        let row = Row(title: "Sound",
                      kind: .switch,
                      getValue: { SettingsManager.current.feedback.sound != nil },
                      didChangeValue: { value in
                        if value {
                            SettingsManager.current.feedback = BarcodeSelectionFeedback.default.selection
                        } else {
                            SettingsManager.current.feedback = Feedback(vibration: nil, sound: nil)
                        }
                      })
        return [Section(rows: [row])]
    }()
}

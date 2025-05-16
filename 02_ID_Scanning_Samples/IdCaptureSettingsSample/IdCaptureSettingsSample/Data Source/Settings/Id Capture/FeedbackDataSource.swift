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

import ScanditIdCapture

class FeedbackDataSource: DataSource {

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections
    lazy var sections: [Section] = {
        [
            Section(
                title: "ID Captured Feedback",
                rows: [
                    Row(
                        title: "Sound",
                        kind: .switch,
                        getValue: { SettingsManager.current.idCapturedFeedback.sound != nil },
                        didChangeValue: { value, _, _ in
                            SettingsManager.current.idCapturedFeedback =
                                Feedback(
                                    vibration: SettingsManager.current.idCapturedFeedback.vibration,
                                    sound: value ? IdCaptureFeedback.default.idCaptured.sound : nil
                                )
                        }
                    ),

                    Row(
                        title: "Vibration",
                        kind: .switch,
                        getValue: { SettingsManager.current.idCapturedFeedback.vibration != nil },
                        didChangeValue: { value, _, _ in
                            SettingsManager.current.idCapturedFeedback =
                                Feedback(
                                    vibration: value ? IdCaptureFeedback.default.idCaptured.vibration : nil,
                                    sound: SettingsManager.current.idCapturedFeedback.sound
                                )

                        }
                    ),
                ]
            ),
            Section(
                title: "ID Rejected Feedback",
                rows: [
                    Row(
                        title: "Sound",
                        kind: .switch,
                        getValue: { SettingsManager.current.idRejectedFeedback.sound != nil },
                        didChangeValue: { value, _, _ in
                            SettingsManager.current.idRejectedFeedback =
                                Feedback(
                                    vibration: SettingsManager.current.idRejectedFeedback.vibration,
                                    sound: value ? IdCaptureFeedback.defaultFailureSound : nil
                                )
                        }
                    ),

                    Row(
                        title: "Vibration",
                        kind: .switch,
                        getValue: { SettingsManager.current.idRejectedFeedback.vibration != nil },
                        didChangeValue: { value, _, _ in
                            SettingsManager.current.idRejectedFeedback =
                                Feedback(
                                    vibration: value ? Vibration.failureHapticFeedback : nil,
                                    sound: SettingsManager.current.idRejectedFeedback.sound
                                )

                        }
                    ),
                ]
            ),
        ]
    }()
}

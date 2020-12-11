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

class CameraDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        guard Camera.default != nil else {
            return [Section(title: "No camera available", rows: [])]
        }
        return [position, torch, cameraSettings]
    }()

    // MARK: Section: Camera Position

    lazy var position: Section = {
        var rows = [Row]()

        if let worldFacingCamera = Camera(position: .worldFacing) {
            rows.append(Row.option(title: "World Facing",
                                   getValue: { SettingsManager.current.camera == worldFacingCamera },
                                   didSelect: { _, _ in SettingsManager.current.camera = worldFacingCamera },
                                   dataSourceDelegate: self.delegate))
        }

        if let userFacingCamera = Camera(position: .userFacing) {
            rows.append(Row.option(title: "User Facing",
                                   getValue: { SettingsManager.current.camera == userFacingCamera },
                                   didSelect: { _, _ in SettingsManager.current.camera = userFacingCamera },
                                   dataSourceDelegate: self.delegate))
        }

        return Section(title: "Camera Position", rows: rows)
    }()

    // MARK: Section: Other Camera Properties

    lazy var torch: Section = {
        return Section(rows: [
            Row(title: "Desired Torch State",
                kind: .switch,
                getValue: { SettingsManager.current.torchState == .on },
                didChangeValue: { SettingsManager.current.torchState = $0 ? .on : .off })])
    }()

    // MARK: Section: Camera Settings

    lazy var cameraSettings: Section = {
        return Section(title: "Camera Settings",
                       rows: [
                        Row.choice(title: "Preferred Resolution",
                                   options: VideoResolution.allCases,
                                   getValue: { SettingsManager.current.preferredResolution },
                                   didChangeValue: { SettingsManager.current.preferredResolution = $0 },
                                   dataSourceDelegate: self.delegate),
                        Row(title: "Zoom Factor",
                            kind: .slider(minimum: 1, maximum: 20, decimalPlaces: 1),
                            getValue: { SettingsManager.current.zoomFactor },
                            didChangeValue: { SettingsManager.current.zoomFactor = $0 }),
                        Row.choice(title: "Focus Range",
                                   options: FocusRange.allCases,
                                   getValue: { SettingsManager.current.focusRange },
                                   didChangeValue: { SettingsManager.current.focusRange = $0 },
                                   dataSourceDelegate: self.delegate)
            ])
    }()
}

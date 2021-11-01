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

import ScanditIdCapture

class SettingsManager {
    static let current = SettingsManager()

    var isContinuousModeEnabled = false

    var context: DataCaptureContext
    var idCaptureSettings: IdCaptureSettings
    var idCapture: IdCapture
    weak var idCaptureListener: IdCaptureListener?

    var captureView: DataCaptureView! {
        didSet {
            // Add an ID capture overlay to the data capture view to render the location
            // of captured IDs on top of the video preview.
            // This is optional, but recommended for better visual feedback.
            overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        }
    }

    var overlay: IdCaptureOverlay!

    var internalCamera: Camera? = Camera.default
    var internalTorchState: TorchState = .off
    // Use the recommended camera settings for the IdCapture mode.
    var cameraSettings: CameraSettings = IdCapture.recommendedCameraSettings
    var internalTorchSwitch: TorchSwitchControl = TorchSwitchControl()

    init() {
        // The ID capturing process is configured through ID capture settings
        // and are then applied to the ID capture instance that manages ID recognition.
        idCaptureSettings = IdCaptureSettings()

        // Create data capture context using your license key and set the camera as the frame source.
        context = DataCaptureContext.licensed
        context.setFrameSource(internalCamera, completionHandler: nil)

        // Create new ID capture mode with the settings from above.
        idCapture = IdCapture(context: context, settings: idCaptureSettings)

        // Make sure that references to some settings are actually the current settings
        internalCamera?.apply(cameraSettings, completionHandler: nil)
        internalCamera?.desiredTorchState = internalTorchState
    }

    func configure() {
        context.removeAllModes()
        if let listener = idCaptureListener {
            idCapture.removeListener(listener)
        }
        if overlay != nil {
            captureView?.removeOverlay(overlay)
        }

        idCapture = IdCapture(context: context, settings: idCaptureSettings)
        if let listener = idCaptureListener {
            idCapture.addListener(listener)
        }

        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        overlay.idLayoutStyle = idLayoutStyle
        overlay.idLayoutLineStyle = idLayoutLineStyle
        overlay.capturedBrush = capturedBrush
    }

    // MARK: - View

    // MARK: Controls

    var torchSwitchShown: Bool = false {
        didSet {
            if torchSwitchShown {
                captureView.addControl(internalTorchSwitch)
            } else {
                captureView.removeControl(internalTorchSwitch)
            }
        }
    }

    // MARK: Overlay

    var idLayoutStyle: IdLayoutStyle = .rounded {
        didSet {
            overlay.idLayoutStyle = idLayoutStyle
        }
    }

    var idLayoutLineStyle: IdLayoutLineStyle = .bold {
        didSet {
            overlay.idLayoutLineStyle = idLayoutLineStyle
        }
    }

    var capturedBrush: Brush = IdCaptureOverlay.defaultCapturedBrush {
        didSet {
            overlay.capturedBrush = capturedBrush
        }
    }
}

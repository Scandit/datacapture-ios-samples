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

extension SettingsManager {
    var camera: Camera? {
        get {
            return internalCamera
        }
        set {
            // ⚠️ The new camera might be nil, e.g. the device doesn't have a specific or any camera
            internalCamera = newValue

            internalCamera?.apply(cameraSettings, completionHandler: nil)
            context.setFrameSource(internalCamera, completionHandler: nil)
        }
    }

    var torchState: TorchState {
        get {
            return internalTorchState
        }
        set {
            internalTorchState = newValue

            camera?.desiredTorchState = internalTorchState
        }
    }

    var preferredResolution: VideoResolution {
        get {
            return cameraSettings.preferredResolution
        }
        set {
            cameraSettings.preferredResolution = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

    var focusRange: FocusRange {
        get {
            return cameraSettings.focusRange
        }
        set {
            cameraSettings.focusRange = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

    var zoomFactor: CGFloat {
        get {
            return cameraSettings.zoomFactor
        }
        set {
            cameraSettings.zoomFactor = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

    var zoomGestureZoomFactor: CGFloat {
        get {
            return cameraSettings.zoomGestureZoomFactor
        }
        set {
            cameraSettings.zoomGestureZoomFactor = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

    var focusGestureStrategy: FocusGestureStrategy {
        get {
            return cameraSettings.focusGestureStrategy
        }
        set {
            cameraSettings.focusGestureStrategy = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

}

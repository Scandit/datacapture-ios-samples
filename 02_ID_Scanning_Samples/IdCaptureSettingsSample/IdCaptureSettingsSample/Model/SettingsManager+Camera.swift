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

import ScanditCaptureCore

extension SettingsManager {
    var camera: Camera? {
        get {
            internalCamera
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
            camera?.desiredTorchState ?? .off
        }
        set {
            camera?.desiredTorchState = newValue
        }
    }

    var preferredResolution: VideoResolution {
        get {
            cameraSettings.preferredResolution
        }
        set {
            cameraSettings.preferredResolution = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

    var focusRange: FocusRange {
        get {
            cameraSettings.focusRange
        }
        set {
            cameraSettings.focusRange = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

    var focusGestureStrategy: FocusGestureStrategy {
        get {
            cameraSettings.focusGestureStrategy
        }
        set {
            cameraSettings.focusGestureStrategy = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
        }
    }

}

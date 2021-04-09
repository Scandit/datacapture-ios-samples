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

class SettingsManager {
    static let current = SettingsManager()

    var isContinuousModeEnabled = false

    var context: DataCaptureContext
    var barcodeCaptureSettings: BarcodeCaptureSettings
    var barcodeCapture: BarcodeCapture

    var captureView: DataCaptureView! {
        didSet {
            // Add a barcode capture overlay to the data capture view to render the location
            // of captured barcodes on top of the video preview.
            // This is optional, but recommended for better visual feedback.
            overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, view: captureView)
        }
    }

    var overlay: BarcodeCaptureOverlay!

    var defaultBrush: Brush!

    var internalCamera: Camera? = Camera.default
    var internalTorchState: TorchState = .off
    // Use the recommended camera settings for the BarcodeCapture mode.
    var cameraSettings: CameraSettings = BarcodeCapture.recommendedCameraSettings
    var internalTorchSwitch: TorchSwitchControl = TorchSwitchControl()
    var internalVibration = FeedbackVibration.default

    init() {
        // The barcode capturing process is configured through barcode capture settings  
        // and are then applied to the barcode capture instance that manages barcode recognition.
        barcodeCaptureSettings = BarcodeCaptureSettings()

        // Create data capture context using your license key and set the camera as the frame source.
        context = DataCaptureContext.licensed
        context.setFrameSource(internalCamera, completionHandler: nil)

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: barcodeCaptureSettings)

        defaultBrush = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture).brush

        // Make sure that references to some settings are actually the current settings
        internalCamera?.apply(cameraSettings, completionHandler: nil)
        internalCamera?.desiredTorchState = internalTorchState
    }

    // MARK: - View

    // MARK: Viewfinder

    var viewfinder: Viewfinder? {
        get {
            return overlay.viewfinder
        }
        set {
            overlay.viewfinder = newValue
            if let rectangular = newValue as? RectangularViewfinder {
                switch rectangular.sizeWithUnitAndAspect.sizingMode {
                case .widthAndHeight:
                    let widthAndHeight = rectangular.sizeWithUnitAndAspect.widthAndHeight
                    rectangularWidth = widthAndHeight.width
                    rectangularHeight = widthAndHeight.height
                case .widthAndAspectRatio:
                    rectangularWidthAspect = rectangular.sizeWithUnitAndAspect.widthAndAspectRatio.aspect
                case .heightAndAspectRatio:
                    rectangularHeightAspect = rectangular.sizeWithUnitAndAspect.heightAndAspectRatio.aspect
                }
            }
        }
    }

    func setViewfinderSize() {
        guard let viewfinder = viewfinder as? RectangularViewfinder else { return }
        switch viewfinderSizeSpecification {
        case .widthAndHeight:
            viewfinder.setSize(SizeWithUnit(width: rectangularWidth, height: rectangularHeight))
        case .widthAndHeightAspect:
            viewfinder.setWidth(rectangularWidth, aspectRatio: rectangularHeightAspect)
        case .heightAndWidthAspect:
            viewfinder.setHeight(rectangularHeight, aspectRatio: rectangularWidthAspect)
        }
    }

    lazy var defaultRectangularViewfinderColor = RectangularViewfinder().color

    /// Note: RectangularViewfinderColor is not part of the SDK, see RectangularViewfinderColor.swift
    var rectangularViewfinderColor: RectangularViewfinderColor = .default {
        didSet {
            (viewfinder as? RectangularViewfinder)?.color = rectangularViewfinderColor.uiColor
        }
    }

    lazy var defaultLaserlineViewfinderEnabledColor = LaserlineViewfinder().enabledColor

    /// Note: LaserlineViewfinderEnabledColor is not part of the SDK, see LaserlineViewfinderEnabledColor.swift
    var laserlineViewfinderEnabledColor: LaserlineViewfinderEnabledColor = .default {
        didSet {
            (viewfinder as? LaserlineViewfinder)?.enabledColor = laserlineViewfinderEnabledColor.uiColor
        }
    }

    lazy var defaultLaserlineViewfinderDisabledColor = LaserlineViewfinder().disabledColor

    /// Note: LaserlineViewfinderDisabledColor is not part of the SDK, see LaserlineViewfinderDisabledColor.swift
    var laserlineViewfinderDisabledColor: LaserlineViewfinderDisabledColor = .default {
        didSet {
            (viewfinder as? LaserlineViewfinder)?.disabledColor = laserlineViewfinderDisabledColor.uiColor
        }
    }

    lazy var defaultAimerViewfinderFrameColor = AimerViewfinder().frameColor

    /// Note: AimerViewfinderFrameColor is not part of the SDK, see LaserlineViewfinderDisabledColor.swift
    var aimerViewfinderFrameColor: AimerViewfinderFrameColor = .default {
        didSet {
            (viewfinder as? AimerViewfinder)?.frameColor = aimerViewfinderFrameColor.uiColor
        }
    }

    lazy var defaultAimerViewfinderDotColor = AimerViewfinder().dotColor

    /// Note: AimerViewfinderDotColor is not part of the SDK, see LaserlineViewfinderDisabledColor.swift
    var aimerViewfinderDotColor: AimerViewfinderDotColor = .default {
        didSet {
            (viewfinder as? AimerViewfinder)?.dotColor = aimerViewfinderDotColor.uiColor
        }
    }

    var viewfinderSizeSpecification: RectangularSizeSpecification = .widthAndHeight

    var rectangularWidth: FloatWithUnit = .zero {
        didSet {
            setViewfinderSize()
        }
    }

    var rectangularHeight: FloatWithUnit = .zero {
        didSet {
            setViewfinderSize()
        }
    }

    var rectangularWidthAspect: CGFloat = 0 {
        didSet {
            setViewfinderSize()
        }
    }

    var rectangularHeightAspect: CGFloat = 0 {
        didSet {
            setViewfinderSize()
        }
    }

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
}

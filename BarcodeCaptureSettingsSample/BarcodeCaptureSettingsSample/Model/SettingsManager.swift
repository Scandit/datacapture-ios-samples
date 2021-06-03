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
        }
    }

    var laserlineStyle: LaserlineViewfinderStyle {
        get {
            (viewfinder as! LaserlineViewfinder).style
        }
        set {
            viewfinder = LaserlineViewfinder(style: newValue)
        }
    }

    var rectangularStyle: RectangularViewfinderStyle {
        get {
            (viewfinder as! RectangularViewfinder).style
        }
        set {
            viewfinder = RectangularViewfinder(style: newValue)
        }
    }

    var rectangularLineStyle: RectangularViewfinderLineStyle {
        get {
            (viewfinder as! RectangularViewfinder).lineStyle
        }
        set {
            viewfinder = RectangularViewfinder(style: rectangularStyle, lineStyle: newValue)
        }
    }

    var rectangularDimming: CGFloat {
        get {
            (viewfinder as! RectangularViewfinder).dimming
        }
        set {
            (viewfinder as! RectangularViewfinder).dimming = newValue
        }
    }

    lazy var defaultRectangularViewfinderColor = RectangularViewfinder().color
    lazy var defaultRectangularViewfinderDisabledColor = RectangularViewfinder().disabledColor

    /// Note: RectangularViewfinderColor is not part of the SDK, see RectangularViewfinderColor.swift
    var rectangularViewfinderColor: RectangularViewfinderColor {
        get {
            let color = (viewfinder as! RectangularViewfinder).color
            return RectangularViewfinderColor(color: color)
        }
        set {
            (viewfinder as! RectangularViewfinder).color = newValue.uiColor
        }
    }

    /// Note: RectangularViewfinderDisabledColor is not part of the SDK, see RectangularViewfinderColor.swift
    var rectangularViewfinderDisabledColor: RectangularViewfinderDisabledColor {
        get {
            let color = (viewfinder as! RectangularViewfinder).disabledColor
            return RectangularViewfinderDisabledColor(color: color)
        }
        set {
            (viewfinder as! RectangularViewfinder).disabledColor = newValue.uiColor
        }
    }

    var rectangularAnimation: RectangularViewfinderAnimation? {
        get {
            (viewfinder as! RectangularViewfinder).animation
        }
        set {
            (viewfinder as! RectangularViewfinder).animation = newValue
        }
    }

    lazy var defaultLaserlineViewfinderEnabledColor = LaserlineViewfinder().enabledColor

    /// Note: LaserlineViewfinderEnabledColor is not part of the SDK, see LaserlineViewfinderEnabledColor.swift
    var laserlineViewfinderEnabledColor: LaserlineViewfinderEnabledColor {
        get {
            let color = (viewfinder as! LaserlineViewfinder).enabledColor
            return LaserlineViewfinderEnabledColor(color: color)
        }
        set {
            (viewfinder as! LaserlineViewfinder).enabledColor = newValue.uiColor
        }
    }

    lazy var defaultLaserlineViewfinderDisabledColor = LaserlineViewfinder().disabledColor

    /// Note: LaserlineViewfinderDisabledColor is not part of the SDK, see LaserlineViewfinderDisabledColor.swift
    var laserlineViewfinderDisabledColor: LaserlineViewfinderDisabledColor {
        get {
            let color = (viewfinder as! LaserlineViewfinder).disabledColor
            return LaserlineViewfinderDisabledColor(color: color)
        }
        set {
            (viewfinder as! LaserlineViewfinder).disabledColor = newValue.uiColor
        }
    }

    lazy var defaultAimerViewfinderFrameColor = AimerViewfinder().frameColor

    /// Note: AimerViewfinderFrameColor is not part of the SDK, see LaserlineViewfinderDisabledColor.swift
    var aimerViewfinderFrameColor: AimerViewfinderFrameColor {
        get {
            let color = (viewfinder as! AimerViewfinder).frameColor
            return AimerViewfinderFrameColor(color: color)
        }
        set {
            (viewfinder as! AimerViewfinder).frameColor = newValue.uiColor
        }
    }

    lazy var defaultAimerViewfinderDotColor = AimerViewfinder().dotColor

    /// Note: AimerViewfinderDotColor is not part of the SDK, see LaserlineViewfinderDisabledColor.swift
    var aimerViewfinderDotColor: AimerViewfinderDotColor {
        get {
            let color = (viewfinder as! AimerViewfinder).dotColor
            return AimerViewfinderDotColor(color: color)
        }
        set {
            (viewfinder as! AimerViewfinder).dotColor = newValue.uiColor
        }
    }

    var viewfinderSizeSpecification: RectangularSizeSpecification = .widthAndHeight {
        didSet {
            /// Update the viewfinder when we update the size specification.
            let rectangular = viewfinder as! RectangularViewfinder
            switch viewfinderSizeSpecification {
            case .widthAndHeight:
                let widthAndHeight = rectangular.sizeWithUnitAndAspect.widthAndHeight
                rectangularWidthAndHeight = widthAndHeight
            case .widthAndHeightAspect:
                rectangularWidthAndAspectRatio = rectangular.sizeWithUnitAndAspect.widthAndAspectRatio
            case .heightAndWidthAspect:
                rectangularHeightAndAspectRatio = rectangular.sizeWithUnitAndAspect.heightAndAspectRatio
            case .shorterDimensionAndAspect:
                rectangularShorterDimensionAndAspectRatio =
                    (rectangular.sizeWithUnitAndAspect.shorterDimensionAndAspectRatio.size.value,
                     rectangular.sizeWithUnitAndAspect.shorterDimensionAndAspectRatio.aspect)
            }
        }
    }

    var rectangularWidthAndHeight: SizeWithUnit {
        get {
            let sizeWithUnitAndAspect = (viewfinder as! RectangularViewfinder).sizeWithUnitAndAspect
            return sizeWithUnitAndAspect.widthAndHeight
        }
        set {
            let rectangular = viewfinder as! RectangularViewfinder
            rectangular.setSize(newValue)
        }
    }

    var rectangularWidthAndAspectRatio: SizeWithAspect {
        get {
            let sizeWithUnitAndAspect = (viewfinder as! RectangularViewfinder).sizeWithUnitAndAspect
            return sizeWithUnitAndAspect.widthAndAspectRatio
        }
        set {
            let rectangular = viewfinder as! RectangularViewfinder
            rectangular.setWidth(newValue.size, aspectRatio: newValue.aspect)
        }
    }

    var rectangularHeightAndAspectRatio: SizeWithAspect {
        get {
            let sizeWithUnitAndAspect = (viewfinder as! RectangularViewfinder).sizeWithUnitAndAspect
            return sizeWithUnitAndAspect.heightAndAspectRatio
        }
        set {
            let rectangular = viewfinder as! RectangularViewfinder
            rectangular.setWidth(newValue.size, aspectRatio: newValue.aspect)
        }
    }

    var rectangularShorterDimensionAndAspectRatio: (CGFloat, CGFloat) {
        get {
            let sizeWithUnitAndAspect = (viewfinder as! RectangularViewfinder).sizeWithUnitAndAspect
            return (sizeWithUnitAndAspect.shorterDimensionAndAspectRatio.size.value,
                    sizeWithUnitAndAspect.shorterDimensionAndAspectRatio.aspect)
        }
        set {
            let rectangular = viewfinder as! RectangularViewfinder
            rectangular.setShorterDimension(newValue.0,
                                            aspectRatio: newValue.1)
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

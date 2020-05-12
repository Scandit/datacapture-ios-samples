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

    private var internalCamera: Camera? = Camera.default
    private var internalTorchState: TorchState = .off
    // Use the recommended camera settings for the BarcodeCapture mode.
    private var cameraSettings: CameraSettings = BarcodeCapture.recommendedCameraSettings
    private var internalTorchSwitch: TorchSwitchControl = TorchSwitchControl()

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

    // MARK: - Barcode Capture

    // MARK: Symbologies

    var anySymbologyEnabled: Bool {
        return !barcodeCaptureSettings.enabledSymbologyValues.isEmpty
    }

    func setAllSymbologies(enabled: Bool) {
        if enabled {
            let allSymbologies = Set(Symbology.allCases.map { NSNumber(value: $0.rawValue) })
            barcodeCaptureSettings.enableSymbologies(allSymbologies)
        } else {
            barcodeCaptureSettings.enabledSymbologyValues.forEach { symbologyValue in
                let symbology = Symbology(rawValue: symbologyValue.uintValue)!
                barcodeCaptureSettings.set(symbology: symbology, enabled: false)
            }
        }
        barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
    }

    func isSymbologyEnabled(_ symbology: Symbology) -> Bool {
        return barcodeCaptureSettings.enabledSymbologyValues.contains(NSNumber(value: symbology.rawValue))
    }

    func getSymbologySettings(for symbology: Symbology) -> SymbologySettings {
        return barcodeCaptureSettings.settings(for: symbology)
    }

    func symbologySettingsChanged() {
        // Apply barcode capture settings, which includes symbology settings that might've
        // been potentially updated
        return barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
    }

    // MARK: Feedback

    var feedback: Feedback {
        get {
            return barcodeCapture.feedback.success
        }
        set {
            barcodeCapture.feedback.success = newValue
        }
    }

    // MARK: Location Selection

    var locationSelection: LocationSelection? {
        get {
            return barcodeCaptureSettings.locationSelection
        }
        set {
            barcodeCaptureSettings.locationSelection = newValue
            barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
        }
    }

    // MARK: - Camera

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

    var maxFrameRate: CGFloat {
        get {
            return cameraSettings.maxFrameRate
        }
        set {
            cameraSettings.maxFrameRate = newValue
            camera?.apply(cameraSettings, completionHandler: nil)
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

    // MARK: - View

    // MARK: Scan Area

    var scanAreaMargins: MarginsWithUnit {
        get {
            return captureView.scanAreaMargins
        }
        set {
            captureView.scanAreaMargins = newValue
        }
    }

    var shouldShowScanAreaGuides: Bool {
        get {
            return overlay.shouldShowScanAreaGuides
        }
        set {
            overlay.shouldShowScanAreaGuides = newValue
        }
    }

    // MARK: Point of Interest

    var pointOfInterest: PointWithUnit {
        get {
            return captureView.pointOfInterest
        }
        set {
            captureView.pointOfInterest = newValue
        }
    }

    // MARK: Overlay

    var brush: Brush {
        get {
            return overlay.brush
        }
        set {
            overlay.brush = newValue
        }
    }

    // MARK: Logo

    var logoAnchor: Anchor {
        get {
            return captureView.logoAnchor
        }
        set {
            captureView.logoAnchor = newValue
        }
    }

    var logoOffset: PointWithUnit {
        get {
            return captureView.logoOffset
        }
        set {
            captureView.logoOffset = newValue
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

    private func setViewfinderSize() {
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

}

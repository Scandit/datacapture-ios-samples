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

    var context: DataCaptureContext
    var barcodeSelectionSettings: BarcodeSelectionSettings
    var barcodeSelection: BarcodeSelection
    var captureView: DataCaptureView! {
        didSet {
            overlay = BarcodeSelectionBasicOverlay(barcodeSelection: barcodeSelection,
                                                   view: captureView,
                                                   style: overlayStyle)
        }
    }

    var overlay: BarcodeSelectionBasicOverlay!

    private var internalCamera: Camera? = Camera.default
    private var internalTorchState: TorchState = .off
    // Use the recommended camera settings for the BarcodeSelection mode.
    private var cameraSettings: CameraSettings = BarcodeSelection.recommendedCameraSettings
    private var internalTorchSwitch: TorchSwitchControl = TorchSwitchControl()

    init() {
        // The barcode selection process is configured through barcode selection settings
        // and are then applied to the barcode selection instance that manages barcode recognition.
        barcodeSelectionSettings = BarcodeSelectionSettings()

        // Create data capture context using your license key and set the camera as the frame source.
        context = DataCaptureContext.licensed
        context.setFrameSource(internalCamera, completionHandler: nil)

        // Create new barcode selection mode with the settings from above.
        barcodeSelection = BarcodeSelection(context: context, settings: barcodeSelectionSettings)

        // Make sure that references to some settings are actually the current settings
        internalCamera?.apply(cameraSettings, completionHandler: nil)
        internalCamera?.desiredTorchState = internalTorchState
    }

    // MARK: - Barcode Selection

    // MARK: Symbologies

    var anySymbologyEnabled: Bool {
        !barcodeSelectionSettings.enabledSymbologyValues.isEmpty
    }

    func setAllSymbologies(enabled: Bool) {
        if enabled {
            let allSymbologies = Set(Symbology.allCases.map { NSNumber(value: $0.rawValue) })
            barcodeSelectionSettings.enableSymbologies(allSymbologies)
        } else {
            barcodeSelectionSettings.enabledSymbologyValues.forEach { symbologyValue in
                let symbology = Symbology(rawValue: symbologyValue.uintValue)!
                barcodeSelectionSettings.set(symbology: symbology, enabled: false)
            }
        }
        barcodeSelection.apply(barcodeSelectionSettings, completionHandler: nil)
    }

    func isSymbologyEnabled(_ symbology: Symbology) -> Bool {
        barcodeSelectionSettings.enabledSymbologyValues.contains(NSNumber(value: symbology.rawValue))
    }

    func getSymbologySettings(for symbology: Symbology) -> SymbologySettings {
        barcodeSelectionSettings.settings(for: symbology)
    }

    func symbologySettingsChanged() {
        // Apply barcode selection settings, which includes symbology settings that might've
        // been potentially updated
        barcodeSelection.apply(barcodeSelectionSettings, completionHandler: nil)
    }

    // MARK: Selection Type

    var selectionType: BarcodeSelectionType {
        get {
            barcodeSelectionSettings.selectionType
        }
        set {
            barcodeSelectionSettings.selectionType = newValue
            barcodeSelection.apply(barcodeSelectionSettings, completionHandler: nil)
        }
    }

    // MARK: Single Barcode Auto Detection

    var singleBarcodeAutoDetection: Bool {
        get {
            barcodeSelectionSettings.singleBarcodeAutoDetection
        }
        set {
            barcodeSelectionSettings.singleBarcodeAutoDetection = newValue
            barcodeSelection.apply(barcodeSelectionSettings, completionHandler: nil)
        }
    }

    // MARK: Feedback

    var feedback: Feedback {
        get {
            barcodeSelection.feedback.selection
        }
        set {
            barcodeSelection.feedback.selection = newValue
        }
    }

    var sound: Sound? {
        get {
            feedback.sound
        }
        set {
            feedback = Feedback(vibration: hapticAndVibration.sdcVibration, sound: newValue)
        }
    }

    var hapticAndVibration: HapticAndVibration = .selectionHapticFeedback {
        didSet {
            feedback = Feedback(vibration: hapticAndVibration.sdcVibration, sound: sound)
        }
    }

    // MARK: Code Duplicate Filter

    var codeDuplicateFilter: TimeInterval {
        get {
            return barcodeSelectionSettings.codeDuplicateFilter
        }
        set {
            barcodeSelectionSettings.codeDuplicateFilter = newValue
            barcodeSelection.apply(barcodeSelectionSettings, completionHandler: nil)
        }
    }

    // MARK: Capture Mode Point of Intereset

    var modePointOfInterest: PointWithUnit {
        get {
            barcodeSelection.pointOfInterest
        }
        set {
            barcodeSelection.pointOfInterest = newValue
        }
    }

    // MARK: - Camera

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
            internalTorchState
        }
        set {
            internalTorchState = newValue
            camera?.desiredTorchState = internalTorchState
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

    var zoomFactor: CGFloat {
        get {
            cameraSettings.zoomFactor
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
            captureView.scanAreaMargins
        }
        set {
            captureView.scanAreaMargins = newValue
        }
    }

    var shouldShowScanAreaGuides: Bool {
        get {
            overlay.shouldShowScanAreaGuides
        }
        set {
            overlay.shouldShowScanAreaGuides = newValue
        }
    }

    // MARK: Point of Interest

    var pointOfInterest: PointWithUnit {
        get {
            captureView.pointOfInterest
        }
        set {
            captureView.pointOfInterest = newValue
        }
    }

    // MARK: Overlay

    var trackedBrushStyle: Brush.Style = .default
    var aimedBrushStyle: Brush.Style = .default
    var selectingBrushStyle: Brush.Style = .default
    var selectedBrushStyle: Brush.Style = .default

    var trackedBrush: Brush {
        switch trackedBrushStyle {
        case .default:
            return BarcodeSelectionBasicOverlay.defaultTrackedBrush(forStyle: overlayStyle)
        case .blue:
            return Brush.scanditTrackedBrush(for: overlayStyle)
        }
    }

    var aimedBrush: Brush {
        switch aimedBrushStyle {
        case .default:
            return BarcodeSelectionBasicOverlay.defaultAimedBrush(forStyle: overlayStyle)
        case .blue:
            return Brush.scanditAimedBrush(for: overlayStyle)
        }
    }

    var selectingBrush: Brush {
        switch selectingBrushStyle {
        case .default:
            return BarcodeSelectionBasicOverlay.defaultSelectingBrush(forStyle: overlayStyle)
        case .blue:
            return Brush.scanditSelectingBrush(for: overlayStyle)
        }
    }

    var selectedBrush: Brush {
        switch selectedBrushStyle {
        case .default:
            return BarcodeSelectionBasicOverlay.defaultSelectedBrush(forStyle: overlayStyle)
        case .blue:
            return Brush.scanditSelectedBrush(for: overlayStyle)
        }
    }

    var frozenBackgroundColor: UIColor {
        get {
            overlay.frozenBackgroundColor
        }
        set {
            overlay.frozenBackgroundColor = newValue
        }
    }

    var shouldShowHints: Bool {
        get {
            overlay.shouldShowHints
        }
        set {
            overlay.shouldShowHints = newValue
        }
    }

    // MARK: Viewfinder

    var frameColor: UIColor {
        get {
            if let aimerViewfinder = overlay.viewfinder as? AimerViewfinder {
                return aimerViewfinder.frameColor
            }
            return .white
        }
        set {
            if let aimerViewfinder = overlay.viewfinder as? AimerViewfinder {
                aimerViewfinder.frameColor = newValue
            }
        }
    }

    var dotColor: UIColor {
        get {
            if let aimerViewfinder = overlay.viewfinder as? AimerViewfinder {
                return aimerViewfinder.dotColor
            }
            return UIColor(white: 1, alpha: 0.7)
        }
        set {
            if let aimerViewfinder = overlay.viewfinder as? AimerViewfinder {
                aimerViewfinder.dotColor = newValue
            }
        }
    }

    var overlayStyle: BarcodeSelectionBasicOverlayStyle = .frame

    func createAndSetupBarcodeSelectionBasicOverlay() {
        captureView.removeOverlay(overlay)
        let newOverlay = BarcodeSelectionBasicOverlay(barcodeSelection: barcodeSelection,
                                        view: captureView,
                                        style: overlayStyle)
        newOverlay.shouldShowScanAreaGuides = shouldShowScanAreaGuides
        newOverlay.trackedBrush = trackedBrush
        newOverlay.aimedBrush = aimedBrush
        newOverlay.selectedBrush = selectedBrush
        newOverlay.selectingBrush = selectingBrush
        newOverlay.frozenBackgroundColor = frozenBackgroundColor
        newOverlay.shouldShowHints = shouldShowHints
        if let aimerViewfinder = newOverlay.viewfinder as? AimerViewfinder {
            aimerViewfinder.frameColor = frameColor
        }
        if let aimerViewfinder = newOverlay.viewfinder as? AimerViewfinder {
            aimerViewfinder.dotColor = dotColor
        }
        overlay = newOverlay
    }
}

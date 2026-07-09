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

import ScanditBarcodeCapture
import ScanditLabelCapture
import UIKit

final class ScanViewController: UIViewController {

    // Enter your Scandit License key here.
    // Your Scandit License key is available via your Scandit SDK web account.
    private static let licenseKey = "-- ENTER YOUR SCANDIT LICENSE KEY HERE --"

    private static let labelDefinitionName = "PRICE-LABEL"
    // Field names produced by `LabelDefinition.priceCapture(withName:)`.
    private static let skuFieldName = "SKU"
    private static let priceFieldName = "priceText"

    private let database = BarcodePriceDatabase.loadFromBundle(named: "barcode_price_database")

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var labelCapture: LabelCapture!
    private var captureView: DataCaptureView!

    private lazy var clearBrush = Brush(fill: .clear, stroke: .clear, strokeWidth: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        try? setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        labelCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        labelCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    private func setupRecognition() throws {
        let priceDefinition = LabelDefinition.priceCapture(withName: Self.labelDefinitionName)
        let labelCaptureSettings = try LabelCaptureSettings(labelDefinitions: [priceDefinition])

        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: Self.licenseKey)
        context = DataCaptureContext.shared
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the LabelCapture mode.
        let recommendedCameraSettings = LabelCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // Create LabelCapture mode
        labelCapture = LabelCapture(context: context, settings: labelCaptureSettings)

        // Disable the mode's automatic capture feedback; it is emitted manually from the
        // advanced overlay delegate when the status pin is shown.
        labelCapture.feedback.success = Feedback(vibration: nil, sound: nil)

        // Create capture view to visualize the frame source and set it up
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.insertSubview(captureView, at: 0)

        // Basic overlay draws the colored box around the price field.
        let basicOverlay = LabelCaptureBasicOverlay(labelCapture: labelCapture)
        basicOverlay.delegate = self
        captureView.addOverlay(basicOverlay)

        // Advanced overlay floats the status pin above the captured label.
        let advancedOverlay = LabelCaptureAdvancedOverlay(labelCapture: labelCapture, view: captureView)
        advancedOverlay.delegate = self
    }

    /// Validation result for a captured label, or `nil` while the (barcode, price) pair is
    /// still incomplete. The same result drives both the price-field box and the status icon.
    private func result(for label: CapturedLabel) -> BarcodePriceDatabase.ValidationResult? {
        var capturedBarcode: String?
        var capturedPrice: Decimal?

        for field in label.fields {
            switch field.name {
            case Self.skuFieldName:
                capturedBarcode = field.barcode?.data
            case Self.priceFieldName:
                if let text = field.text {
                    capturedPrice = Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
                }
            default:
                break
            }
        }

        guard let barcode = capturedBarcode, !barcode.isEmpty, let price = capturedPrice else {
            return nil
        }
        return database.validate(barcode: barcode, capturedPrice: price)
    }
}

// MARK: - Validation appearance

extension BarcodePriceDatabase.ValidationResult {

    fileprivate enum Palette {
        static let green = UIColor(red: 13 / 255, green: 133 / 255, blue: 61 / 255, alpha: 1)
        static let red = UIColor(red: 217 / 255, green: 33 / 255, blue: 33 / 255, alpha: 1)
        static let yellow = UIColor(red: 240 / 255, green: 189 / 255, blue: 48 / 255, alpha: 1)
    }

    fileprivate var color: UIColor {
        switch self {
        case .correct: return Palette.green
        case .incorrect: return Palette.red
        case .unknown: return Palette.yellow
        }
    }

    fileprivate var pinImageName: String {
        switch self {
        case .correct: return "overlay_correct"
        case .incorrect: return "overlay_incorrect"
        case .unknown: return "overlay_unknown"
        }
    }

    fileprivate var boxBrush: Brush {
        Brush(fill: .clear, stroke: color, strokeWidth: 3)
    }

    fileprivate func makePinView() -> UIView {
        let imageView = UIImageView(image: UIImage(named: pinImageName))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        return imageView
    }
}

// MARK: - LabelCaptureBasicOverlayDelegate

extension ScanViewController: LabelCaptureBasicOverlayDelegate {

    func labelCaptureBasicOverlay(
        _ overlay: LabelCaptureBasicOverlay,
        brushFor field: LabelField,
        of label: CapturedLabel
    ) -> Brush? {
        // Only the price field gets the colored box; everything else stays clear.
        guard field.name == Self.priceFieldName else { return clearBrush }
        return result(for: label)?.boxBrush ?? clearBrush
    }

    func labelCaptureBasicOverlay(
        _ overlay: LabelCaptureBasicOverlay,
        brushFor label: CapturedLabel
    ) -> Brush? {
        // No whole-label outline — only the price field is highlighted.
        clearBrush
    }

    func labelCaptureBasicOverlay(
        _ overlay: LabelCaptureBasicOverlay,
        didTap label: CapturedLabel
    ) {
        // No tap interaction in this sample.
    }
}

// MARK: - LabelCaptureAdvancedOverlayDelegate

extension ScanViewController: LabelCaptureAdvancedOverlayDelegate {

    // Required label-level methods — unused: the pin is attached to the price field below so
    // it tracks the field, not the whole label.
    func labelCaptureAdvancedOverlay(
        _ overlay: LabelCaptureAdvancedOverlay,
        viewFor capturedLabel: CapturedLabel
    ) -> UIView? {
        nil
    }

    func labelCaptureAdvancedOverlay(
        _ overlay: LabelCaptureAdvancedOverlay,
        anchorFor capturedLabel: CapturedLabel
    ) -> Anchor {
        .center
    }

    func labelCaptureAdvancedOverlay(
        _ overlay: LabelCaptureAdvancedOverlay,
        offsetFor capturedLabel: CapturedLabel
    ) -> PointWithUnit {
        .zero
    }

    // Attach the status pin to the price field, floating just above it so the tip points down.
    func labelCaptureAdvancedOverlay(
        _ overlay: LabelCaptureAdvancedOverlay,
        viewFor field: LabelField,
        of capturedLabel: CapturedLabel
    ) -> UIView? {
        guard field.name == Self.priceFieldName else { return nil }
        // Emit the capture feedback here, once per captured price label, since the mode's
        // automatic feedback is disabled.
        LabelCaptureFeedback.default.success.emit()
        return (result(for: capturedLabel) ?? .unknown).makePinView()
    }

    func labelCaptureAdvancedOverlay(
        _ overlay: LabelCaptureAdvancedOverlay,
        anchorFor field: LabelField,
        of capturedLabel: CapturedLabel
    ) -> Anchor {
        .topCenter
    }

    func labelCaptureAdvancedOverlay(
        _ overlay: LabelCaptureAdvancedOverlay,
        offsetFor field: LabelField,
        of capturedLabel: CapturedLabel
    ) -> PointWithUnit {
        // Lift the pin above the price field so its downward tip points at the field's top edge.
        PointWithUnit(x: .zero, y: FloatWithUnit(value: -20, unit: .dip))
    }
}

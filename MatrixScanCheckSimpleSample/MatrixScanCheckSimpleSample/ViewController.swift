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

extension DataCaptureContext {
    // Enter your Scandit License key here.
    // Your Scandit License key is available via your Scandit SDK web account.
    private static let licenseKey = "-- ENTER YOUR SCANDIT LICENSE KEY HERE --"

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        return DataCaptureContext(licenseKey: licenseKey)
    }
}

class ViewController: UIViewController {
    private var context: DataCaptureContext!
    private var barcodeCheck: BarcodeCheck!
    private var barcodeCheckView: BarcodeCheckView!
    private let discountProvider = DiscountProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barcodeCheckView.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barcodeCheckView.stop()
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Configure the barcode check settings.
        let settings = BarcodeCheckSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)

        // Create BarcodeCheck instance.
        barcodeCheck = BarcodeCheck(context: context, settings: settings)

        // Create and configure BarcodeCheckView with default view settings.
        let viewSettings = BarcodeCheckViewSettings()

        // Use the recommended camera settings for the BarcodeCheck mode.
        let recommendedCameraSettings = BarcodeCheck.recommendedCameraSettings

        // To visualize the on-going barcode check process on screen, setup a barcode check view that renders the
        // camera preview and the barcode check UI. The view is automatically added to the parent view hierarchy.
        barcodeCheckView = BarcodeCheckView(
            parentView: self.view,
            barcodeCheck: barcodeCheck,
            settings: viewSettings,
            cameraSettings: recommendedCameraSettings
        )

        // Set this ViewController as the provider for barcode highlight and annotation styling.
        barcodeCheckView.highlightProvider = self
        barcodeCheckView.annotationProvider = self
    }
}

// MARK: - BarcodeCheckHighlightProvider

extension ViewController: BarcodeCheckHighlightProvider {
    func highlight(for barcode: Barcode) async -> (any UIView & BarcodeCheckHighlight)? {
        // Returns a circular dot highlight that will be displayed over each detected barcode.
        let highlight = BarcodeCheckCircleHighlight(barcode: barcode, preset: .dot)
        highlight.brush = Brush(fill: .white, stroke: .white, strokeWidth: 1)
        return highlight
    }
}

// MARK: - BarcodeCheckAnnotationProvider

extension ViewController: BarcodeCheckAnnotationProvider {
    func annotation(for barcode: Barcode) async -> (any UIView & BarcodeCheckAnnotation)? {
        // Get the information you want to show from your back end system/database.
        let discount = discountProvider.getDiscountForBarcode(barcode)

        // Create and configure the header section of the annotation.
        let header = BarcodeCheckInfoAnnotationHeader()
        header.backgroundColor = discount.color
        header.text = discount.percentage

        // Create and configure the body section of the annotation.
        let bodyComponent = BarcodeCheckInfoAnnotationBodyComponent()
        bodyComponent.backgroundColor = .white.withAlphaComponent(0.9)
        bodyComponent.text = discount.expirationMessage

        // Create the annotation itself and attach the header and body.
        let annotation = BarcodeCheckInfoAnnotation(barcode: barcode)
        annotation.backgroundColor = .clear
        annotation.width = .large
        annotation.header = header
        annotation.body = [bodyComponent]

        // Set this ViewController as the delegate for annotation to handle annotation taps.
        annotation.delegate = self
        // Set this property to handle tap in any part of the annotation instead of individual parts.
        annotation.isEntireAnnotationTappable = true

        return annotation
    }
}

extension ViewController: BarcodeCheckInfoAnnotationDelegate {
    func barcodeCheckInfoAnnotationDidTap(_ annotation: BarcodeCheckInfoAnnotation) {
        // Handle annotation tap.
        let discount = discountProvider.getDiscountForBarcode(annotation.barcode)
        if annotation.body.first?.text == discount.expirationMessage {
            annotation.body.first?.text = discount.expirationDate
        } else {
            annotation.body.first?.text = discount.expirationMessage
        }
    }

    func barcodeCheckInfoAnnotationDidTapHeader(_ annotation: BarcodeCheckInfoAnnotation) {
        // no op
    }

    func barcodeCheckInfoAnnotationDidTapFooter(_ annotation: BarcodeCheckInfoAnnotation) {
        // no op
    }

    func barcodeCheckInfoAnnotation(_ annotation: BarcodeCheckInfoAnnotation,
                                    didTapLeftIconFor component: BarcodeCheckInfoAnnotationBodyComponent,
                                    at componentIndex: Int) {
        // no op
    }

    func barcodeCheckInfoAnnotation(_ annotation: BarcodeCheckInfoAnnotation,
                                    didTapRightIconFor component: BarcodeCheckInfoAnnotationBodyComponent,
                                    at componentIndex: Int) {
        // no op
    }
}

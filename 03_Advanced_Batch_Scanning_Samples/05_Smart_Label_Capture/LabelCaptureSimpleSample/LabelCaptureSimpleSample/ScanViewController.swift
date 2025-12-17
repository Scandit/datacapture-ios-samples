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

class ScanViewController: UIViewController {
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var labelCapture: LabelCapture!
    private var captureView: DataCaptureView!

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        try? setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    private func startScanning() {
        camera?.switch(toDesiredState: .on)
        labelCapture.isEnabled = true
    }

    private func pauseScanning() {
        camera?.switch(toDesiredState: .standby)
        labelCapture.isEnabled = false
    }

    private func stopScanning() {
        camera?.switch(toDesiredState: .off)
        labelCapture.isEnabled = false
    }
}

// MARK: - LabelCapture configuration

extension ScanViewController {

    private func setupRecognition() throws {
        let labelCaptureSettings = try LabelCaptureSettings {
            LabelDefinition("weighted_item") {
                CustomBarcode(
                    name: "barcode",
                    symbologies: [.ean13UPCA, .gs1DatabarExpanded, .code128]
                )

                ExpiryDateText(name: "expiry_date")
                    .labelDateFormat(
                        LabelDateFormat(
                            componentFormat: LabelDateComponentFormat.MDY,
                            acceptPartialDates: false
                        )
                    )
                    .optional(true)

                WeightText(name: "weight")
                    .optional(true)

                UnitPriceText(name: "unit_price")
                    .optional(true)
            }

            // Note: - You can customize the label definiton to adapt it to your use-case.
            // For example, you can use the following label definitoin for Smart Devices box Scanning.
            //        return LabelDefinition("SMART_DEVICE") {
            //            CustomBarcode(
            //                name: "FIELD_BARCODE",
            //                symbologies: [.ean13UPCA, .code128, .code39, .interleavedTwoOfFive]
            //            )
            //
            //            IMEIOneBarcode(name: "FIELD_IMEI1")
            //
            //            IMEITwoBarcode(name: "FIELD_IMEI2")
            //                .optional(true)
            //
            //            SerialNumberBarcode(name: "FIELD_SERIAL_NUMBER")
            //                .optional(true)
            //        }
        }

        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        context = DataCaptureContext.shared
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the LabelCapture mode.
        let recommendedCameraSettings = LabelCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // Create LabelCapture mode
        labelCapture = LabelCapture(context: context, settings: labelCaptureSettings)

        // Create capture view to visualize the frame source and set it up
        captureView = DataCaptureView(context: context, frame: containerView.bounds)
        captureView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        captureView.addControl(TorchSwitchControl())
        containerView.insertSubview(captureView, at: 0)

        // Create basic overlay to visualize results
        let basicOverlay = LabelCaptureBasicOverlay(labelCapture: labelCapture)
        captureView.addOverlay(basicOverlay)

        // Create Validation Flow overlay to verify scanning results and set the delegate
        let validationFlowOverlay = LabelCaptureValidationFlowOverlay(labelCapture: labelCapture, view: captureView)
        let validationFlowSettings = LabelCaptureValidationFlowSettings()
        validationFlowOverlay.apply(validationFlowSettings)
        validationFlowOverlay.delegate = self
        captureView.addOverlay(validationFlowOverlay)
    }
}

// MARK: LabelCaptureValidationFlowDelegate

extension ScanViewController: LabelCaptureValidationFlowDelegate {
    func labelCaptureValidationFlowOverlay(
        _ overlay: LabelCaptureValidationFlowOverlay,
        didCaptureLabelWith fields: [LabelField]
    ) {
        var capturedData: String = ""

        for field in fields {
            let value: String?

            switch field.type {
            case .barcode:
                value = field.barcode?.data
            default:
                if let date = field.asDate() {
                    value = "\(date.day) - \(date.month) - \(date.year)"
                } else {
                    value = field.text
                }
            }

            if let value, !value.isEmpty {
                capturedData.append("\(field.name): \(value)\n")
            }
        }

        DispatchQueue.main.async {
            self.pauseScanning()
            self.showLabelCapturedAlert(capturedData: capturedData)
        }
    }

    private func showLabelCapturedAlert(capturedData: String) {
        let alert = UIAlertController(
            title: "Label Captured",
            message: capturedData,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Continue Scanning",
                style: .default,
                handler: { _ in
                    self.startScanning()
                }
            )
        )

        present(alert, animated: true)
    }
}

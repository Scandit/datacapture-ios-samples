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
        setupRecognition()
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
    private var labelDefinition: LabelDefinition {
        // barcode value starting with 02, UPC/GS1 DataBar Expanded/Code128
        let barcodeField = CustomBarcode(
            name: "barcode",
            symbologies: [
                NSNumber(value: Symbology.ean13UPCA.rawValue),
                NSNumber(value: Symbology.gs1DatabarExpanded.rawValue),
                NSNumber(value: Symbology.code128.rawValue),
            ]
        )
        barcodeField.patterns = ["^0?2\\d+"]

        let expiryDateField = ExpiryDateText(name: "expiry_date")
        expiryDateField.labelDateFormat = LabelDateFormat(
            componentFormat: LabelDateComponentFormat.MDY,
            acceptPartialDates: false
        )
        expiryDateField.optional = true

        let weightField = WeightText(name: "weight")
        weightField.optional = true

        let unitPriceField = UnitPriceText(name: "unit_price")
        unitPriceField.optional = true

        return LabelDefinition(
            name: "weighted_item",
            fields: [barcodeField, expiryDateField, weightField, unitPriceField]
        )

        // Note: - You can customize the label definiton to adapt it to your use-case. For example, you can use the following label definitoin for Smart Devices box Scanning.
        //        let barcodeField = CustomBarcode(
        //            name: "FIELD_BARCODE",
        //            symbologies: [
        //                NSNumber(value: Symbology.ean13UPCA.rawValue),
        //                NSNumber(value: Symbology.code128.rawValue),
        //                NSNumber(value: Symbology.code39.rawValue),
        //                NSNumber(value: Symbology.interleavedTwoOfFive.rawValue),
        //            ]
        //        )
        //
        //        let imeiOneField = IMEIOneBarcode(name: "FIELD_IMEI1")
        //
        //        let imeiTwoField = IMEITwoBarcode(name: "FIELD_IMEI2")
        //        imeiTwoField.optional = true
        //
        //        let serialNumberField = SerialNumberBarcode(name: "FIELD_SERIAL_NUMBER")
        //        serialNumberField.optional = true
        //
        //        return LabelDefinition(
        //            name: "SMART_DEVICE",
        //            fields: [barcodeField, imeiOneField, imeiTwoField, serialNumberField]
        //        )
    }

    private func setupRecognition() {
        guard let labelCaptureSettings = try? LabelCaptureSettings(labelDefinitions: [labelDefinition])
        else {
            return
        }

        // Create context and set the default camera as frame source
        // See DataCaptureContext+Extensions.swift for DataCaptureContext.licensed
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        context = DataCaptureContext.sharedInstance
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
            self.showLabelCapturedAlert(caputredData: capturedData)
        }
    }

    private func showLabelCapturedAlert(caputredData: String) {
        let alert = UIAlertController(
            title: "Label Captured",
            message: caputredData,
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

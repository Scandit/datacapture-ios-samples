/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import ScanditBarcodeCapture
import UIKit

class CommonScannerViewController: UIViewController {
    private var captureView: DataCaptureView!
    private var context: DataCaptureContext!
    private var camera = Camera.default
    private var barcodeCapture: BarcodeCapture!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        barcodeCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode tracking as well.
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    func setupRecognition() {
        // The barcode capturing process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let barcodeCaptureSettings = BarcodeCaptureSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        barcodeCaptureSettings.set(symbology: .ean13UPCA, enabled: true)
        barcodeCaptureSettings.set(symbology: .ean8, enabled: true)
        barcodeCaptureSettings.set(symbology: .upce, enabled: true)
        barcodeCaptureSettings.set(symbology: .qr, enabled: true)
        barcodeCaptureSettings.set(symbology: .dataMatrix, enabled: true)
        barcodeCaptureSettings.set(symbology: .code39, enabled: true)
        barcodeCaptureSettings.set(symbology: .code128, enabled: true)
        barcodeCaptureSettings.set(symbology: .interleavedTwoOfFive, enabled: true)

        // Create data capture context using your license key and set the camera as the frame source.
        context = DataCaptureContext.licensed
        context.setFrameSource(camera, completionHandler: nil)

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: barcodeCaptureSettings)

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(for: context, frame: view.bounds)

        // Add a barcode capture overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback.
        let barcodeCaptureOverlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, for: captureView)

        // We have to add the overlay to the capture view.
        captureView.addOverlay(barcodeCaptureOverlay)

        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
    }

    private func showResult(_ result: String,
                            symbology: Symbology,
                            symbolCount: Int,
                            completion: @escaping () -> Void) {
        // Assemble the message part.
        var message = "\(symbology.readableName): \(result)"
        if symbolCount != -1 {
            message += "\nSymbol count: \(symbolCount)"
        }

        let alert = UIAlertController(title: "Scanned", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in completion() }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CommonScannerViewController: BarcodeCaptureListener {
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcodes.first else {
            return
        }

        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new results until
        // the capture mode is enabled again. Note that disabling the capture mode does not stop the camera, the camera
        // continues to stream frames until it is turned off.
        barcodeCapture.isEnabled = false

        // This method is invoked on a non-UI thread, so in order to perform UI work,
        // we have to switch to the main thread.
        DispatchQueue.main.async { [weak self] in
            self?.showResult(barcode.data, symbology: barcode.symbology, symbolCount: barcode.symbolCount) {
                // Enable recognizing barcodes when the result is not shown anymore.
                self?.barcodeCapture.isEnabled = true
            }
        }
    }
}

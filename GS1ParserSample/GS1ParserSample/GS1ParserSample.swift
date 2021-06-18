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

import UIKit

import ScanditCaptureCore
import ScanditBarcodeCapture
import ScanditParser

class GS1ParserSample: UIViewController {

    // The barcode capturing process is configured through the barcode capture settings
    // and are then applied to the barcode capture instance that manages barcode recognition.
    private lazy var barcodeCaptureSettings = BarcodeCaptureSettings()

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var parser: Parser!

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable id capture as well.
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the IdCapture mode.
        let recommendedCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // We are interested in scanning GS1 data from code128 and dataMatrix barcodes
        barcodeCaptureSettings.set(symbology: .code128, enabled: true)
        barcodeCaptureSettings.set(symbology: .dataMatrix, enabled: true)

        // Create new barcode capture mode with the chosen settings.
        barcodeCapture = BarcodeCapture(context: context, settings: barcodeCaptureSettings)

        // Register self as a listener to get informed whenever a new barcode is recognized.
        barcodeCapture.addListener(self)

        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        let overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture)
        overlay.viewfinder = RectangularViewfinder(style: .square, lineStyle: .bold)
        captureView.addOverlay(overlay)

        // Let's create the Parser object that will parse the GS1 strings.
        parser = try! Parser(context: context, format: .gs1AI)
    }
}

extension GS1ParserSample: BarcodeCaptureListener {
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let capturedBarcode = session.newlyRecognizedBarcodes.first,
              let barcodeValue = capturedBarcode.data else { return }

        do {
            let message: String
            let parsedData = try parser.parseString(barcodeValue)
            // Let's pause the barcodeCapture mode while we show the captured GS1 data.
            barcodeCapture.isEnabled = false
            message = parsedData.fields.reduce("") { (result, field) -> String in
                guard let parsed = field.parsed else { return result }
                return "\(result) \n\(field.name): \(parsed)"
            }

            // Show the parsed data.
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Parser result", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    self.barcodeCapture.isEnabled = true
                }))
                self.present(alert, animated: true, completion: nil)
            }

        } catch {
            print("Parser did fail with error: \(error.localizedDescription)")
            self.barcodeCapture.isEnabled = true
        }
    }
}

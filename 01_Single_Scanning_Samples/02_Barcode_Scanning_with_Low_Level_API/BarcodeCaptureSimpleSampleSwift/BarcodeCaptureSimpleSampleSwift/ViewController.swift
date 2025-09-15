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

class ViewController: UIViewController {

    private lazy var context = {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        return DataCaptureContext.shared
    }()
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!
    private let feedback = Feedback.default  // Used when emitting feedback manually.

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on. To be notified when the camera is completely on, pass non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        barcodeCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        // To be notified when the camera is completely stopped, pass a non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    func setupRecognition() {
        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommendedCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // The barcode capturing process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let settings = BarcodeCaptureSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true)

        // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
        // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
        // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
        // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        let symbologySettings = settings.settings(for: .code39)
        symbologySettings.activeSymbolCounts = Set(7...20)

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: settings)

        // By default, every time a barcode is scanned, a sound (if not in silent mode) and a vibration are played.
        // Uncomment the following line to set a success feedback without sound and vibration.
        //        barcodeCapture.feedback.success = Feedback(vibration: nil, sound: nil)

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, view: captureView)
        overlay.viewfinder = RectangularViewfinder(style: .square, lineStyle: .light)
    }

    private func showResult(_ result: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

// MARK: - BarcodeCaptureListener

extension ViewController: BarcodeCaptureListener {

    func barcodeCapture(
        _ barcodeCapture: BarcodeCapture,
        didScanIn session: BarcodeCaptureSession,
        frameData: FrameData
    ) {
        guard let barcode = session.newlyRecognizedBarcode else {
            return
        }

        // Use the following code to reject barcodes.
        // By uncommenting the following lines, barcodes not starting with 09: are ignored.
        //        guard (barcode.data ?? "").hasPrefix("09:") else {
        //            // We temporarily change the brush, used to highlight recognized barcodes, to a transparent brush.
        //            self.overlay.brush = Brush.transparent
        //            return
        //        }
        // Otherwise, if the barcode is of interest, we want to use a brush to highlight it.
        //        overlay.brush = Brush(fill: .clear, stroke: .white, strokeWidth: 3)
        // We also want to emit a feedback (vibration and, if enabled, sound).
        // By default, every time a barcode is scanned, a sound (if not in silent mode) and a vibration are played.
        // To emit a feedback only when necessary, it is necessary to set a success feedback without sound and vibration
        // when setting up Barcode Capture (in this case in the `setupRecognition` method).
        //        feedback.emit()

        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new results until
        // the capture mode is enabled again. Note that disabling the capture mode does not stop the camera, the camera
        // continues to stream frames until it is turned off.
        barcodeCapture.isEnabled = false

        // If you don't want the codes to be scanned more than once, consider setting the
        // codeDuplicateFilter when creating the barcode capture settings to -1.
        // You can set any other value (e.g. 500) to set a fixed timeout and override the smart
        // behaviour enabled by default.

        // Get the human readable name of the symbology and assemble the result to be shown.
        let symbology = SymbologyDescription(symbology: barcode.symbology).readableName

        var result = "Scanned: "
        if let data = barcode.data {
            result += "\(data) "
        }
        result += "(\(symbology))"

        showResult(result) { [weak self] in
            // Enable recognizing barcodes when the result is not shown anymore.
            self?.barcodeCapture.isEnabled = true
        }
    }

}

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
import UIKit

extension DataCaptureContext {
    // Enter your Scandit License key here.
    // Your Scandit License key is available via your Scandit SDK web account.
    private static let licenseKey = "-- ENTER YOUR SCANDIT LICENSE KEY HERE --"

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        DataCaptureContext(licenseKey: licenseKey)
    }
}

class ScanningViewController: UIViewController {
    var results: [String: Barcode] = [:]

    @IBOutlet private weak var showResultsButton: UIButton!

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeBatch: BarcodeBatch!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeBatchBasicOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        results = [:]

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        barcodeBatch.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable Barcode Batch as well.
        barcodeBatch.isEnabled = false
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

        // Use the recommended camera settings for the BarcodeBatch mode as default settings.
        // The preferred resolution is automatically chosen, which currently defaults to HD on all devices.
        // Setting the preferred resolution to full HD helps to get a better decode range.
        let cameraSettings = BarcodeBatch.recommendedCameraSettings
        cameraSettings.preferredResolution = .fullHD
        camera?.apply(cameraSettings, completionHandler: nil)

        // The barcode tracking process is configured through Barcode Batch settings
        // and are then applied to the Barcode Batch instance that manages barcode tracking.
        let settings = BarcodeBatchSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)

        // Create new Barcode Batch mode with the settings from above.
        barcodeBatch = BarcodeBatch(context: context, settings: settings)

        // Register self as a listener to get informed of tracked barcodes.
        barcodeBatch.addListener(self)

        // To visualize the on-going barcode tracking process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)

        // Add a Barcode Batch overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback. The overlay is automatically added
        // to the view.
        overlay = BarcodeBatchBasicOverlay(barcodeBatch: barcodeBatch, view: captureView, style: .frame)
        overlay.brush = .accepted
        overlay.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultsViewController = segue.destination as? ResultsViewController else {
            return
        }

        resultsViewController.results = Array(results.values)
    }
}

// MARK: - Barcode extension

fileprivate extension Barcode {
    var isRejected: Bool {
        data?.first == "7"
    }
}

// MARK: - BarcodeBatchListener

extension ScanningViewController: BarcodeBatchListener {
    // This function is called whenever objects are updated and it's the right place to react to the tracking results.
    func barcodeBatch(
        _ barcodeBatch: BarcodeBatch,
        didUpdate session: BarcodeBatchSession,
        frameData: FrameData
    ) {
        let barcodes = session.trackedBarcodes.values.compactMap { $0.barcode }
        DispatchQueue.main.async {
            barcodes.forEach { barcode in
                // The `isRejected` property is for illustrative purposes only, not part of the official API.
                if let data = barcode.data, !data.isEmpty, !barcode.isRejected {
                    self.results[data] = barcode
                }
            }
        }
    }
}

// MARK: - Brush extension

fileprivate extension Brush {
    static let rejected: Brush = {
        let defaultBrush = BarcodeBatchBasicOverlay.defaultBrush(forStyle: .frame)
        guard let brushBorderColor = UIColor(sdcHexString: "#FA4446FF") else {
            return .transparent
        }
        return Brush(
            fill: .clear,
            stroke: brushBorderColor,
            strokeWidth: defaultBrush.strokeWidth
        )
    }()

    static let accepted: Brush = {
        let defaultBrush = BarcodeBatchBasicOverlay.defaultBrush(forStyle: .frame)
        return Brush(
            fill: defaultBrush.fillColor,
            stroke: defaultBrush.strokeColor,
            strokeWidth: defaultBrush.strokeWidth
        )
    }()
}

// MARK: - BarcodeBatchBasicOverlayDelegate

extension ScanningViewController: BarcodeBatchBasicOverlayDelegate {
    // This function is called to get the brush to be used for tracked barcodes, for example to visualize rejected ones.
    // Note that modifying a barcode's brush color requires the MatrixScan AR add-on.
    func barcodeBatchBasicOverlay(
        _ overlay: BarcodeBatchBasicOverlay,
        brushFor trackedBarcode: TrackedBarcode
    ) -> Brush? {
        // The `isRejected` property is for illustrative purposes only, not part of the official API.
        guard trackedBarcode.barcode.isRejected else {
            return overlay.brush
        }
        return .rejected
    }

    func barcodeBatchBasicOverlay(
        _ overlay: BarcodeBatchBasicOverlay,
        didTap trackedBarcode: TrackedBarcode
    ) {
    }
}

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

class ScannerViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeTracking: BarcodeTracking!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeTrackingBasicOverlay!

    private var results: [String: Barcode] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Remove the scanned barcodes everytime the barcode tracking starts.
        results.removeAll()

        // First, enable barcode tracking to resume processing frames.
        barcodeTracking.isEnabled = true
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // First, disable barcode tracking to stop processing frames.
        barcodeTracking.isEnabled = false
        // Switch the camera off to stop streaming frames. The camera is stopped asynchronously.
        camera?.switch(toDesiredState: .off)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultsViewController = segue.destination as? ResultViewController else {
            return
        }
        resultsViewController.codes = Array(results.values)
    }

    @IBAction func unwindToScanner(segue: UIStoryboardSegue) {}

    private func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the default camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeTracking mode as default settings.
        // The preferred resolution is automatically chosen, which currently defaults to HD on all devices.
        // Setting the preferred resolution to full HD helps to get a better decode range.
        let cameraSettings = BarcodeTracking.recommendedCameraSettings
        cameraSettings.preferredResolution = .fullHD
        camera?.apply(cameraSettings, completionHandler: nil)

        // swiftlint:disable line_length
        // Scenario A is used as an example to show how the scenario has to be set to configure barcode tracking
        // properly. Please choose the right scenario depending on your exact use case; you can find more information
        // at https://docs.scandit.com/data-capture-sdk/ios/barcode-capture/api/barcode-tracking-settings.html#method-scandit.datacapture.barcode.tracking.BarcodeTrackingSettings.ForScenario .
        // Feel free to contact support@scandit.com if you have any questions about it.
        // swiftlint:enable line_length
        let scenario: BarcodeTrackingScenario = .a

        // The barcode tracking process is configured through barcode tracking settings
        // and are then applied to the barcode tracking instance that manages barcode tracking.
        let settings = BarcodeTrackingSettings(scenario: scenario)

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)

        // Create new barcode tracking mode with the settings from above.
        barcodeTracking = BarcodeTracking(context: context, settings: settings)

        // Register self as a listener to get informed of tracked barcodes.
        barcodeTracking.addListener(self)

        // To visualize the on-going barcode tracking process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.context = context
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)

        // Add a barcode tracking overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback.
        overlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking, view: captureView, style: .frame)
    }
}

// MARK: - BarcodeTrackingListener
extension ScannerViewController: BarcodeTrackingListener {
     // This function is called whenever objects are updated and it's the right place to react to the tracking results.
    func barcodeTracking(_ barcodeTracking: BarcodeTracking,
                         didUpdate session: BarcodeTrackingSession,
                         frameData: FrameData) {
        let barcodes = session.trackedBarcodes.values.compactMap { $0.barcode }
        DispatchQueue.main.async { [weak self] in
            barcodes.forEach {
                if let self = self, let data = $0.data, !data.isEmpty {
                    self.results[data] = $0
                }
            }
        }
    }
}

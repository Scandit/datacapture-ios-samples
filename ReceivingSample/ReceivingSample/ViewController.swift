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

extension DataCaptureContext {
    private static let licenseKey = "-- ENTER YOUR SCANDIT LICENSE KEY HERE --"

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        return DataCaptureContext(licenseKey: licenseKey)
    }
}

class ViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCount: BarcodeCount!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCountBasicOverlay!
    private var shouldCameraStandby = true

    private var allTrackedBarcodes: [TrackedBarcode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on. To be notified when the camera is completely on, pass non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera to stanby to stop streaming frames. The camera is stopped asynchronously and will take
        // some time to completely turn off.
        // To be notified when the camera is completely stopped, pass a non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        if shouldCameraStandby {
            camera?.switch(toDesiredState: .standby)
        }
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCount mode.
        let recommendedCameraSettings = BarcodeCount.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // The barcode counting process is configured through barcode count settings
        // and are then applied to the barcode count instance that manages barcode recognition.
        let settings = BarcodeCountSettings()

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
        symbologySettings.activeSymbolCounts = Set(7...20) as Set<NSNumber>

        // Create new barcode count mode with the settings from above.
        barcodeCount = BarcodeCount(context: context, settings: settings)

        // Register self as a listener to monitor the barcode count session.
        barcodeCount.add(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Add a barcode count overlay to the data capture view to overlays of tracked barcodes on top of
        // the video preview. This is will also show the UI controls needed to interact with the mode.
        overlay = BarcodeCountBasicOverlay(barcodeCount: barcodeCount, view: captureView, style: .icon)
        overlay.delegate = self
        overlay.uiDelegate = self
    }

    /// Creates  an array of ScannedItem from TrackedBarcode so that it can be displayed by the ListViewController
    private func prepareScannedItemsList(trackedBarcodes: [TrackedBarcode]) -> [ScannedItem] {
        var tempMap: [String: ScannedItem] = [:]
        for trackedBarcode in trackedBarcodes {
            guard let barcodeData = trackedBarcode.barcode.data else {
                continue
            }
            if var item = tempMap[barcodeData] {
                item.quantity += 1
                tempMap[barcodeData] = item
            } else {
                let newItem = ScannedItem(symbology: trackedBarcode.barcode.symbology.description.uppercased(),
                                          data: barcodeData,
                                          quantity: 1)
                tempMap[barcodeData] = newItem
            }
        }

        return Array(tempMap.values)
    }

    @objc
    private func showList(isOrderCompleted: Bool) {
        self.shouldCameraStandby = false
        // Get a list of ScannedItem to display
        let scannedItems = prepareScannedItemsList(trackedBarcodes: allTrackedBarcodes)
        guard scannedItems.count > 0 else {
            return
        }
        let listController = ListViewController(scannedItems: scannedItems, isOrderCompleted: isOrderCompleted)
        // Listen to the user actions
        listController.delegate = self
        // Show the list
        self.navigationController?.pushViewController(listController, animated: true)
    }

}

extension ViewController: BarcodeCountListener {
    func barcodeCount(_ barcodeCount: BarcodeCount, didUpdate session: BarcodeCountSession, frameData: FrameData) {
        // Gather all the tracked barcodes
        let allTrackedBarcodes = session.trackedBarcodes.map({ $0.value })
        // This method is invoked from a recognition internal thread.
        // Dispatch to the main thread to update the internal barcode list.
        DispatchQueue.main.async {
            // Update the internal list
            self.allTrackedBarcodes = allTrackedBarcodes
        }
    }
}

extension ViewController: ListViewControllerDelegate {
    func resumeScanning() {
        self.shouldCameraStandby = true
        self.navigationController?.popViewController(animated: true)
    }

    func restartScanning() {
        self.barcodeCount.reset()
        self.shouldCameraStandby = true
        self.navigationController?.popViewController(animated: true)
    }
}

extension ViewController: BarcodeCountBasicOverlayDelegate {
    func barcodeCountBasicOverlay(_ overlay: BarcodeCountBasicOverlay,
                                  brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        // Return the default brush
        return BarcodeCountBasicOverlay.defaultScannedBrush
    }

    func barcodeCountBasicOverlay(_ overlay: BarcodeCountBasicOverlay,
                                  brushForUntrackedBarcode untrackedBarcode: TrackedBarcode) -> Brush? {
        // Return the default brush
        return BarcodeCountBasicOverlay.defaultUnscannedBrush
    }

    func barcodeCountBasicOverlay(_ overlay: BarcodeCountBasicOverlay,
                                  didTap trackedBarcode: TrackedBarcode) {
        // Not used
    }

    func barcodeCountBasicOverlay(_ overlay: BarcodeCountBasicOverlay,
                                  didTapUntrackedBarcode untrackedBarcode: TrackedBarcode) {
        // Not used
    }
}

extension ViewController: BarcodeCountBasicOverlayUIDelegate {
    func listButtonTapped(for overlay: BarcodeCountBasicOverlay) {
        // Show the current progress but the order is not completed
        showList(isOrderCompleted: false)
    }

    func exitButtonTapped(for overlay: BarcodeCountBasicOverlay) {
        // The order is completed
        showList(isOrderCompleted: true)
    }
}

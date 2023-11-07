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
	// There is a Scandit sample license key set below here.
	// This license key is enabled for sample evaluation only.
	// If you want to build your own application,
    // get your license key by signing up for a trial at https://ssl.scandit.com/dashboard/sign-up?p=test
    private static let licenseKey = "AWHjFzlFHa+fLq/kfS8GCBU/hT60NkQeVGQOWhhtRVcDZxJfsD0OY9NK0YErLuxTtTKLC1BLdrvDdsJ1dnxmcx9fDIeeaQlxawtkiq1pmEFxHOvYa3emcbAfOeiwbFPtQEWCWvdc95KoIFxAuDiYcfccdywzH2KONgwmnV9cEcX11FhIPLtX74RLua7VkOukFfNTOGExxhiCq96qZnzGgrgViuagpL0ekK6xv8K4bYt7lVkxloUMM6dFRSZ4aummJ2Q1uZNR78kSGCpCn/uJjaf/5lyNbYWpnxYvsYRPI7jOFYZykI0nIjhjt/ncukCEsz4BQLAh5hp1qocvQ2+dw3ADD8LJLXcnX7JaCOKV5cfHEHGSLR4moTxNtxPXdUNlM5w75iHZub5BsIfkJCknKrLn5oJ15k5Rx4/JnFj11tGLqtfRs+jdtXSGxAb86BxwPM1mEBO/Va1yV//CGku5UWR5MwspCf7pl8OUH7frkCtV4kDB6y5jusSMSIEGnKCLd2sWKE04mAURrpWt8pgsIB89xXPPTgPh1C+nAeMuuEN3dPYAJYrJKvy44w130JrUvxWLcTM1oFVWikC6CluLC7WGgRhZCew0eROnv9neITolB6Gmy04dlF0euA595dJcw2lLTwwxEydGp5gGIIDtofviho7JdHtPrMer/Ptz1/LOVeF55OY9eg8z1Lq2CkZf6cgWZBPa1uakuZzxWXZUprJMdTquhInmqP4ELLxGXhv+CXoT2n0p022+wyiWAXatmhvcK+n2uCWX30SL0Sri1qPmf6Ldtgqj2aFEMLM+LouJg6Ukv0PKUTXlgPW7L0vYrNGtPjvRlaR7Nwph"

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        return DataCaptureContext(licenseKey: licenseKey)
    }
}

class ViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCount: BarcodeCount!
    private var barcodeCountView: BarcodeCountView!
    private var shouldCameraStandby = true

    private var allRecognizedBarcodes: [TrackedBarcode] = []
    private var previouslyScannedBarcodes: [Barcode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MatrixScan Count"
        setupRecognition()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure that Barcode Count mode is enabled after going back from the list screen
        barcodeCountView.prepareScanning(with: context)

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

        if isMovingFromParent {
            // Stop the mode when dismissed
            barcodeCountView.stopScanning()
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
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)

        // Create new barcode count mode with the settings from above.
        barcodeCount = BarcodeCount(context: context, settings: settings)

        // Register self as a listener to monitor the barcode count session.
        barcodeCount.add(self)

        // To visualize the Barcode Count UI you need to create a BarcodeCountView and add it to the view hierarchy.
        // BarcodeCountView is designed to be displayed full screen.
        barcodeCountView = BarcodeCountView(frame: view.bounds, context: context, barcodeCount: barcodeCount)
        barcodeCountView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(barcodeCountView)
        barcodeCountView.delegate = self
        barcodeCountView.uiDelegate = self
    }

    /// Creates  an array of ScannedItem from TrackedBarcode so that it can be displayed by the ListViewController
    private func prepareScannedItemsList(trackedBarcodes: [TrackedBarcode],
                                         previousBarcodes: [Barcode]) -> [ScannedItem] {
        var tempMap: [String: ScannedItem] = [:]
        var allBarcodes = trackedBarcodes.compactMap { $0.barcode }
        allBarcodes.append(contentsOf: previousBarcodes)
        for barcode in allBarcodes {
            guard let barcodeData = barcode.data else {
                continue
            }
            if var item = tempMap[barcodeData] {
                item.quantity += 1
                tempMap[barcodeData] = item
            } else {
                let newItem = ScannedItem(symbology: barcode.symbology.description.uppercased(),
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
        let scannedItems = prepareScannedItemsList(trackedBarcodes: allRecognizedBarcodes,
                                                   previousBarcodes: previouslyScannedBarcodes)
        let listController = ListViewController(scannedItems: scannedItems, isOrderCompleted: isOrderCompleted)
        // Listen to the user actions
        listController.delegate = self
        // Show the list
        self.navigationController?.pushViewController(listController, animated: true)
    }

    @objc func didEnterBackground() {
        let currentlyTrackedBarcodes = allRecognizedBarcodes.compactMap({ trackedBarcode in
            return trackedBarcode.barcode
        })
        previouslyScannedBarcodes.append(contentsOf: currentlyTrackedBarcodes)
        allRecognizedBarcodes.removeAll()
        barcodeCount.reset()
    }

    @objc func willEnterForeground() {
        barcodeCount.setAdditionalBarcodes(previouslyScannedBarcodes)
    }

    private func resetMode() {
        barcodeCount.setAdditionalBarcodes([])
        barcodeCount.reset()
        allRecognizedBarcodes.removeAll()
        previouslyScannedBarcodes.removeAll()
    }
}

extension ViewController: BarcodeCountListener {
    func barcodeCount(_ barcodeCount: BarcodeCount,
                      didScanIn session: BarcodeCountSession,
                      frameData: FrameData) {
        // Gather all the recognized barcodes
        let allRecognizedBarcodes = session.recognizedBarcodes.map({ $0.value })
        // This method is invoked from a recognition internal thread.
        // Dispatch to the main thread to update the internal barcode list.
        DispatchQueue.main.async {
            // Update the internal list
            self.allRecognizedBarcodes = allRecognizedBarcodes
        }
    }
}

extension ViewController: ListViewControllerDelegate {
    func listViewController(_ listViewController: ListViewController,
                            didFinishWithIntent intent: ListViewController.Intent) {
        switch intent {
        case .restartScanning:
            resetMode()
            self.shouldCameraStandby = true
            self.navigationController?.popViewController(animated: true)
        case .resumeScanning:
            self.shouldCameraStandby = true
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ViewController: BarcodeCountViewDelegate {
    func barcodeCountView(_ view: BarcodeCountView,
                          brushForRecognizedBarcode trackedBarcode: TrackedBarcode) -> Brush? {
        // Return the default brush
        return BarcodeCountView.defaultRecognizedBrush
    }

    func barcodeCountView(_ view: BarcodeCountView,
                          brushForUnrecognizedBarcode trackedBarcode: TrackedBarcode) -> Brush? {
        // Return the default brush
        return BarcodeCountView.defaultUnrecognizedBrush
    }

    func barcodeCountView(_ view: BarcodeCountView,
                          brushForRecognizedBarcodeNotInList trackedBarcode: TrackedBarcode) -> Brush? {
        // Return the default brush
        return BarcodeCountView.defaultNotInListBrush
    }

    func barcodeCountView(_ view: BarcodeCountView,
                          didTapRecognizedBarcode trackedBarcode: TrackedBarcode) {
        // Not used
    }

    func barcodeCountView(_ view: BarcodeCountView,
                          didTapUnrecognizedBarcode trackedBarcode: TrackedBarcode) {
        // Not used
    }

    func barcodeCountView(_ view: BarcodeCountView,
                          didTapRecognizedBarcodeNotInList trackedBarcode: TrackedBarcode) {
        // Not used
    }

    func barcodeCountView(_ view: BarcodeCountView,
                          didTapFilteredBarcode trackedBarcode: TrackedBarcode) {
        // Not used
    }
}

extension ViewController: BarcodeCountViewUIDelegate {
    func listButtonTapped(for view: BarcodeCountView) {
        // Show the current progress but the order is not completed
        showList(isOrderCompleted: false)
    }

    func exitButtonTapped(for view: BarcodeCountView) {
        // The order is completed
        showList(isOrderCompleted: true)
    }
}

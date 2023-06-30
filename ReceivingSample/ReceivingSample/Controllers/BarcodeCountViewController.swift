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

import ScanditBarcodeCapture

class BarcodeCountViewController: UIViewController {

    // Inject the context
    var context: DataCaptureContext!
    var itemsTableViewModel: ItemsTableViewModel?
    private var camera: Camera?
    private var barcodeCount: BarcodeCount!
    private var barcodeCountView: BarcodeCountView!
    private var currentlyRecognizedBarcodeIds = Set<Int>()
    private var shouldCameraStandby = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Make sure that Barcode Count mode is enabled
        barcodeCountView.prepareScanning(with: context)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on. To be notified when the camera is completely on, pass non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // We are navigating back to SparkScan, stop BarcodeCount
        if isMovingFromParent {
            barcodeCountView.stopScanning()
        }
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

    @objc func didEnterBackground() {
        resetMode()
    }

    func setupRecognition() {
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
        // sample we enable just Code128 and DataMatrix. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        Set<Symbology>([.ean13UPCA, .ean8, .upce, .code39, .code128]).forEach {
            settings.set(symbology: $0, enabled: true)
        }

        // Create new barcode count mode with the settings from above.
        barcodeCount = BarcodeCount(context: context, settings: settings)
        // Inject the barcodes already scanned so the list button badge is updated.
        if let itemsTableViewModel {
            barcodeCount.setAdditionalBarcodes(itemsTableViewModel.allBarcodes())
        }

        // Register self as a listener to monitor the barcode count session.
        barcodeCount.add(self)

        // To visualize the Barcode Count UI you need to create a BarcodeCountView and add it to the view hierarchy.
        // BarcodeCountView is designed to be displayed full screen.
        barcodeCountView = BarcodeCountView(frame: view.bounds, context: context, barcodeCount: barcodeCount)
        barcodeCountView.shouldShowClearHighlightsButton = true
        view.addSubview(barcodeCountView)

        barcodeCountView.uiDelegate = self
        // Use single scan button to go back to SparkScan
        barcodeCountView.shouldShowSingleScanButton = true
    }

    private func showList(isOrderCompleted: Bool) {
        shouldCameraStandby = false
        performSegue(withIdentifier: "ShowItemList", sender: NSNumber(value: isOrderCompleted))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let listVC = segue.destination as? ItemsTableViewController {
            listVC.viewModel = itemsTableViewModel
            listVC.scanningCompleted = (sender as? NSNumber)?.boolValue ?? false
            listVC.delegate = self
        }
    }

    func resetMode() {
        // Reset the mode but don't clear the scanned items
        currentlyRecognizedBarcodeIds.removeAll()
        barcodeCount.reset()
        if let itemsTableViewModel {
            barcodeCount.setAdditionalBarcodes(itemsTableViewModel.allBarcodes())
        }
    }

    func restartMode() {
        // Reset the mode and clear the list
        resetMode()
        itemsTableViewModel?.clear()
        barcodeCount.setAdditionalBarcodes([])
    }
}

// MARK: - BarcodeCountListener

extension BarcodeCountViewController: BarcodeCountListener {
    func barcodeCount(_ barcodeCount: BarcodeCount,
                      didScanIn session: BarcodeCountSession,
                      frameData: FrameData) {
        // Gather all the recognized barcodes
        let recognizedBarcodes = session.recognizedBarcodes.values
        // This method is invoked from a recognition internal thread.
        // Dispatch to the main thread to update the internal barcode list.
        DispatchQueue.main.async {
            // Update the internal list
            for trackedBarcode in recognizedBarcodes
            where !self.currentlyRecognizedBarcodeIds.contains(trackedBarcode.identifier) {
                self.currentlyRecognizedBarcodeIds.insert(trackedBarcode.identifier)
                self.itemsTableViewModel?.addBarcode(trackedBarcode.barcode)
            }
        }
    }
}

// MARK: - BarcodeCountViewUIDelegate

extension BarcodeCountViewController: BarcodeCountViewUIDelegate {
    func listButtonTapped(for view: BarcodeCountView) {
        // Show the current progress but the order is not completed
        showList(isOrderCompleted: false)
    }

    func exitButtonTapped(for view: BarcodeCountView) {
        // The order is completed
        showList(isOrderCompleted: true)
    }

    func singleScanButtonTapped(for view: BarcodeCountView) {
        // Go back to SparkScan
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - ItemsTableViewControllerDelegate

extension BarcodeCountViewController: ItemsTableViewControllerDelegate {
    func userWantsToResumeScanning() {
        shouldCameraStandby = true
    }

    func userWantsToRestartScanning() {
        shouldCameraStandby = true
        restartMode()
    }
}

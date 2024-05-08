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

import UIKit
import ScanditBarcodeCapture

struct Result {
    let data: String
    let symbology: Symbology
}

class ScanViewController: UIViewController {

    // The DataCaptureContext that the current BarcodeSelection mode is attached to.
    private var context: DataCaptureContext!
    // The wrapper over the device's camera
    private var camera: Camera?
    // The current BarcodeSelection.
    private var barcodeSelection: BarcodeSelection!
    // DataCaptureView displays the camera preview and the additional UI to guide the user through
    // the capture process.
    private var captureView: DataCaptureView!
    // Overlays provide UI to aid the user in the capture process and need to be attached
    // to DataCaptureView.
    private var overlay: BarcodeSelectionBasicOverlay!
    // The list of selected barcodes to show in the results screen.
    private var selectedResults: [Result] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupBarcodesSelectionGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch the camera on. The camera frames will be sent to the modes connected to the
        // DataCaptureContext for processing.
        // Additionally the preview will appear on the screen. The camera is started asynchronously,
        // and you may notice a small delay before the preview appears.
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Put the camera in standby mode to stop streaming frames, but allowing for a faster
        // restart compared to switching it completely off.
        // The camera is stopped asynchronously.
        // Check https://docs.scandit.com/data-capture-sdk/android/camera-advanced.html#camera-advanced-standby
        // for more info.
        camera?.switch(toDesiredState: .standby)
    }

    private func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommendedCameraSettings = BarcodeCapture.recommendedCameraSettings
        // For this use case, we recommend using 4k resolution.
        recommendedCameraSettings.preferredResolution = .uhd4k
        camera?.apply(recommendedCameraSettings)

        // The barcode selection process is configured through barcode selection settings
        // and are then applied to the barcode selection instance that manages barcode recognition.
        let barcodeSelectionSettings = BarcodeSelectionSettings()
        // Selection type is used to define the method that BarcodeSelection will use to select barcodes.
        // When the freezeBehavior is set to `.manual`, the frame preview can only be frozen manually
        // by double tapping anywhere on the screen. When the tapBehavior is set to `.toggleSelection`,
        // tapping an unselected barcode selects it, tapping an already selected barcode will unselect it.
        barcodeSelectionSettings.selectionType = BarcodeSelectionTapSelection(freezeBehavior: .manual,
                                                                              tapBehavior: .toggleSelection)

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        barcodeSelectionSettings.set(symbology: .ean13UPCA, enabled: true)
        barcodeSelectionSettings.set(symbology: .ean8, enabled: true)
        barcodeSelectionSettings.set(symbology: .upce, enabled: true)
        barcodeSelectionSettings.set(symbology: .code128, enabled: true)
        barcodeSelectionSettings.set(symbology: .code39, enabled: true)

        // Create new barcode selection mode with the settings from above.
        barcodeSelection = BarcodeSelection(context: context, settings: barcodeSelectionSettings)

        // Register self as a listener to get informed whenever a new barcode is selected/unselected.
        barcodeSelection.addListener(self)

        // To visualize the on-going barcode selection process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        // Disable the zoom gesture.
        captureView.zoomGesture = nil
        // Disable the focus gesture.
        captureView.focusGesture = nil

        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = BarcodeSelectionBasicOverlay(barcodeSelection: barcodeSelection, view: captureView, style: .dot)
        overlay.frozenBackgroundColor = .clear
    }

    private func setupBarcodesSelectionGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(selectVisibleBarcodes))
        swipeGestureRecognizer.direction = .right
        captureView.addGestureRecognizer(swipeGestureRecognizer)
    }

    @objc private func selectVisibleBarcodes() {
        barcodeSelection.selectUnselectedBarcodes()
    }

    private func clearResults() {
        selectedResults = []
        barcodeSelection.reset()
    }

    @IBSegueAction func prepareForSegue(_ coder: NSCoder) -> UINavigationController? {
        let navigationController = NavigationController(coder: coder)
        guard let resultViewController = navigationController?.topViewController as? ResultsViewController else {
            return nil
        }
        resultViewController.delegate = self
        resultViewController.results = selectedResults
        return navigationController
    }
}

extension ScanViewController: BarcodeSelectionListener {
    func barcodeSelection(_ barcodeSelection: BarcodeSelection,
                          didUpdateSelection session: BarcodeSelectionSession,
                          frameData: FrameData?) {
        // Implement to handle selection updates.
        // This callback is executed on the background thread.
        // In this sample we just need to keep track of what codes are being selected to then
        // display them in the results screen.
        let results = session.selectedBarcodes.map {
            Result(data: $0.data ?? "[binary result]",
                   symbology: $0.symbology)
        }
        self.selectedResults = results
    }
}

extension ScanViewController: ResultViewControllerDelegate {
    func clearButtonTapped() {
        clearResults()
    }
}

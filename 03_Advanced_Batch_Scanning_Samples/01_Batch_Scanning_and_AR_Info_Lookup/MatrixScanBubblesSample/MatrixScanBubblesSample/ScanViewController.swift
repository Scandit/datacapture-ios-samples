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

class ScanViewController: UIViewController {

    private enum Constants {
        static let barcodeToScreenTresholdRation: CGFloat = 0.1
        static let shelfCount = 4
        static let backRoomCount = 8
    }

    private lazy var context = {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        return DataCaptureContext.sharedInstance
    }()
    private var camera: Camera?
    private var barcodeBatch: BarcodeBatch!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeBatchBasicOverlay!
    private var advancedOverlay: BarcodeBatchAdvancedOverlay!
    @IBOutlet weak var freezeButton: UIButton!

    private var overlays: [Int: StockOverlay] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unfreeze()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        freeze()
    }

    private func setupRecognition() {
        // Use the default camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeBatch mode as default settings.
        // The preferred resolution is automatically chosen, which currently defaults to HD on all devices.
        // Setting the preferred resolution to full HD helps to get a better decode range.
        let cameraSettings = BarcodeBatch.recommendedCameraSettings
        cameraSettings.preferredResolution = .uhd4k
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
        captureView.context = context
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)

        // Add a Barcode Batch overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback. The overlay is automatically added
        // to the view.
        overlay = BarcodeBatchBasicOverlay(barcodeBatch: barcodeBatch, view: captureView, style: .dot)

        // Add another Barcode Batch overlay to the data capture view to render other views. The overlay is
        // automatically added to the view.
        advancedOverlay = BarcodeBatchAdvancedOverlay(barcodeBatch: barcodeBatch, view: captureView)
        advancedOverlay.delegate = self
    }

    @IBAction func toggleFreezing(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            freeze()
        } else {
            unfreeze()
        }
    }

    private func freeze() {
        // First, disable Barcode Batch to stop processing frames.
        barcodeBatch.isEnabled = false
        // Switch the camera off to stop streaming frames. The camera is stopped asynchronously.
        camera?.switch(toDesiredState: .off)
    }

    private func unfreeze() {
        // First, enable Barcode Batch to resume processing frames.
        barcodeBatch.isEnabled = true
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        camera?.switch(toDesiredState: .on)
    }

    private func stockOverlay(for trackedCode: TrackedBarcode) -> StockOverlay {
        let identifier = trackedCode.identifier
        var overlay: StockOverlay
        if overlays.keys.contains(identifier), let existingOverlay = overlays[identifier] {
            overlay = existingOverlay
        } else {
            // Get the information you want to show from your back end system/database.
            overlay = StockOverlay(
                with: StockModel(
                    shelfCount: Constants.shelfCount,
                    backroomCount: Constants.backRoomCount,
                    barcodeData: trackedCode.barcode.data
                )
            )
            overlays[identifier] = overlay
        }
        overlay.isHidden = !canShowOverlay(of: trackedCode)
        return overlay
    }

    private func canShowOverlay(of trackedCode: TrackedBarcode) -> Bool {
        let captureViewWidth = captureView.frame.width

        // If the barcode is wider than the desired percent of the data capture view's width,
        // show it to the user.
        let width = trackedCode.location.width(in: captureView)
        return (width / captureViewWidth) >= Constants.barcodeToScreenTresholdRation
    }
}

// MARK: - BarcodeBatchListener

extension ScanViewController: BarcodeBatchListener {
    // This function is called whenever objects are updated and it's the right place to react to the tracking results.
    func barcodeBatch(
        _ barcodeBatch: BarcodeBatch,
        didUpdate session: BarcodeBatchSession,
        frameData: FrameData
    ) {
        let removedTrackedBarcodes = session.removedTrackedBarcodes
        let trackedBarcodes = session.trackedBarcodes.values
        DispatchQueue.main.async {
            if !self.barcodeBatch.isEnabled {
                return
            }
            for identifier in removedTrackedBarcodes {
                self.overlays.removeValue(forKey: identifier)
            }
            for trackedCode in trackedBarcodes {
                guard let code = trackedCode.barcode.data, !code.isEmpty else {
                    return
                }

                self.overlays[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
            }
        }
    }
}

// MARK: - BarcodeBatchAdvancedOverlayDelegate

extension ScanViewController: BarcodeBatchAdvancedOverlayDelegate {
    func barcodeBatchAdvancedOverlay(
        _ overlay: BarcodeBatchAdvancedOverlay,
        viewFor trackedBarcode: TrackedBarcode
    ) -> UIView? {
        stockOverlay(for: trackedBarcode)
    }

    func barcodeBatchAdvancedOverlay(
        _ overlay: BarcodeBatchAdvancedOverlay,
        anchorFor trackedBarcode: TrackedBarcode
    ) -> Anchor {
        // The offset of our overlay will be calculated from the top center anchoring point.
        .topCenter
    }

    func barcodeBatchAdvancedOverlay(
        _ overlay: BarcodeBatchAdvancedOverlay,
        offsetFor trackedBarcode: TrackedBarcode
    ) -> PointWithUnit {
        // We set the offset's height to be equal of the 100 percent of our overlay.
        // The minus sign means that the overlay will be above the barcode.
        PointWithUnit(
            x: FloatWithUnit(value: 0, unit: .fraction),
            y: FloatWithUnit(value: -1, unit: .fraction)
        )
    }
}

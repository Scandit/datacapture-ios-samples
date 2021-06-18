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
import UIKit

@objc protocol SplitViewScannerViewControllerDelegate: AnyObject {
    func splitViewScannerViewController(_ splitViewScannerViewController: SplitViewScannerViewController,
                                        didScan scanResult: ScanResult)
}

class SplitViewScannerViewController: UIViewController {

    private enum Constants {
        static let splitViewScanTimeout: TimeInterval = 10
    }

    weak var delegate: SplitViewScannerViewControllerDelegate?

    @IBOutlet weak var tapToContinueLabel: UILabel!

    private var captureView: DataCaptureView!
    private var context: DataCaptureContext!
    private var camera = Camera.default
    private var barcodeCapture: BarcodeCapture!

    private var scanTimeoutTimer: Timer?

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

        scanTimeoutTimer = createScanTimeoutTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode tracking as well.
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)

        scanTimeoutTimer?.invalidate()
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

        // Setting the code duplicate filter to one means that the scanner won't report the same code as recognized
        // for one second once it's recognized.
        barcodeCaptureSettings.codeDuplicateFilter = 1

        // By setting the radius to zero, the barcode's frame has to contain the point of interest.
        // The point of interest is at the center of the data capture view by default, as in this case.
        barcodeCaptureSettings.locationSelection = RadiusLocationSelection(radius: .zero)

        // Create data capture context using your license key and set the camera as the frame source.
        context = DataCaptureContext.licensed
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommendedCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // Register self as a listener to get informed whenever the status of the license changes.
        context.addListener(self)

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: barcodeCaptureSettings)

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: .zero)

        // Add a barcode capture overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback. The overlay is automatically added
        // to the view.
        let barcodeCaptureOverlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, view: captureView)

        // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of
        // feedback. With 6.10 we will introduce this visual treatment as a new style for the overlay.
        let brush = Brush(fill: .clear, stroke: .white, strokeWidth: 3)
        barcodeCaptureOverlay.brush = brush

        // We have to add the laser line viewfinder to the overlay.
        let viewFinder = LaserlineViewfinder(style: .animated)
        viewFinder.width = FloatWithUnit(value: 0.9, unit: .fraction)
        barcodeCaptureOverlay.viewfinder = viewFinder

        // We are resizing the capture view to not to take the whole screen,
        // but just fill it's parent, both horizontally and vertically.
        view.addSubview(captureView)
        captureView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureView.topAnchor.constraint(equalTo: view.topAnchor),
            captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.sendSubviewToBack(captureView)
    }

    @IBAction func continueScanning(_ sender: Any) {
        tapToContinueLabel.isHidden = true
        barcodeCapture.isEnabled = true
        scanTimeoutTimer?.invalidate()
        scanTimeoutTimer = createScanTimeoutTimer()
    }

    @objc func pauseScanning() {
        barcodeCapture.isEnabled = false
        tapToContinueLabel.isHidden = false
    }

    private func createScanTimeoutTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: Constants.splitViewScanTimeout,
                                    target: self,
                                    selector: #selector(pauseScanning),
                                    userInfo: nil,
                                    repeats: false)
    }
}

extension SplitViewScannerViewController: BarcodeCaptureListener {
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcodes.first else {
            return
        }

        // The barcode capture listener callbacks are running on a background queue,
        // so to make any changes to the UI, we need to switch to the main queue.
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.scanTimeoutTimer?.invalidate()
            self.scanTimeoutTimer = self.createScanTimeoutTimer()
            let scanResult = ScanResult(with: barcode.data, symbology: barcode.symbology)
            self.delegate?.splitViewScannerViewController(self, didScan: scanResult)
        }
    }
}

extension SplitViewScannerViewController: DataCaptureContextListener {
    func context(_ context: DataCaptureContext, didChange contextStatus: ContextStatus) {
        // This function is executed from a background queue, so we need to switch to the main queue
        // before doing any work with our timer.
        DispatchQueue.main.async { [weak self] in
            self?.scanTimeoutTimer?.invalidate()
            if !contextStatus.isValid {
                // No need to create a timer in case we have an invalid license.
                self?.scanTimeoutTimer = nil
            } else {
                self?.scanTimeoutTimer = self?.createScanTimeoutTimer()
            }
        }
    }

    func context(_ context: DataCaptureContext, didAdd mode: DataCaptureMode) {}

    func context(_ context: DataCaptureContext, didRemove mode: DataCaptureMode) {}

    func context(_ context: DataCaptureContext, didChange frameSource: FrameSource?) {}
}

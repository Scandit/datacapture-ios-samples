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
import ScanditCaptureCore
import UIKit

class SearchViewController: UIViewController {

    private enum Constants {
        static let presentFindViewControllerSegue = "presentFindViewControllerSegue"
    }

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!

    private var displayedData: String?
    private var selectedSymbology: Symbology?

    @IBOutlet weak var dismissOverlayButton: UIButton!
    @IBOutlet weak var scannedBarcodeOverlay: UIView!
    @IBOutlet weak var scannedBarcodeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SEARCH & FIND"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        scannedBarcodeOverlay.layer.cornerRadius = 16
        scannedBarcodeOverlay.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        setupRecognition()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Make sure barcode capture is the only mode associated with the context.
        context.removeAllModes()
        context.addMode(barcodeCapture)
        // Enable barcode capture to resume processing frames.
        barcodeCapture.isEnabled = true
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Disable barcode capture to stop processing frames.
        barcodeCapture.isEnabled = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FindViewController {
            guard let displayedData else { return }
            // Create the Barcode Find Item with the scanned barcode data.
            // If you have more information about the product (such as name or image) that you want
            // to display, you can pass a BarcodeFindItemContent object to the content parameter below.
            let searchOptions = BarcodeFindItemSearchOptions(barcodeData: displayedData)
            let itemToFind = BarcodeFindItem(searchOptions: searchOptions, content: nil)

            destination.context = context
            destination.itemToFind = itemToFind
            destination.symbology = selectedSymbology
        }
    }

    @IBAction func searchButtonDidTouchUpInside(_ sender: Any) {
        guard displayedData != nil else { return }
        scannedBarcodeLabel.text = nil
        scannedBarcodeOverlay.isHidden = true
        dismissOverlayButton.isHidden = true
        self.performSegue(withIdentifier: Constants.presentFindViewControllerSegue,
                          sender: self)
    }

    @IBAction func dismissOverlayButtonDidTouchUpInside(_ sender: Any) {
        scannedBarcodeOverlay.isHidden = true
        dismissOverlayButton.isHidden = true
        displayedData = nil
        selectedSymbology = nil
    }

    @IBAction func unwindFromSearchViewController(segue: UIStoryboardSegue) {}

    private func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the default camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode as default settings.
        // The preferred resolution is automatically chosen, which currently defaults to HD on all devices.
        // Setting the preferred resolution to full HD helps to get a better decode range.
        let cameraSettings = BarcodeCapture.recommendedCameraSettings
        cameraSettings.preferredResolution = .fullHD
        camera?.apply(cameraSettings, completionHandler: nil)

        // The barcode capture process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode capture.
        let settings = BarcodeCaptureSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)

        // By setting the radius to zero, the barcode's frame has to contain the point of interest.
        // The point of interest is at the center of the data capture view by default, as in this case.
        settings.locationSelection = RadiusLocationSelection(radius: .zero)

        // Setting the code duplicate filter to one means that the scanner won't report the same code as recognized
        // for one second, once it's recognized.
        settings.codeDuplicateFilter = 1

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: settings)

        // Register self as a listener to get informed of captured barcodes.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode tracking process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, view: captureView, style: .frame)
        overlay.brush = Brush.scanned
        overlay.viewfinder = AimerViewfinder()
    }
}

// MARK: - BarcodeTrackingListener

extension SearchViewController: BarcodeCaptureListener {
    // This function is called whenever objects are updated and it's the right place to react to the tracking results.
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcode else { return }
        DispatchQueue.main.async {
            self.scannedBarcodeLabel.text = barcode.data
            self.displayedData = barcode.data
            self.selectedSymbology = barcode.symbology
            if self.scannedBarcodeOverlay.isHidden {
                self.scannedBarcodeOverlay.isHidden = false
                self.view.bringSubviewToFront(self.scannedBarcodeOverlay)
                self.dismissOverlayButton.isHidden = false
                self.view.bringSubviewToFront(self.dismissOverlayButton)
            }
        }
    }
}

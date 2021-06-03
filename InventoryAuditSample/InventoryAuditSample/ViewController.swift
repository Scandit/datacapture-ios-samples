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

class ViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeTracking: BarcodeTracking!
    private var barcodeTrackingOverlay: BarcodeTrackingAdvancedOverlay!
    private var captureView: DataCaptureView!

    @IBOutlet weak var freezeButton: UIButton! {
        didSet {
            freezeButton.backgroundColor = .white
        }
    }

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
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommendedCameraSettings = BarcodeTracking.recommendedCameraSettings
        recommendedCameraSettings.preferredResolution = .uhd4k
        camera?.apply(recommendedCameraSettings)

        // The barcode capturing process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let settings = BarcodeTrackingSettings(scenario: .a)

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable the QR symbology. In your own app ensure that you only enable the symbologies that your app
        // requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .upce, enabled: true)

        barcodeTracking = BarcodeTracking(context: context, settings: settings)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.bringSubviewToFront(freezeButton)

        barcodeTrackingOverlay = BarcodeTrackingAdvancedOverlay(barcodeTracking: barcodeTracking, view: captureView)
        barcodeTrackingOverlay.delegate = self
    }

    @IBAction func didTapOnFreezeButton(_ sender: UIButton) {
        let isFreezed = sender.isSelected
        sender.isSelected.toggle()
        if isFreezed {
            unfreeze()
        } else {
            freeze()
        }
    }

    private func freeze() {
        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        barcodeTracking.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    private func unfreeze() {
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        barcodeTracking.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }
}

extension ViewController: BarcodeTrackingAdvancedOverlayDelegate {
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        viewFor trackedBarcode: TrackedBarcode) -> UIView? {
        guard let barcode = trackedBarcode.barcode.data else {
            return nil
        }
        let view = StockOverlay(frame: CGRect(x: 0, y: 0, width: 60, height: 66))
        view.bind(to: barcode)
        return view
    }

    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        anchorFor trackedBarcode: TrackedBarcode) -> Anchor {
        return .center
    }

    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        offsetFor trackedBarcode: TrackedBarcode) -> PointWithUnit {
        return PointWithUnit(x: FloatWithUnit(value: 0, unit: .dip),
                             y: FloatWithUnit(value: -1, unit: .fraction))
    }
}

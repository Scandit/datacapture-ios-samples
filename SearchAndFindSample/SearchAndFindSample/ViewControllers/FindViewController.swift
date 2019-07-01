/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import ScanditBarcodeCapture
import ScanditCaptureCore
import UIKit

class FindViewController: UIViewController {

    private enum Constants {
        static let unWindToSearchSegueIdentifier = "unWindToSearchSegueIdentifier"
    }

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeTracking: BarcodeTracking!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeTrackingBasicOverlay!

    @IBOutlet weak var scanningIndicatorView: BottomScanningIndicator!
    @IBOutlet weak var closeButton: UIButton!

    var symbology: Symbology!
    var selectedBarcodeData: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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

    private func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the default camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // The preferred resolution is automatically chosen, which currently defaults to HD on all devices. Setting the
        // preferred resolution to full HD helps to get a better decode range.
        let cameraSettings = CameraSettings()
        cameraSettings.preferredResolution = .fullHD
        camera?.apply(cameraSettings, completionHandler: nil)

        // The barcode tracking process is configured through barcode tracking settings
        // and are then applied to the barcode tracking instance that manages barcode tracking.
        let settings = BarcodeTrackingSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: symbology, enabled: true)

        // Create new barcode tracking mode with the settings from above.
        barcodeTracking = BarcodeTracking(context: context, settings: settings)

        // To visualize the on-going barcode tracking process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(for: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(scanningIndicatorView)

        overlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking, for: captureView)
        overlay.delegate = self
    }
}

extension FindViewController: BarcodeTrackingBasicOverlayDelegate {
    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay,
                                     brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        if trackedBarcode.barcode.data == selectedBarcodeData {
            return Brush.matching
        } else {
            return Brush.nonMatching
        }
    }

    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay,
                                     didTap trackedBarcode: TrackedBarcode) {}
}

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

class MainViewController: UIViewController {

    private lazy var barcodeCaptureSettings = {
        let settings = BarcodeCaptureSettings()
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true)
        return settings
    }()
    private var camera: Camera?
    private var context: DataCaptureContext?
    private var captureView: DataCaptureView?
    private var barcodeCapture: BarcodeCapture?

    override func viewWillAppear(_ animated: Bool) {
        setupBarcodeCapture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        captureView?.isHidden = true
    }

    private func setupBarcodeCapture() {
        let camera = Camera.default
        let cameraSettings = BarcodeCapture
            .recommendedCameraSettings
        cameraSettings.preferredResolution = .uhd4k
        camera?.apply(cameraSettings)
        camera?.switch(toDesiredState: .on)

        let context = DataCaptureContext.licensed
        context.setFrameSource(camera)

        let barcodeCapture = BarcodeCapture(
            context: context,
            settings: barcodeCaptureSettings)
        barcodeCapture.addListener(self)

        captureView?.removeFromSuperview()
        let captureView = DataCaptureView(
            context: context,
            frame: .zero)

        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        captureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureView.topAnchor.constraint(equalTo: view.topAnchor),
            captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.camera = camera
        self.context = context
        self.barcodeCapture = barcodeCapture
        self.captureView = captureView

        let overlay = BarcodeCaptureOverlay(
            barcodeCapture: barcodeCapture,
            view: captureView,
            style: .frame)
        overlay.viewfinder = RectangularViewfinder(
            style: .square,
            lineStyle: .light)
    }

    private func reset() {
        camera?.switch(toDesiredState: .on)
        barcodeCapture?.isEnabled = true
    }

    private func stopScanning() {
        camera?.switch(toDesiredState: .off)
        barcodeCapture?.isEnabled = false
    }

    private func makeIdCaptureViewController() -> IdCaptureViewController {
        let viewController = storyboard?
            .instantiateViewController(identifier: "IdCaptureViewController")
        as! IdCaptureViewController

        viewController.modalPresentationStyle = .fullScreen

        return viewController
    }

    private func presentIdCaptureViewController() {
        navigationController?.pushViewController(makeIdCaptureViewController(),
                                                 animated: true)
    }

    private func presentAgeVerificationInstruction() {
        let deliveryResultViewController = DeliveryResultViewController.instantiateFrom(storyboard: storyboard)
        deliveryResultViewController.configureWith(.idRequired)
        deliveryResultViewController.mainButtonTapped = { [weak self] in
            self?.presentIdCaptureViewController()
        }
        present(deliveryResultViewController, animated: true, completion: nil)
    }
}

extension MainViewController: BarcodeCaptureListener {
    public func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                               didScanIn session: BarcodeCaptureSession,
                               frameData: FrameData) {
        guard session.newlyRecognizedBarcode?.data != nil else {
            return
        }
        stopScanning()
        DispatchQueue.main.async { [weak self] in
            self?.presentAgeVerificationInstruction()
        }
    }
}

extension DeliveryResultViewController {
    static func instantiateFrom(storyboard: UIStoryboard?) -> DeliveryResultViewController {
        let deliveryResultViewController = storyboard?
            .instantiateViewController(identifier: "DeliveryResultViewController")
        as! DeliveryResultViewController

        let transitionManager = TransitionManager()
        deliveryResultViewController.transitioningDelegate = transitionManager
        deliveryResultViewController.transitionManager = transitionManager
        deliveryResultViewController.modalPresentationStyle = .custom

        return deliveryResultViewController
    }
}

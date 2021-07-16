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

import ScanditCaptureCore
import ScanditIdCapture

class IdCaptureViewController: UIViewController {

    enum Mode: Int {
        case barcode
        case mrz
        case viz
    }

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var idCapture: IdCapture!
    private var captureView: DataCaptureView!
    private var overlay: IdCaptureOverlay!

    private var isScanningBackSide: Bool = false

    private lazy var modeControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Barcode", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "MRZ", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "Viz", at: 2, animated: false)
        segmentedControl.addTarget(self, action: #selector(didChangeMode(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        idCapture.reset()
        isScanningBackSide = false
        idCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable id capture as well.
        idCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    private func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the IdCapture mode.
        let recommendedCameraSettings = IdCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // To visualize the on-going id capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        captureView.addSubview(modeControl)
        modeControl.bottomAnchor.constraint(equalTo: captureView.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -20).isActive = true
        modeControl.centerXAnchor.constraint(equalTo: captureView.centerXAnchor).isActive = true
        modeControl.selectedSegmentIndex = 0
        configure(mode: .barcode)
    }

    private func configure(mode: IdCaptureViewController.Mode) {
        context.removeAllModes()
        isScanningBackSide = false

        let settings = IdCaptureSettings()
        switch mode {
        case .barcode:
            configureBarcodeMode(settings: settings)
        case .mrz:
            configureMRZMode(settings: settings)
        case .viz:
            configureVIZMode(settings: settings)
        }

        idCapture = IdCapture(context: context, settings: settings)
        idCapture.addListener(self)

        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        overlay.idLayoutStyle = .square
    }

    @objc
    private func didChangeMode(_ sender: UISegmentedControl) {
        guard let mode = Mode(rawValue: sender.selectedSegmentIndex) else { fatalError("Unknown mode") }
        configure(mode: mode)
    }

    private func configureBarcodeMode(settings: IdCaptureSettings) {
        settings.supportedDocuments = [.aamvaBarcode, .argentinaIdBarcode, .colombiaIdBarcode,
                                       .southAfricaDLBarcode, .southAfricaIdBarcode, .ususIdBarcode]
    }

    private func configureVIZMode(settings: IdCaptureSettings) {
        settings.supportedDocuments = [.dlVIZ, .idCardVIZ]
        settings.resultShouldContainImage(true, for: .face)
        settings.resultShouldContainImage(true, for: .idBack)
        settings.resultShouldContainImage(true, for: .idFront)
        settings.supportedSides = .frontAndBack
    }

    private func configureMRZMode(settings: IdCaptureSettings) {
        settings.supportedDocuments = [.visaMRZ, .passportMRZ, .idCardMRZ, .swissDLMRZ]
    }
}

extension IdCaptureViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCaptureIn session: IdCaptureSession, frameData: FrameData) {
        guard let capturedId = session.newlyCapturedId else {
            return
        }

        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false

        // Viz documents support multiple sides scanning.
        // In case the back side is supported and not yet captured we inform the user about the feature.
        if let vizResult = capturedId.vizResult,
           vizResult.isBackSideCaptureSupported,
           vizResult.capturedSides == .frontOnly {

            // Until the back side is scanned, IdCapture will keep reporting the front side.
            // Here if we are looking for the back side we just return.
            guard !isScanningBackSide else {
                idCapture.isEnabled = true
                return
            }
            DispatchQueue.main.async {
                self.displayBackOfCardAlert(capturedId: capturedId)
            }

            return
        }

        // We could be scanning for the

        // Show the result
        DispatchQueue.main.async {
            self.display(capturedId: capturedId)
        }
    }

    func idCapture(_ idCapture: IdCapture,
                   didFailWithError error: Error,
                   session: IdCaptureSession,
                   frameData: FrameData) {

        // Implement to handle an error encountered during the capture process.
        // The error message can be retrieved from the Error localizedDescription.
    }

    func display(capturedId: CapturedId) {
        let detail = ResultViewController(capturedId: capturedId)
        self.navigationController?.pushViewController(detail, animated: true)
    }

    func displayBackOfCardAlert(capturedId: CapturedId) {
        let message = "This documents has additional data in the visual inspection zone on the back of the card"
        let alertController = UIAlertController(title: "Back of Card",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Scan",
                                                style: .default,
                                                handler: { _ in
                                                    self.isScanningBackSide = true
                                                    self.idCapture.isEnabled = true
                                                }))
        alertController.addAction(UIAlertAction(title: "Skip",
                                                style: .cancel,
                                                handler: { _ in
                                                    self.display(capturedId: capturedId)
                                                }))

        present(alertController, animated: true, completion: nil)
    }
}

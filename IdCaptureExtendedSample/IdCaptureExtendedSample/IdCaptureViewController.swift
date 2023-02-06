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

    enum Mode: String, CaseIterable {

        case barcode = "Barcode"
        case mrz = "MRZ"
        case viz = "VIZ"

    }

    private enum Constants {
        static let modeCollectionHeight: CGFloat = 80
    }

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var idCapture: IdCapture!
    private var captureView: DataCaptureView!
    private var overlay: IdCaptureOverlay!

    private var isScanningBackSide: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupModeCollection()
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
        captureView = DataCaptureView(context: context, frame: .zero)
        view.addSubview(captureView)
        captureView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.modeCollectionHeight)
        ])
        configure(mode: .barcode)
    }

    private func setupModeCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let modeCollection = ModeCollectionViewController(collectionViewLayout: layout)
        modeCollection.items = Mode.allCases.map(\.rawValue)
        addChild(modeCollection)
        view.addSubview(modeCollection.view)
        modeCollection.view.translatesAutoresizingMaskIntoConstraints = false
        modeCollection.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        modeCollection.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        modeCollection.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        modeCollection.view.heightAnchor.constraint(equalToConstant: Constants.modeCollectionHeight).isActive = true
        modeCollection.delegate = self
        modeCollection.selectItem(atIndex: 0)
    }

    private func configure(mode: IdCaptureViewController.Mode) {
        context.removeAllModes()
        idCapture?.removeListener(self)
        if overlay != nil {
            captureView?.removeOverlay(overlay)
        }
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
        overlay.idLayoutStyle = .rounded
    }

    private func configureBarcodeMode(settings: IdCaptureSettings) {
        settings.supportedDocuments = [
            .aamvaBarcode,
            .argentinaIdBarcode,
            .colombiaIdBarcode,
            .colombiaDlBarcode,
            .southAfricaDLBarcode,
            .southAfricaIdBarcode,
            .ususIdBarcode
        ]
    }

    private func configureVIZMode(settings: IdCaptureSettings) {
        settings.supportedDocuments = [.dlVIZ, .idCardVIZ]
        settings.resultShouldContainImage(true, for: .face)
        settings.resultShouldContainImage(true, for: .idBack)
        settings.resultShouldContainImage(true, for: .idFront)
        settings.supportedSides = .frontAndBack
    }

    private func configureMRZMode(settings: IdCaptureSettings) {
        settings.supportedDocuments = [
            .visaMRZ,
            .passportMRZ,
            .idCardMRZ,
            .swissDLMRZ,
            .chinaExitEntryPermitMRZ,
            .chinaMainlandTravelPermitMRZ,
            .chinaOneWayPermitBackMRZ,
            .chinaOneWayPermitFrontMRZ,
            .apecBusinessTravelCardMRZ
        ]
    }
}

extension IdCaptureViewController: ModeCollectionViewControllerDelegate {

    func selectedItem(atIndex index: Int) {
        configure(mode: Mode.allCases[index])
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

    func idCapture(_ idCapture: IdCapture, didRejectIn session: IdCaptureSession, frameData: FrameData) {
        // Implement to handle documents recognized in a frame, but rejected.
        // A document or its part is considered rejected when (a) it's valid, but not enabled in the settings,
        // (b) it's a barcode of a correct symbology or a Machine Readable Zone (MRZ),
        // but the data is encoded in an unexpected/incorrect format.

        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false
        showAlert(message: "Document not supported", completion: {
            // Resume the idCapture.
            idCapture.isEnabled = true
        })
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
        let message = "This document has additional data on the back of the card"
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

    func showAlert(title: String? = nil, message: String? = nil, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion()
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }

}

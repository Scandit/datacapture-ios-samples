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

final class DLScanningViewController: UIViewController {
    enum Hint: String {
        case front = "Align front of document"
        case back = "Align back of document"
        case verifying = "Verifying..."
    }

    private var context: DataCaptureContext!
    private var camera: Camera!
    private var captureView: DataCaptureView!
    private var idCapture: IdCapture!
    private var idCaptureSettings: IdCaptureSettings = IdCaptureSettings()
    private var overlay: IdCaptureOverlay!
    private var verificationRunner: DLScanningVerificationRunner!
    private var hintView = HintView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        camera.switch(toDesiredState: .on)
        showHint(.front)
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the IdCapture mode.
        let recommendedCameraSettings = IdCapture.recommendedCameraSettings
        camera.apply(recommendedCameraSettings)

        // To visualize the on-going id capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // We are interested in the front and back sides of the driver's licenses or id cards.
        idCaptureSettings.supportedDocuments = [ .dlVIZ, .idCardVIZ ]
        idCaptureSettings.supportedSides = .frontAndBack

        // We are requesting the capture result should contain face image.
        idCaptureSettings.resultShouldContainImage(true, for: .face)

        // Create new id capture mode with the chosen settings.
        idCapture = IdCapture(context: context, settings: idCaptureSettings)

        // Register self as a listener to get informed whenever a new id got recognized.
        idCapture.addListener(self)

        // Add an id capture overlay to the data capture view to render the location of captured ids on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        overlay.idLayoutStyle = .rounded

        // VerificationRunner is encapsulating verification process. See the class for more details.
        // We are initializing VerificationRunner to pass captured id later (see bellow)
        verificationRunner = DLScanningVerificationRunner(context)
    }
}

private extension DLScanningViewController {
    func showHint(_ hint: Hint) {
        if hintView.superview == nil {
            // Attach hint view
            view.addSubview(hintView)
            hintView.translatesAutoresizingMaskIntoConstraints = false

            let hintGuide = UILayoutGuide()
            view.addLayoutGuide(hintGuide)
            NSLayoutConstraint.activate([
                hintGuide.bottomAnchor.constraint(equalTo: view.centerYAnchor),
                hintGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                hintView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                hintView.centerYAnchor.constraint(equalTo: hintGuide.topAnchor)
            ])
        }

        hintView.text = hint.rawValue
    }
}

extension DLScanningViewController: IdCaptureListener {
    func idCapture(_ idCapture: IdCapture, didCaptureIn session: IdCaptureSession, frameData: FrameData) {
        // This is the main delegate call we receive from IdCapture on a new capture event.
        // We check if we have a new captured id, otherwise we return eagerly.
        guard let capturedId = session.newlyCapturedId else { return }

        // We are only interested in Driving Licenses from USA for this sample
        if capturedId.documentType == .drivingLicense, capturedId.issuingCountryISO == "USA" {
            DispatchQueue.main.async { [weak self] in self?.handleCapturedId(capturedId) }
        } else {
            // If the captured id is not a US Driving License we show an alert to the user.
            DispatchQueue.main.async { [weak self] in self?.handleUnexpectedId(capturedId) }
        }
    }

    func handleUnexpectedId(_ capturedId: CapturedId) {
        idCapture.isEnabled = false
        idCapture.reset()

        let controller = UIAlertController(
            title: "Error",
            message: "Document is not a US driver’s license",
            preferredStyle: .alert
        )
        controller.addAction(.init(title: "OK", style: .default, handler: { [unowned self] _ in
            self.idCapture.isEnabled = true
        }))
        present(controller, animated: true)
    }

    func handleCapturedId(_ capturedId: CapturedId) {
        // By checking captured sides on viz result, we are updating shown hint to the user
        if let vizResult = capturedId.vizResult, vizResult.capturedSides == .frontOnly {
            // If the captured sides are front only, we are updating hint and waiting for another capture event
            showHint(.back)
        } else if let vizResult = capturedId.vizResult, vizResult.capturedSides == .frontAndBack {
            // If the captured sides are front and back, we are starting the verification process.
            showHint(.verifying)
            handleCapturedIdResult(capturedId)
        } else {
            preconditionFailure("Unexpected captured id")
        }
    }

    func handleCapturedIdResult(_ capturedId: CapturedId) {
        // When the front and back capture is completed, we are passing the captured id to VerificationRunner
        // VerificationRunner will call back the closure passed in to let us know about the verification result
        verificationRunner.verify(capturedId: capturedId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                DispatchQueue.main.async { [weak self] in
                    self?.handleVerificationResult(capturedId, result: success)
                }
            case .failure(let failure): ()
                DispatchQueue.main.async { [weak self] in
                    self?.handleVerificationError(failure)
                }
            }
        }
    }

    func handleVerificationError(_ error: Error) {
        let message = """
An error was encountered when trying to connect to the verification \
service. Please make sure that the device has internet access and that \
your Scandit license key permits cloud verification.
"""
        let controller = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        controller.addAction(.init(title: "OK", style: .default))
        present(controller, animated: true)
    }

    func handleVerificationResult(_ capturedId: CapturedId, result: DLScanningVerificationResult) {
        guard let viewController = UIStoryboard(name: "DLScanningResultViewController", bundle: nil)
            .instantiateInitialViewController() as? DLScanningResultViewController else { return }
        viewController.transitioningDelegate = self
        viewController.prepare(capturedId, result)
        present(viewController, animated: true)
        // We disable IdCapture while presenting the results to prevent capturing while user is inpecting results.
        idCapture.isEnabled = false
    }
}

extension DLScanningViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is DLScanningResultViewController {
            // The result screen is dismissed, we are resetting and re-enabling the IdCapture to restart capture
            // process.
            idCapture.reset()
            idCapture.isEnabled = true
            showHint(.front)
        }

        return nil
    }
}

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

import ScanditCaptureCore
import ScanditIdCapture
import UIKit

struct DLScanningVerificationResult {
    let rejectionReason: RejectionReason?
    let frontReviewImage: UIImage?

    init(rejectionReason: RejectionReason?, frontReviewImage: UIImage? = nil) {
        self.rejectionReason = rejectionReason
        self.frontReviewImage = frontReviewImage
    }
}

final class DLScanningViewController: UIViewController {

    private enum Constants {
        enum Message {
            static let timeout =
                "Document capture failed. Make sure the document is well lit and free of glare. "
                + "Alternatively, try scanning another document"
            static let notSupported = "Document not supported. Try scanning another document"
            static let nonUsId = "Document is not a US driver’s license"
        }
    }

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var captureView: DataCaptureView!
    private var idCapture: IdCapture!
    private var idCaptureSettings: IdCaptureSettings = IdCaptureSettings()
    private var overlay: IdCaptureOverlay!
    private var hintView = HintView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecognition()

        hintView.isHidden = true
        view.addSubview(hintView)
        hintView.text = "Running verification checks"
        hintView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hintView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        camera?.switch(toDesiredState: .on)
    }

    func setupRecognition() {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        context = DataCaptureContext.shared
        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear above.
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

        // We are interested in Driver's Licenses from USA
        idCaptureSettings.acceptedDocuments = [DriverLicense(region: .us)]

        // We want to scan all zones and both sides
        idCaptureSettings.scanner = IdCaptureScanner(physicalDocument: FullDocumentScanner())

        // We are requesting the capture result should contain face and croppedDocument images.
        idCaptureSettings.setIncludeImage(true, for: .face)
        idCaptureSettings.setIncludeImage(true, for: .croppedDocument)

        // Enable built-in verification - documents with inconsistent data, forged AAMVA barcodes, or expired documents will be rejected
        idCaptureSettings.rejectInconsistentData = true
        idCaptureSettings.rejectForgedAamvaBarcodes = true
        idCaptureSettings.rejectExpiredIds = true

        // Create new id capture mode with the chosen settings.
        idCapture = IdCapture(context: context, settings: idCaptureSettings)

        // Register self as a listener to get informed whenever a new id got recognized.
        idCapture.addListener(self)

        // Add an id capture overlay to the data capture view to render the location of captured ids on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        overlay.idLayoutStyle = .rounded
    }
}

extension DLScanningViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        DispatchQueue.main.async { [weak self] in self?.handleCapturedId(capturedId) }
    }

    func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason: RejectionReason) {
        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false

        var message: String?
        switch reason {
        case .inconsistentData, .forgedAamvaBarcode, .documentExpired:
            // Handle verification failures by showing detailed verification results
            if let capturedId = capturedId {
                handleVerificationFailure(capturedId, reason: reason)
            }
        case .timeout:
            message = Constants.Message.timeout
        case .notAcceptedDocumentType:
            message = capturedId?.issuingCountry == .us ? Constants.Message.notSupported : Constants.Message.nonUsId
        default:
            // For any other rejection reasons, show standard error alert
            message = Constants.Message.notSupported
        }

        if let message = message {
            showAlert(
                title: "Error",
                message: message,
                completion: {
                    // Resume the idCapture.
                    idCapture.isEnabled = true
                }
            )
        }
    }

    func handleCapturedId(_ capturedId: CapturedId) {
        if let vizResult = capturedId.vizResult, vizResult.capturedSides == .frontAndBack {
            // Documents that reach this callback have passed all built-in verification checks
            // (expiration, data consistency, AAMVA barcode verification)
            handleVerificationSuccess(capturedId)
        } else {
            preconditionFailure("Unexpected captured id")
        }
    }

    func handleVerificationFailure(_ capturedId: CapturedId, reason: RejectionReason) {
        // Extract front review image if available for data consistency failures
        let frontReviewImage =
            reason == .inconsistentData ? capturedId.verificationResult.dataConsistency?.frontReviewImage : nil

        let result = DLScanningVerificationResult(rejectionReason: reason, frontReviewImage: frontReviewImage)
        DispatchQueue.main.async { [weak self] in
            self?.presentResult(capturedId, result: result)
        }
    }

    func handleVerificationSuccess(_ capturedId: CapturedId) {
        // All verification checks passed
        let frontReviewImage = capturedId.verificationResult.dataConsistency?.frontReviewImage
        let result = DLScanningVerificationResult(rejectionReason: nil, frontReviewImage: frontReviewImage)
        presentResult(capturedId, result: result)
    }

    func presentResult(_ capturedId: CapturedId, result: DLScanningVerificationResult) {
        guard
            let viewController = UIStoryboard(name: "DLScanningResultViewController", bundle: nil)
                .instantiateInitialViewController() as? DLScanningResultViewController
        else { return }
        viewController.transitioningDelegate = self
        viewController.prepare(capturedId, result)
        present(viewController, animated: true)
        // We disable IdCapture while presenting the results to prevent capturing while user is inspecting results.
        idCapture.isEnabled = false
    }

    func showAlert(title: String? = nil, message: String? = nil, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: { _ in
                        completion()
                    }
                )
            )

            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension DLScanningViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is DLScanningResultViewController {
            // The result screen is dismissed, we are resetting and re-enabling the IdCapture to restart capture
            // process.
            idCapture.reset()
            idCapture.isEnabled = true
        }

        return nil
    }
}


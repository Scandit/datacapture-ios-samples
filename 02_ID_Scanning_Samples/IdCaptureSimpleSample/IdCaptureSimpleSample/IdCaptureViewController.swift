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

class IdCaptureViewController: UIViewController {

    private enum Constants {
        enum Message {
            static let timeout =
                "Document capture failed. Make sure the document is well lit and free of glare. "
                + "Alternatively, try scanning another document"
            static let rejected = "Document not supported. Try scanning another document"
        }
    }

    // The id capturing process is configured through id capture settings
    // and are then applied to the id capture instance that manages id recognition.
    private lazy var idCaptureSettings = IdCaptureSettings()

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var idCapture: IdCapture!
    private var captureView: DataCaptureView!
    private var overlay: IdCaptureOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
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

    func setupRecognition() {
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

        // We are interested in Id Cards, Driver's Licenses and Passports from any region
        idCaptureSettings.acceptedDocuments = [
            IdCard(region: .any),
            DriverLicense(region: .any),
            Passport(region: .any),
        ]

        // We want to scan all zones and both sides
        idCaptureSettings.scannerType = FullDocumentScanner()

        // Create new id capture mode with the chosen settings.
        idCapture = IdCapture(context: context, settings: idCaptureSettings)

        // Register self as a listener to get informed whenever a new id got recognized.
        idCapture.addListener(self)

        // Add an id capture overlay to the data capture view to render the location of captured ids on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
    }
}

extension IdCaptureViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false

        showAlert(
            title: "Recognized Document",
            message: descriptionForCapturedId(result: capturedId),
            completion: {
                // Resume the idCapture.
                idCapture.isEnabled = true
            }
        )
    }

    func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason: RejectionReason) {
        // Implement to handle documents recognized in a frame, but rejected.
        // A document or its part is considered rejected when (a) it's valid, but not enabled in the settings,
        // (b) it's a barcode of a correct symbology or a Machine Readable Zone (MRZ),
        // but the data is encoded in an unexpected/incorrect format.

        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false
        let message = reason == .timeout ? Constants.Message.timeout : Constants.Message.rejected
        showAlert(
            message: message,
            completion: {
                // Resume the idCapture.
                idCapture.isEnabled = true
            }
        )
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

    func descriptionForCapturedId(result: CapturedId) -> String {
        var results: [String] = []
        if !result.fullName.isEmpty {
            results.append("Full Name: \(result.fullName)")
        }
        if let dateOfBirth = result.dateOfBirth {
            results.append("Date of Birth: \(dateOfBirth)")
        }
        if let dateOfExpiry = result.dateOfExpiry {
            results.append("Date of Expiry: \(dateOfExpiry)")
        }
        if let documentNumber = result.documentNumber {
            results.append("Document Number: \(documentNumber)")
        }
        if let nationality = result.nationality {
            results.append("Nationality: \(nationality)")
        }
        if let documentType = result.document?.documentType {
            results.append("Document Type: \(documentType.description)")
        }

        return results.joined(separator: "\n")
    }
}


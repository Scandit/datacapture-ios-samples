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

class MRZScanViewController: UIViewController {

    // The id capturing process is configured through the id capture settings
    // that are then applied to the id capture instance that manages id recognition.
    private lazy var idCaptureSettings: IdCaptureSettings = {
        let settings = IdCaptureSettings()
        // It's possible to specify which documents to scan via the supportedDocuments property.
        settings.supportedDocuments = [.passportMRZ, .idCardMRZ]
        return settings
    }()

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
        // it's a good idea to first disable text capture as well.
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

        // Use the recommended camera settings for the TextCapture mode.
        let recommenededCameraSettings = IdCapture.recommendedCameraSettings
        camera?.apply(recommenededCameraSettings)

        // To visualize the on-going id capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Create new id capture mode with the chosen settings.
        idCapture = IdCapture(context: context, settings: idCaptureSettings)

        // Register self as a listener to get informed whenever a new id gets recognized.
        idCapture.addListener(self)

        // Add an IdCaptureOverlay to highlight the scanning area.
        // The overlay appearance can be customized by using the setIdLayout method.
        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        // If set to auto the overlay appearance will be deducted from the supportedDocuments property.
        overlay.setIdLayout(.auto)
    }
}

extension MRZScanViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCaptureIn session: IdCaptureSession, frameData: FrameData) {
        // Pause the running IdCapture while processing the captured id.
        idCapture.isEnabled = false
        guard let capturedId = session.newlyCapturedId else {
            idCapture.isEnabled = true
            return
        }

        // The mrzResult property should be nonnull.
        assert(capturedId.mrzResult != nil)

        // Show the data of the capturedId
        let documentDescription = descriptionForCapturedId(result: capturedId)

        DispatchQueue.main.async {
            let alert = UIAlertController(title: "MRZ Document", message: documentDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.idCapture.isEnabled = true
            }))
            self.present(alert, animated: true, completion: nil)
        }

    }

    func idCapture(_ idCapture: IdCapture,
                   didFailWithError error: Error,
                   session: IdCaptureSession,
                   frameData: FrameData) {

        // The error message can be retrieved from the Error localizedDescription.
        print(error.localizedDescription)
    }

    func descriptionForCapturedId(result: CapturedId) -> String {
        return """
        Name: \(result.firstName ?? "<nil>")
        Last Name: \(result.lastName ?? "<nil>")
        Full Name: \(result.fullName)
        Sex: \(result.sex ?? "<nil>")
        Date of Birth: \(result.dateOfBirth?.description ?? "<nil>")
        Nationality: \(result.nationality ?? "<nil>")
        Address: \(result.address ?? "<nil>")
        Document Type: \(result.documentType)
        Captured Result Type: \(result.capturedResultType)
        Issuing Country: \(result.issuingCountry ?? "<nil>")
        Issuing Country ISO: \(result.issuingCountryISO ?? "<nil>")
        Document Number: \(result.documentNumber ?? "<nil>")
        Date of Expiry: \(result.dateOfExpiry?.description ?? "<nil>")
        Date of Issue: \(result.dateOfIssue?.description ?? "<nil>")
        """
    }

    func descriptionForMrzResult(result: CapturedId) -> String {
        let mrzResult = result.mrzResult!
        return """
        \(descriptionForCapturedId(result: result))

        Document Code: \(mrzResult.documentCode)
        Names Are Truncated: \(mrzResult.namesAreTruncated ? "Yes" : "No")
        Optional: \(mrzResult.optional ?? "<nil>")
        Optional 1: \(mrzResult.optional1 ?? "<nil>")
        """
    }
}

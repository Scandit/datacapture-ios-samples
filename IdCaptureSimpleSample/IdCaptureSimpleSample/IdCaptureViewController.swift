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

        // We are interested in the Id Cards and Driver's Licenses visual inspection zone
        idCaptureSettings.supportedDocuments = [
            .idCardVIZ,
            .dlVIZ
         ]

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

extension IdCaptureViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCaptureIn session: IdCaptureSession, frameData: FrameData) {
        guard let capturedId = session.newlyCapturedId else {
            return
        }

        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false

        // The recognized fields of the captured Id can vary based on the type.
        let idDescription: String
        if capturedId.vizResult != nil {
            // If the capturedResultType is `.vizResult`
            // then `capturedId` is guaranteed to have the vizResult property not nil.
            idDescription = descriptionForVizResult(result: capturedId)
        } else {
            idDescription = descriptionForCapturedId(result: capturedId)
        }

        let title = capturedId.capturedResultTypes.combinedDescription

        showAlert(title: title, message: idDescription, completion: {
            // Resume the idCapture.
            idCapture.isEnabled = true
        })
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

    func descriptionForVizResult(result: CapturedId) -> String {
        let vizResult = result.vizResult!
        return """
        \(descriptionForCapturedId(result: result))

        Additional Name Information: \(vizResult.additionalNameInformation ?? "<nil>")
        Additional Address Information: \(vizResult.additionalAddressInformation ?? "<nil>")
        Place of Birth: \(vizResult.placeOfBirth ?? "<nil>")
        Race: \(vizResult.race ?? "<nil>")
        Religion: \(vizResult.religion ?? "<nil>")
        Profession: \(vizResult.profession ?? "<nil>")
        Marital Status: \(vizResult.maritalStatus ?? "<nil>")
        Residential Status: \(vizResult.residentialStatus ?? "<nil>")
        Employer: \(vizResult.employer ?? "<nil>")
        Personal Id Number: \(vizResult.personalIdNumber ?? "<nil>")
        Document Additional Number: \(vizResult.documentAdditionalNumber ?? "<nil>")
        Issuing Jurisdiction: \(vizResult.issuingJurisdiction ?? "<nil>")
        Issuing Authority: \(vizResult.issuingAuthority ?? "<nil>")
        """
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
        Captured Result Type: \(result.capturedResultTypes.combinedDescription)
        Issuing Country: \(result.issuingCountry ?? "<nil>")
        Issuing Country ISO: \(result.issuingCountryISO ?? "<nil>")
        Document Number: \(result.documentNumber ?? "<nil>")
        Date of Expiry: \(result.dateOfExpiry?.description ?? "<nil>")
        Date of Issue: \(result.dateOfIssue?.description ?? "<nil>")
        """
    }
}

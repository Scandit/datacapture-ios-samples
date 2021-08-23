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

        // We are interested in the front side of national Id Cards and passports using MRZ.
        idCaptureSettings.supportedDocuments = [.idCardVIZ, .dlVIZ, .aamvaBarcode, .argentinaIdBarcode,
                                       .colombiaIdBarcode, .southAfricaDLBarcode, .southAfricaIdBarcode, .ususIdBarcode]

        // Create new id capture mode with the chosen settings.
        idCapture = IdCapture(context: context, settings: idCaptureSettings)

        // Register self as a listener to get informed whenever a new id got recognized.
        idCapture.addListener(self)

        // Add an id capture overlay to the data capture view to render the location of captured ids on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        overlay.idLayoutStyle = .square
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
        if capturedId.mrzResult != nil {
            // If the capturedResultType is `.mrzResult`
            // then `capturedId` is guaranteed to have the mrzResult property not nil.
            idDescription = descriptionForMrzResult(result: capturedId)
        } else if capturedId.vizResult != nil {
            // If the capturedResultType is `.vizResult`
            // then `capturedId` is guaranteed to have the vizResult property not nil.
            idDescription = descriptionForVizResult(result: capturedId)
        } else if capturedId.aamvaBarcodeResult != nil {
            // If the capturedResultType is `.aamvaBarcodeResult`
            // then `capturedId` is guaranteed to have the aamvaBarcodeResult property not nil.
            idDescription = descriptionForUsDriverLicenseBarcodeResult(result: capturedId)
        } else if capturedId.usUniformedServicesBarcodeResult != nil {
            // If the capturedResultType is `.usUniformedServicesBarcodeResult`
            // then `capturedId` is guaranteed to have the usUniformedServicesBarcodeResult property not nil.
            idDescription = descriptionForUsUniformedServicesBarcodeResult(result: capturedId)
        } else {
            idDescription = descriptionForCapturedId(result: capturedId)
        }

        let title = capturedId.capturedResultType.description
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: idDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                // Resume the idCapture.
                idCapture.isEnabled = true
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }

    func idCapture(_ idCapture: IdCapture,
                   didFailWithError error: Error,
                   session: IdCaptureSession,
                   frameData: FrameData) {

        // Implement to handle an error encountered during the capture process.
        // The error message can be retrieved from the Error localizedDescription.
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

    func descriptionForUsDriverLicenseBarcodeResult(result: CapturedId) -> String {
        let aamvaBarcodeResult = result.aamvaBarcodeResult!
        return """
        \(descriptionForCapturedId(result: result))

        AAMVA Version: \(aamvaBarcodeResult.aamvaVersion)
        Jurisdiction Version: \(aamvaBarcodeResult.jurisdictionVersion)
        IIN: \(aamvaBarcodeResult.iin)
        Issuing Jurisdiction: \(aamvaBarcodeResult.issuingJurisdiction)
        Issuing Jurisdiction ISO: \(aamvaBarcodeResult.issuingJurisdictionISO)
        Eye Color: \(aamvaBarcodeResult.eyeColor ?? "<nil>")
        Hair Color: \(aamvaBarcodeResult.hairColor ?? "<nil>")
        Height Inch: \(String(aamvaBarcodeResult.heightInch?.floatValue ?? 0))
        Height Cm: \(String(aamvaBarcodeResult.heightCm?.floatValue ?? 0))
        Weight Lb: \(String(aamvaBarcodeResult.weightLbs?.floatValue ?? 0))
        Weight Kg: \(String(aamvaBarcodeResult.weightKg?.floatValue ?? 0))
        Place of Birth: \(aamvaBarcodeResult.placeOfBirth ?? "<nil>")
        Race: \(aamvaBarcodeResult.race ?? "<nil>")
        Document Discriminator Number: \(aamvaBarcodeResult.documentDiscriminatorNumber ?? "<nil>")
        Vehicle Class: \(aamvaBarcodeResult.vehicleClass ?? "<nil>")
        Restrictions Code: \(aamvaBarcodeResult.restrictionsCode ?? "<nil>")
        Endorsements Code: \(aamvaBarcodeResult.endorsementsCode ?? "<nil>")
        Card Revision Date: \(aamvaBarcodeResult.cardRevisionDate?.description ?? "<nil>")
        Middle Name: \(aamvaBarcodeResult.middleName ?? "<nil>")
        Driver Name Suffix: \(aamvaBarcodeResult.driverNameSuffix ?? "<nil>")
        Driver Name Prefix: \(aamvaBarcodeResult.driverNamePrefix ?? "<nil>")
        Last Name Truncation: \(aamvaBarcodeResult.lastNameTruncation ?? "<nil>")
        First Name Truncation: \(aamvaBarcodeResult.firstNameTruncation ?? "<nil>")
        Middle Name Truncation: \(aamvaBarcodeResult.middleNameTruncation ?? "<nil>")
        Alias Family Name: \(aamvaBarcodeResult.aliasFamilyName ?? "<nil>")
        Alias Given Name: \(aamvaBarcodeResult.aliasGivenName ?? "<nil>")
        Alias Suffix Name: \(aamvaBarcodeResult.aliasSuffixName ?? "<nil>")
        """
    }

    func descriptionForUsUniformedServicesBarcodeResult(result: CapturedId) -> String {
        let ususBarcoderesult = result.usUniformedServicesBarcodeResult!
        return """
        \(descriptionForCapturedId(result: result))

        Version: \(ususBarcoderesult.version)
        Sponsor Flag: \(ususBarcoderesult.sponsorFlag)
        Person Designator Document: \(ususBarcoderesult.personDesignatorDocument)
        Family Sequence Number: \(ususBarcoderesult.familySequenceNumber)
        Deers Dependent Suffix Code: \(ususBarcoderesult.deersDependentSuffixCode)
        Deers Dependent Suffix Description: \(ususBarcoderesult.deersDependentSuffixDescription)
        Height: \(ususBarcoderesult.height)
        Weight: \(ususBarcoderesult.weight)
        Hair Color: \(ususBarcoderesult.hairColor)
        Eye Color: \(ususBarcoderesult.eyeColor)
        Direct Care Flag Code: \(ususBarcoderesult.directCareFlagCode)
        Direct Care Flag Description: \(ususBarcoderesult.directCareFlagDescription)
        Civilian Health Care Flag Code: \(ususBarcoderesult.civilianHealthCareFlagCode)
        Civilian Health Care Flag Description: \(ususBarcoderesult.civilianHealthCareFlagDescription)
        Commissary Flag Code: \(ususBarcoderesult.commissaryFlagCode)
        Commissary Flag Description: \(ususBarcoderesult.commissaryFlagDescription)
        MWR Flag Code: \(ususBarcoderesult.mwrFlagCode)
        MWR Flag Description: \(ususBarcoderesult.mwrFlagDescription)
        Exchange Flag Code: \(ususBarcoderesult.exchangeFlagCode)
        Exchange Flag Description: \(ususBarcoderesult.exchangeFlagDescription)
        Champus Effective Date: \(ususBarcoderesult.champusEffectiveDate?.description ?? "<nil>")
        Champus Expiry Date: \(ususBarcoderesult.champusExpiryDate?.description ?? "<nil>")
        Form Number: \(ususBarcoderesult.formNumber)
        Security Code: \(ususBarcoderesult.securityCode)
        Service Code: \(ususBarcoderesult.serviceCode)
        Status Code: \(ususBarcoderesult.statusCode)
        Status Code Description: \(ususBarcoderesult.statusCodeDescription)
        Branch Of Service: \(ususBarcoderesult.branchOfService)
        Rank: \(ususBarcoderesult.rank)
        Pay Grade: \(ususBarcoderesult.payGrade ?? "<nil>")
        Sponsor Name: \(ususBarcoderesult.sponsorName ?? "<nil>")
        Sponsor Person Designator Identifier: \(ususBarcoderesult.sponsorPersonDesignatorIdentifier?.intValue ?? 0)
        Relationship Code: \(ususBarcoderesult.relationshipCode ?? "<nil>")
        Relationship Description: \(ususBarcoderesult.relationshipDescription ?? "<nil>")
        Geneva Convention Category: \(ususBarcoderesult.genevaConventionCategory ?? "<nil>")
        Blood Type: \(ususBarcoderesult.bloodType ?? "<nil>")
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
        Captured Result Type: \(result.capturedResultType)
        Issuing Country: \(result.issuingCountry ?? "<nil>")
        Issuing Country ISO: \(result.issuingCountryISO ?? "<nil>")
        Document Number: \(result.documentNumber ?? "<nil>")
        Date of Expiry: \(result.dateOfExpiry?.description ?? "<nil>")
        Date of Issue: \(result.dateOfIssue?.description ?? "<nil>")
        """
    }
}

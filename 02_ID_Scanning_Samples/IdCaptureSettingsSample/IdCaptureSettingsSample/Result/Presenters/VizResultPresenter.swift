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

import Foundation
import ScanditIdCapture

private extension DrivingLicenseDetails {
    func isEmpty() -> Bool {
        if restrictions?.isEmpty == false {
            return false
        }
        if endorsements?.isEmpty == false {
            return false
        }
        return drivingLicenseCategories.isEmpty
    }
}

class VizResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        guard let vizResult = capturedId.vizResult else { fatalError("Unexpected null VizResult") }
        var rows: [CellProvider] = [
            SimpleTextCellProvider(
                value: vizResult.firstName.valueOrNil,
                title: "VIZ First Name"
            ),
            SimpleTextCellProvider(
                value: vizResult.lastName.valueOrNil,
                title: "VIZ Last Name"
            ),
            SimpleTextCellProvider(
                value: vizResult.secondaryLastName.valueOrNil,
                title: "VIZ Secondary Last Name"
            ),
            SimpleTextCellProvider(
                value: vizResult.fullName,
                title: "VIZ Full Name"
            ),
            SimpleTextCellProvider(value: vizResult.sex.valueOrNil, title: "VIZ Sex"),
            SimpleTextCellProvider(value: vizResult.dateOfBirth.valueOrNil, title: "VIZ Date of Birth"),
            SimpleTextCellProvider(value: vizResult.nationality.valueOrNil, title: "VIZ Nationality"),
            SimpleTextCellProvider(value: vizResult.address.valueOrNil, title: "VIZ Address"),
            SimpleTextCellProvider(value: vizResult.documentNumber.valueOrNil, title: "VIZ Document Number"),
            SimpleTextCellProvider(value: vizResult.dateOfExpiry.valueOrNil, title: "VIZ Date of Expiry"),
            SimpleTextCellProvider(value: vizResult.dateOfIssue.valueOrNil, title: "VIZ Date of Issue"),
            SimpleTextCellProvider(
                value: vizResult.additionalNameInformation.valueOrNil,
                title: "Additional Name Information"
            ),
            SimpleTextCellProvider(
                value: vizResult.additionalAddressInformation.valueOrNil,
                title: "Additional Address Information"
            ),
            SimpleTextCellProvider(value: vizResult.placeOfBirth.valueOrNil, title: "Place of Birth"),
            SimpleTextCellProvider(value: vizResult.race.valueOrNil, title: "Race"),
            SimpleTextCellProvider(value: vizResult.religion.valueOrNil, title: "Religion"),
            SimpleTextCellProvider(value: vizResult.profession.valueOrNil, title: "Profession"),
            SimpleTextCellProvider(value: vizResult.maritalStatus.valueOrNil, title: "Marital Status"),
            SimpleTextCellProvider(value: vizResult.residentialStatus.valueOrNil, title: "Residential Status"),
            SimpleTextCellProvider(value: vizResult.employer.valueOrNil, title: "Employer"),
            SimpleTextCellProvider(value: vizResult.personalIdNumber.valueOrNil, title: "Personal ID Number"),
            SimpleTextCellProvider(value: vizResult.issuingJurisdiction.valueOrNil, title: "Issuing Jurisdiction"),
            SimpleTextCellProvider(
                value: vizResult.issuingJurisdictionISO.valueOrNil,
                title: "Issuing Jurisdiction ISO"
            ),
            SimpleTextCellProvider(value: vizResult.issuingAuthority.valueOrNil, title: "Issuing Authority"),
            SimpleTextCellProvider(value: vizResult.bloodType.valueOrNil, title: "Blood Type"),
            SimpleTextCellProvider(value: vizResult.sponsor.valueOrNil, title: "Sponsor"),
            SimpleTextCellProvider(value: vizResult.mothersName.valueOrNil, title: "Mother's name"),
            SimpleTextCellProvider(value: vizResult.fathersName.valueOrNil, title: "Father's name"),
            SimpleTextCellProvider(value: vizResult.capturedSides.description, title: "Captured Sides"),
            SimpleTextCellProvider(
                value: vizResult.isBackSideCaptureSupported ? "Yes" : "No",
                title: "Backside Supported"
            ),
            SimpleTextCellProvider(value: vizResult.visaNumber.valueOrNil, title: "Visa Number"),
            SimpleTextCellProvider(value: vizResult.passportNumber.valueOrNil, title: "Passport Number"),
            SimpleTextCellProvider(value: vizResult.vehicleOwner.valueOrNil, title: "Vehicle Owner"),
        ]

        if let drivingLicenseDetails = vizResult.drivingLicenseDetails,
            !drivingLicenseDetails.isEmpty()
        {
            var dlDetailsString = "Categories:\n"

            if drivingLicenseDetails.drivingLicenseCategories.isEmpty {
                dlDetailsString.append("<nil>\n")
            } else {
                let dlCategories = drivingLicenseDetails.drivingLicenseCategories.map {
                    "Code: \($0.code)\n" + "Date Of Issue: \($0.dateOfIssue.valueOrNil)\n"
                        + "Date Of Expiry: \($0.dateOfExpiry.valueOrNil)"
                }.joined(separator: "\n\n")
                dlDetailsString.append(dlCategories)
            }

            dlDetailsString.append("\n\nRestrictions: \(drivingLicenseDetails.restrictions.valueOrNil)")
            dlDetailsString.append("\n\nEndorsements: \(drivingLicenseDetails.endorsements.valueOrNil)")

            rows.append(
                SimpleTextCellProvider(
                    value: dlDetailsString,
                    title: "Driver's License Details"
                )
            )
        }

        self.rows = rows
    }
}

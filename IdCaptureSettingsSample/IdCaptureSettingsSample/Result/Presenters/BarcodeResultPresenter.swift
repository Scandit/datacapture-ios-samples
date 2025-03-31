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
// swiftlint:disable function_body_length
import ScanditIdCapture
import UIKit

class BarcodeResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        guard let barcode = capturedId.barcode else {
            fatalError("Unexpected null BarcodeResult")
        }
        var rows = [
            SimpleTextCellProvider(value: "\(barcode.aamvaVersion.valueOrNil)", title: "AAMVA Version"),
            SimpleTextCellProvider(value: barcode.firstName.valueOrNil, title: "Barcode First Name"),
            SimpleTextCellProvider(value: barcode.lastName.valueOrNil, title: "Barcode Last Name"),
            SimpleTextCellProvider(value: barcode.fullName, title: "Barcode Full Name"),
            SimpleTextCellProvider(value: barcode.sex.valueOrNil, title: "Barcode Sex"),
            SimpleTextCellProvider(value: barcode.dateOfBirth.valueOrNil, title: "Barcode Date of Birth"),
            SimpleTextCellProvider(value: barcode.nationality.valueOrNil, title: "Barcode Nationality"),
            SimpleTextCellProvider(value: barcode.address.valueOrNil, title: "Barcode Address"),
            SimpleTextCellProvider(value: barcode.documentNumber.valueOrNil, title: "Barcode Document Number"),
            SimpleTextCellProvider(value: barcode.dateOfExpiry.valueOrNil, title: "Barcode Date of Expiry"),
            SimpleTextCellProvider(value: barcode.dateOfIssue.valueOrNil, title: "Barcode Date of Issue"),
            SimpleTextCellProvider(value: barcode.aliasFamilyName.valueOrNil, title: "Alias Family Name"),
            SimpleTextCellProvider(value: barcode.aliasGivenName.valueOrNil, title: "Alias Given Name"),
            SimpleTextCellProvider(value: barcode.aliasSuffixName.valueOrNil, title: "Alias Suffix Name"),
            SimpleTextCellProvider(value: barcode.bloodType.valueOrNil, title: "Blood Type"),
            SimpleTextCellProvider(value: barcode.branchOfService.valueOrNil, title: "Branch Of Service"),
            SimpleTextCellProvider(value: barcode.cardInstanceIdentifier.valueOrNil,
                                   title: "Card Instance Identifier"),
            SimpleTextCellProvider(value: barcode.cardRevisionDate.valueOrNil, title: "Card Revision Date"),
            SimpleTextCellProvider(value: barcode.categories.joined(separator: ", "), title: "Categories"),
            SimpleTextCellProvider(value: barcode.champusEffectiveDate.valueOrNil,
                                   title: "Champus Effective Date"),
            SimpleTextCellProvider(value: barcode.champusExpiryDate.valueOrNil, title: "Champus Expiry Date"),
            SimpleTextCellProvider(value: barcode.citizenshipStatus.valueOrNil, title: "Citizenship Status"),
            SimpleTextCellProvider(value: barcode.civilianHealthCareFlagCode.valueOrNil,
                                   title: "Civilian Health Care Flag Code"),
            SimpleTextCellProvider(value: barcode.civilianHealthCareFlagDescription.valueOrNil,
                                   title: "Civilian Health Care Flag Description"),
            SimpleTextCellProvider(value: barcode.commissaryFlagCode.valueOrNil,
                                   title: "Commissary Flag Code"),
            SimpleTextCellProvider(value: barcode.commissaryFlagDescription.valueOrNil,
                                   title: "Commissary Flag Description"),
            SimpleTextCellProvider(value: barcode.countryOfBirth.valueOrNil,
                                   title: "Country Of Birth"),
            SimpleTextCellProvider(value: barcode.countryOfBirthIso.valueOrNil,
                                   title: "Country Of Birth Iso"),
            SimpleTextCellProvider(value: "\(barcode.deersDependentSuffixCode.valueOrNil)",
                                   title: "Deers Dependent Suffix Code"),
            SimpleTextCellProvider(value: barcode.deersDependentSuffixDescription.valueOrNil,
                                   title: "Deers Dependent Suffix Description"),
            SimpleTextCellProvider(value: barcode.directCareFlagCode.valueOrNil,
                                   title: "Direct Care Flag Code"),
            SimpleTextCellProvider(value: barcode.directCareFlagDescription.valueOrNil,
                                   title: "Direct Care Flag Description"),
            SimpleTextCellProvider(value: barcode.documentCopy.valueOrNil, title: "Document Copy"),
            SimpleTextCellProvider(value: barcode.documentDiscriminatorNumber.valueOrNil,
                                   title: "Document Discriminator Number"),
            SimpleTextCellProvider(value: barcode.driverNamePrefix.valueOrNil, title: "Driver Name Prefix"),
            SimpleTextCellProvider(value: barcode.driverNameSuffix.valueOrNil, title: "Driver Name Suffix"),
            SimpleTextCellProvider(value: barcode
                .driverRestrictionCodes
                .map(String.init)
                .joined(separator: " "),
                                   title: "Driver Restriction Codes"),
            SimpleTextCellProvider(value: barcode.ediPersonIdentifier.valueOrNil, title: "Edi Person Identifier"),
            SimpleTextCellProvider(value: barcode.endorsementsCode.valueOrNil, title: "Endorsements Code"),
            SimpleTextCellProvider(value: barcode.exchangeFlagCode.valueOrNil, title: "Exchange Flag Code"),
            SimpleTextCellProvider(value: barcode.exchangeFlagDescription.valueOrNil,
                                   title: "Exchange Flag Description"),
            SimpleTextCellProvider(value: barcode.eyeColor.valueOrNil, title: "Eye Color"),
            SimpleTextCellProvider(value: "\(barcode.familySequenceNumber.valueOrNil)",
                                   title: "Family Sequence Number"),
            SimpleTextCellProvider(value: barcode.firstNameTruncation.valueOrNil,
                                   title: "First Name Truncation"),
            SimpleTextCellProvider(value: barcode.firstNameWithoutMiddleName.valueOrNil,
                                   title: "First Name Without Middle Name"),
            SimpleTextCellProvider(value: barcode.formNumber.valueOrNil, title: "Form Number"),
            SimpleTextCellProvider(value: barcode.genevaConventionCategory.valueOrNil,
                                   title: "Geneva Convention Category"),
            SimpleTextCellProvider(value: barcode.hairColor.valueOrNil, title: "Hair Color"),
            SimpleTextCellProvider(value: "\(barcode.heightCm.valueOrNil)", title: "Height Cm"),
            SimpleTextCellProvider(value: "\(barcode.heightInch.valueOrNil)", title: "Height Inch"),
            SimpleTextCellProvider(value: barcode.iin.valueOrNil, title: "Iin"),
            SimpleTextCellProvider(value: barcode.identificationType.valueOrNil, title: "Identification Type"),
            SimpleTextCellProvider(value: barcode.issuingJurisdiction.valueOrNil, title: "Issuing Jurisdiction"),
            SimpleTextCellProvider(value: barcode.issuingJurisdictionIso.valueOrNil,
                                   title: "Issuing Jurisdiction Iso"),
            SimpleTextCellProvider(value: "\(barcode.jurisdictionVersion.valueOrNil)",
                                   title: "Jurisdiction Version"),
            SimpleTextCellProvider(value: barcode.lastNameTruncation.valueOrNil, title: "Last Name Truncation"),
            SimpleTextCellProvider(value: barcode.licenseCountryOfIssue.valueOrNil,
                                   title: "License Country Of Issue"),
            SimpleTextCellProvider(value: barcode.middleName.valueOrNil, title: "Middle Name"),
            SimpleTextCellProvider(value: barcode.middleNameTruncation.valueOrNil,
                                   title: "Middle Name Truncation"),
            SimpleTextCellProvider(value: barcode.mwrFlagCode.valueOrNil, title: "Mwr Flag Code"),
            SimpleTextCellProvider(value: barcode.mwrFlagDescription.valueOrNil, title: "Mwr Flag Description"),
            SimpleTextCellProvider(value: barcode.payGrade.valueOrNil, title: "Pay Grade"),
            SimpleTextCellProvider(value: barcode.payPlanCode.valueOrNil, title: "Pay Plan Code"),
            SimpleTextCellProvider(value: barcode.payPlanGradeCode.valueOrNil, title: "Pay Plan Grade Code"),
            SimpleTextCellProvider(value: "\(barcode.personDesignatorDocument.valueOrNil)",
                                   title: "Person Designator Document"),
            SimpleTextCellProvider(value: barcode.personDesignatorTypeCode.valueOrNil,
                                   title: "Person Designator Type Code"),
            SimpleTextCellProvider(value: barcode.personMiddleInitial.valueOrNil, title: "Person Middle Initial"),
            SimpleTextCellProvider(value: barcode.personalIdNumber.valueOrNil, title: "Personal Id Number"),
            SimpleTextCellProvider(value: barcode.personalIdNumberType.valueOrNil,
                                   title: "Personal Id Number Type"),
            SimpleTextCellProvider(value: barcode.personnelCategoryCode.valueOrNil,
                                   title: "Personnel Category Code"),
            SimpleTextCellProvider(value: barcode.personnelEntitlementConditionType.valueOrNil,
                                   title: "Personnel Entitlement Condition Type"),
            SimpleTextCellProvider(value: barcode.placeOfBirth.valueOrNil, title: "Place Of Birth"),
            SimpleTextCellProvider(value: barcode.race.valueOrNil, title: "Race"),
            SimpleTextCellProvider(value: barcode.rank.valueOrNil, title: "Rank"),
            SimpleTextCellProvider(value: barcode.rawData.valueOrNil, title: "Raw Data"),
            SimpleTextCellProvider(value: barcode.relationshipCode.valueOrNil, title: "Relationship Code"),
            SimpleTextCellProvider(value: barcode.relationshipDescription.valueOrNil,
                                   title: "Relationship Description"),
            SimpleTextCellProvider(value: barcode.restrictionsCode.valueOrNil, title: "Restrictions Code"),
            SimpleTextCellProvider(value: barcode.securityCode.valueOrNil, title: "Security Code"),
            SimpleTextCellProvider(value: barcode.serviceCode.valueOrNil, title: "Service Code"),
            SimpleTextCellProvider(value: barcode.sponsorFlag.valueOrNil, title: "Sponsor Flag"),
            SimpleTextCellProvider(value: barcode.sponsorName.valueOrNil, title: "Sponsor Name"),
            SimpleTextCellProvider(value: barcode.sponsorPersonDesignatorIdentifier
                .valueOrNil, title: "Sponsor Person Designator Identifier"),
            SimpleTextCellProvider(value: barcode.statusCode.valueOrNil, title: "Status Code"),
            SimpleTextCellProvider(value: barcode.statusCodeDescription.valueOrNil,
                                   title: "Status Code Description"),
            SimpleTextCellProvider(value: barcode.vehicleClass.valueOrNil, title: "Vehicle Class"),
            SimpleTextCellProvider(value: barcode.version.valueOrNil, title: "Version"),
            SimpleTextCellProvider(value: "\(barcode.weightKg.valueOrNil)", title: "Weight Kg"),
            SimpleTextCellProvider(value: "\(barcode.weightLbs.valueOrNil)", title: "Weight Lbs"),
            SimpleTextCellProvider(value: barcode.isRealId.valueOrNil, title: "Is Real Id"),
            SimpleTextCellProvider(value: barcode
                .barcodeDataElements
                .map({"\($0.key): \($0.value)"})
                .joined(separator: "\n"),
                                   title: "Barcode Elements")
        ]

        if let professionalDrivingPermit = barcode.professionalDrivingPermit {
            rows.append(
                SimpleTextCellProvider(value: professionalDrivingPermit.codes.joined(separator: " "),
                                       title: "Professional Driving Permit - Codes"))
            rows.append(
                SimpleTextCellProvider(value: professionalDrivingPermit.dateOfExpiry.description,
                                       title: "Professional Driving Permit - Date of Expiry"))
        }

        if barcode.vehicleRestrictions.count != 0 {
            let vehicleRestrictions = barcode.vehicleRestrictions.map {
                "Vehicle Code: \($0.vehicleCode)\n" +
                "Vehicle Restriction: \($0.vehicleRestriction)\n" +
                "Date of Issue: \($0.dateOfIssue.description)\n"
            }.joined(separator: "\n")
            rows.append(SimpleTextCellProvider(value: vehicleRestrictions,
                                               title: "Vehicle Restrictions"))
        }

        self.rows = rows
    }
}
// swiftlint:enable function_body_length

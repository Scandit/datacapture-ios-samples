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

import ScanditIdCapture
import UIKit

class AAMVABarcodeResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.aamvaBarcodeResult))
        guard let aamvaBarcodeResult = capturedId.aamvaBarcodeResult else {
            fatalError("Unexpected null AAMVABarcodeResult")
        }
        rows = [
            SimpleTextCellProvider(value: "\(aamvaBarcodeResult.aamvaVersion)", title: "AAMVA Version"),
            SimpleTextCellProvider(value: "\(aamvaBarcodeResult.aamvaVersion)", title: "Jurisdiction Version"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.iin, title: "IIN"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.isRealId ? "YES" : "NO", title: "Is Real ID"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.issuingJurisdiction, title: "Issuing Jurisdiction"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.issuingJurisdictionISO, title: "Issuing Jurisdiction ISO"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.eyeColor.valueOrNil, title: "Eye Color"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.hairColor.valueOrNil, title: "Hair Color"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.heightInch.valueOrNil, title: "Height Inch"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.heightCm.valueOrNil, title: "Height cm"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.weightLbs.valueOrNil, title: "Weight lbs"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.weightKg.valueOrNil, title: "Weight Kg"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.placeOfBirth.valueOrNil, title: "Place of Birth"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.race.valueOrNil, title: "Race"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.documentDiscriminatorNumber.valueOrNil,
                                   title: "Document Discriminator Number"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.vehicleClass.valueOrNil, title: "Vehicle Class"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.restrictionsCode.valueOrNil, title: "Restrictions Code"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.endorsementsCode.valueOrNil, title: "Endorsements Code"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.cardRevisionDate.valueOrNil, title: "Card Revision Date"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.firstNameWithoutMiddleName.valueOrNil,
                                    title: "First Name Without Middle Name"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.middleName.valueOrNil, title: "Middle Name"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.driverNameSuffix.valueOrNil, title: "Driver Name Suffix"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.driverNamePrefix.valueOrNil, title: "Driver Name Prefix"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.lastNameTruncation.valueOrNil,
                                   title: "Last Name Truncation"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.firstNameTruncation.valueOrNil,
                                   title: "First Name Truncation"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.middleNameTruncation.valueOrNil,
                                   title: "Middle Name Truncation"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.aliasFamilyName.valueOrNil, title: "Alias Family Name"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.aliasGivenName.valueOrNil, title: "Alias Given Name"),
            SimpleTextCellProvider(value: aamvaBarcodeResult.aliasSuffixName.valueOrNil, title: "Alias Suffix Name"),
            SimpleTextCellProvider(value: aamvaBarcodeResult
                                    .barcodeDataElements
                                    .map({"\($0.key): \($0.value)"})
                                    .joined(separator: "\n"),
                                   title: "Barcode Elements")
        ]
    }
}

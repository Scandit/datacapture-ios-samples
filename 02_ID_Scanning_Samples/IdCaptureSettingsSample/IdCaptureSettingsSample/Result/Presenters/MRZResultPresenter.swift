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

class MRZResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        guard let mrzResult = capturedId.mrzResult else { fatalError("Unexpected null MRZResult") }
        rows = [
            SimpleTextCellProvider(value: mrzResult.firstName.valueOrNil, title: "MRZ First Name"),
            SimpleTextCellProvider(value: mrzResult.lastName.valueOrNil, title: "MRZ Last Name"),
            SimpleTextCellProvider(value: mrzResult.fullName, title: "MRZ Full Name"),
            SimpleTextCellProvider(value: mrzResult.sex.valueOrNil, title: "MRZ Sex"),
            SimpleTextCellProvider(value: mrzResult.dateOfBirth.valueOrNil, title: "MRZ Date of Birth"),
            SimpleTextCellProvider(value: mrzResult.nationality.valueOrNil, title: "MRZ Nationality"),
            SimpleTextCellProvider(value: mrzResult.address.valueOrNil, title: "MRZ Address"),
            SimpleTextCellProvider(value: mrzResult.documentNumber.valueOrNil, title: "MRZ Document Number"),
            SimpleTextCellProvider(value: mrzResult.dateOfExpiry.valueOrNil, title: "MRZ Date of Expiry"),
            SimpleTextCellProvider(value: mrzResult.dateOfIssue.valueOrNil, title: "MRZ Date of Issue"),
            SimpleTextCellProvider(value: mrzResult.documentCode, title: "Document Code"),
            SimpleTextCellProvider(value: mrzResult.namesAreTruncated ? "Yes" : "No", title: "Names are Truncated"),
            SimpleTextCellProvider(value: mrzResult.optionalDataInLine1.valueOrNil, title: "Optional Data In Line 1"),
            SimpleTextCellProvider(value: mrzResult.optionalDataInLine2.valueOrNil, title: "Optional Data In Line 2"),
            SimpleTextCellProvider(value: mrzResult.capturedMrz, title: "Captured MRZ"),
            SimpleTextCellProvider(value: mrzResult.personalIdNumber.valueOrNil, title: "Personal ID Number"),
            SimpleTextCellProvider(value: mrzResult.passportNumber.valueOrNil, title: "Passport Number"),
            SimpleTextCellProvider(value: mrzResult.passportIssuerIso.valueOrNil, title: "Passport Issuer ISO"),
            SimpleTextCellProvider(value: mrzResult.passportDateOfExpiry.valueOrNil, title: "Passport Date of Expiry"),
            SimpleTextCellProvider(value: mrzResult.renewalTimes.valueOrNil, title: "Renewal Times"),
            SimpleTextCellProvider(
                value: mrzResult.fullNameSimplifiedChinese.valueOrNil,
                title: "Full Name Simplified Chinese"
            ),
            SimpleTextCellProvider(
                value: mrzResult.omittedCharacterCountInGbkName.valueOrNil,
                title: "Omitted Character Count in GBK Name"
            ),
            SimpleTextCellProvider(value: mrzResult.omittedNameCount.valueOrNil, title: "Omitted Name Count"),
            SimpleTextCellProvider(value: mrzResult.issuingAuthorityCode.valueOrNil, title: "Issuing Authority Code"),
        ]
    }
}

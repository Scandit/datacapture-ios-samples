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

class MobileDocumentOcrResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        guard let mobileDocumentOcrResult = capturedId.mobileDocumentOcrResult else {
            fatalError("Unexpected null MobileDocumentOcrResult")
        }
        rows = [
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.firstName.valueOrNil,
                title: "Mobile Document OCR First Name"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.lastName.valueOrNil,
                title: "Mobile Document OCR Last Name"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.fullName.valueOrNil,
                title: "Mobile Document OCR Full Name"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.dateOfBirth.valueOrNil,
                title: "Mobile Document OCR Date of Birth"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.sex.valueOrNil,
                title: "Mobile Document OCR Sex"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.nationality.valueOrNil,
                title: "Mobile Document OCR Nationality"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.address.valueOrNil,
                title: "Mobile Document OCR Address"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.documentNumber.valueOrNil,
                title: "Mobile Document OCR Document Number"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.documentAdditionalNumber.valueOrNil,
                title: "Mobile Document OCR Document Additional Number"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.dateOfExpiry.valueOrNil,
                title: "Mobile Document OCR Date of Expiry"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.dateOfIssue.valueOrNil,
                title: "Mobile Document OCR Date of Issue"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.issuingJurisdiction.valueOrNil,
                title: "Mobile Document OCR Issuing Jurisdiction"
            ),
            SimpleTextCellProvider(
                value: mobileDocumentOcrResult.issuingJurisdictionIso.valueOrNil,
                title: "Mobile Document OCR Issuing Jurisdiction ISO"
            ),
        ]
    }
}

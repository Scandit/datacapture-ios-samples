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
            SimpleTextCellProvider(value: mrzResult.documentCode, title: "Document Code"),
            SimpleTextCellProvider(value: mrzResult.namesAreTruncated ? "Yes" : "No", title: "Names are Truncated"),
            SimpleTextCellProvider(value: mrzResult.optional.valueOrNil, title: "Optional"),
            SimpleTextCellProvider(value: mrzResult.optional1.valueOrNil, title: "Optional 1"),
            SimpleTextCellProvider(value: mrzResult.capturedMrz, title: "Captured MRZ"),
            SimpleTextCellProvider(value: mrzResult.personalIdNumber.valueOrNil, title: "Personal ID Number"),
            SimpleTextCellProvider(value: mrzResult.passportNumber.valueOrNil, title: "Passport Number"),
            SimpleTextCellProvider(value: mrzResult.passportIssuerIso.valueOrNil, title: "Passport Issuer ISO"),
            SimpleTextCellProvider(value: mrzResult.passportDateOfExpiry.valueOrNil, title: "Passport Date of Expiry"),
            SimpleTextCellProvider(value: mrzResult.renewalTimes.valueOrNil, title: "Renewal Times"),
            SimpleTextCellProvider(value: mrzResult.fullNameSimplifiedChinese.valueOrNil,
                                   title: "Full Name Simplified Chinese"),
            SimpleTextCellProvider(value: mrzResult.omittedCharacterCountInGbkName.valueOrNil,
                                   title: "Omitted Character Count in GBK Name"),
            SimpleTextCellProvider(value: mrzResult.omittedNameCount.valueOrNil, title: "Omitted Name Count"),
            SimpleTextCellProvider(value: mrzResult.issuingAuthorityCode.valueOrNil, title: "Issuing Authority Code")
        ]
    }
}

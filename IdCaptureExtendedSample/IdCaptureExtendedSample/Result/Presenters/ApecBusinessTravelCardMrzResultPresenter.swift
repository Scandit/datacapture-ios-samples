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

import ScanditIdCapture

final class ApecBusinessTravelCardMrzResultPresenter: ResultPresenter {
    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.apecBusinessTravelCardMrzResult))
        guard let result = capturedId.apecBusinessTravelCardMrzResult else {
            fatalError("Unexpected null ApecBusinessTravelCardMrzResult")
        }

        rows = [
            SimpleTextCellProvider(value: result.documentCode, title: "Document Code"),
            SimpleTextCellProvider(value: result.passportIssuerIso, title: "Passport Issuer ISO"),
            SimpleTextCellProvider(value: result.passportNumber, title: "Passport Number"),
            SimpleTextCellProvider(value: result.passportDateOfExpiry.description, title: "Passport date of expiry"),
            SimpleTextCellProvider(value: result.capturedMrz, title: "Captured MRZ")
        ]
    }
}

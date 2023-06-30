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

import Foundation
import ScanditIdCapture

class UsVisaResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.usVisaVizResult))
        guard let usVisaResult = capturedId.usVisaVizResult else { fatalError("Unexpected null UsVisaResult") }
        rows = [
            SimpleTextCellProvider(value: usVisaResult.visaNumber, title: "Visa Number"),
            SimpleTextCellProvider(value: usVisaResult.passportNumber, title: "Passport Number")
        ]
    }
}

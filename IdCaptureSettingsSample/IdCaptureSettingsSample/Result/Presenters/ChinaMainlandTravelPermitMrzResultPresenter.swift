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

class ChinaMainlandTravelPermitMrzResultPresenter: ResultPresenter {
    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.chinaMainlandTravelPermitMrzResult))
        guard let result = capturedId.chinaMainlandTravelPermitMrzResult else {
            fatalError("Unexpected null ChinaMainlandTravelPermitMrzResult")
        }
        rows = [
            SimpleTextCellProvider(value: result.documentCode, title: "Document Code"),
            SimpleTextCellProvider(value: result.capturedMrz, title: "Captured MRZ"),
            SimpleTextCellProvider(value: result.personalIdNumber,
                                   title: "Personal ID Number"),
            SimpleTextCellProvider(value: "\(result.renewalTimes)", title: "Renewal Times"),
            SimpleTextCellProvider(value: result.fullNameSimplifiedChinese, title: "Full Name Simplified Chinese"),
            SimpleTextCellProvider(value: "\(result.omittedCharacterCountInGBKName)",
                                   title: "Omitted Character Count in GBK Name"),
            SimpleTextCellProvider(value: "\(result.omittedNameCount)",
                                   title: "Omitted Name Count"),
            SimpleTextCellProvider(value: result.issuingAuthorityCode.valueOrNil,
                                   title: "Issuing Authority Code")
        ]
    }
}

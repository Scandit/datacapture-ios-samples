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
import UIKit

class MRZResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultType == .mrzResult)
        guard let mrzResult = capturedId.mrzResult else { fatalError("Unexpected null MRZResult") }
        let commonRows = Self.getCommonRows(for: capturedId)
        let mrzRows: [CellProvider] = [
            SimpleTextCellProvider(value: mrzResult.documentCode, title: "Document Code"),
            SimpleTextCellProvider(value: mrzResult.namesAreTruncated ? "Yes" : "No", title: "Names are Truncated"),
            SimpleTextCellProvider(value: mrzResult.optional.valueOrNil, title: "Optional"),
            SimpleTextCellProvider(value: mrzResult.optional1.valueOrNil, title: "Optional 1"),
            SimpleTextCellProvider(value: mrzResult.capturedMrz, title: "Captured MRZ")
        ]
        self.rows = commonRows + mrzRows
    }
}

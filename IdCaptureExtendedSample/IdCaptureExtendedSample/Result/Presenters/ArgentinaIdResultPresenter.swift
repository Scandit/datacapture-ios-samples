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

import UIKit
import ScanditIdCapture

class ArgentinaIdResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.argentinaIdBarcodeResult))
        guard let argentinaIdBarcodeResult = capturedId.argentinaIdBarcodeResult else {
            fatalError("Unexpected null ArgentinaIdBarcodeResult")
        }

        let commonRows = Self.getCommonRows(for: capturedId)
        let argentinaIdRows: [CellProvider] = [
            SimpleTextCellProvider(value: argentinaIdBarcodeResult.documentCopy, title: "Document Copy"),
            SimpleTextCellProvider(value: argentinaIdBarcodeResult.personalIdNumber, title: "Personal ID Number")
        ]
        self.rows = commonRows + argentinaIdRows
    }
}

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

class ColombiaDlBarcodeResultPresenter: ResultPresenter {
    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.colombiaDlBarcodeResult))
        guard let result = capturedId.colombiaDlBarcodeResult else {
            fatalError("Unexpected null ColombiaDlBarcodeResult")
        }
        let commonRows = Self.getCommonRows(for: capturedId)
        let specificRows: [CellProvider] = [
            SimpleTextCellProvider(value: result.categories.joined(separator: ", "), title: "Categories"),
            SimpleTextCellProvider(value: result.identificationType, title: "Identification Type")
        ]
        self.rows = commonRows + specificRows
    }
}
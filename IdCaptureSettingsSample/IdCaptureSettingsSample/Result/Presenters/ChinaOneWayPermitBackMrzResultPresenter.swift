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

final class ChinaOneWayPermitBackMrzResultPresenter: ResultPresenter {
    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.chinaOneWayPermitBackMrzResult))
        guard let result = capturedId.chinaOneWayPermitBackMrzResult else {
            fatalError("Unexpected null ChinaOneWayPermitBackMrzResult")
        }

        rows = [
            SimpleTextCellProvider(value: result.documentCode, title: "Document Code"),
            SimpleTextCellProvider(value: result.capturedMrz, title: "Captured MRZ")
        ]
    }
}

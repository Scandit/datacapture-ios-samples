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

class VizResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        var cells = [CellProvider]()
        if let image = capturedId.idImage(of: .idFront) {
            cells.append(ImageCellProvider(image: image, title: "Front Image"))
        }
        if let image = capturedId.idImage(of: .idBack) {
            cells.append(ImageCellProvider(image: image, title: "Back Image"))
        }
        rows = cells
    }
}

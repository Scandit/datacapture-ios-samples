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

import ScanditBarcodeCapture
import UIKit

/// The Item struct for represent each scanned Barcode, with all information needed by TableViewCell.
struct Item: Equatable {
    /// The image of the scanned barcode.
    private(set) var image: UIImage?

    /// Sequence number for scanned barcode.
    let number: Int

    /// The symbology of scanned barcode.
    let symbology: Symbology

    /// Data contained in scanned barcode.
    let data: String

    /// Computed var to get from symbology an human-readable name.
    var symbologyReadableName: String {
        SymbologyDescription
            .init(symbology: symbology)
            .readableName
    }
}

extension Item {
    init(
        barcode: Barcode,
        number: Int,
        image: UIImage?
    ) {
        self.init(
            image: image,
            number: number,
            symbology: barcode.symbology,
            data: barcode.data ?? ""
        )
    }
}

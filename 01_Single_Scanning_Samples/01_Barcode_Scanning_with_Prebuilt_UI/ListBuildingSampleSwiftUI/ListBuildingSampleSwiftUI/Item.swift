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

import Foundation
import ScanditBarcodeCapture
import UIKit

struct Item: Identifiable, Equatable {
    let id = UUID()

    private(set) var images: [UIImage]?
    let number: Int
    let symbology: Symbology
    let data: String
    private(set) var quantity: Int = 1

    var symbologyReadableName: String {
        SymbologyDescription(symbology: symbology).readableName
    }

    mutating func increaseQuantity(with thumbnail: UIImage?) {
        quantity += 1
        if let thumbnail {
            images?.append(thumbnail)
        }
    }
}

extension Item {
    init(barcode: Barcode, number: Int, image: UIImage?) {
        self.init(
            images: image.map { [$0] },
            number: number,
            symbology: barcode.symbology,
            data: barcode.data ?? ""
        )
    }
}

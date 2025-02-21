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

import UIKit
import ScanditBarcodeCapture

enum Discount: CaseIterable {
    case small
    case medium
    case large

    var percentage: String {
        switch self {
        case .small: return "25% off"
        case .medium: return "50% off"
        case .large: return "75% off"
        }
    }

    var color: UIColor {
        switch self {
        case .small: return UIColor(red: 255/255, green: 220/255, blue: 50/255, alpha: 0.9)
        case .medium: return UIColor(red: 250/255, green: 135/255, blue: 25/255, alpha: 0.9)
        case .large: return UIColor(red: 250/255, green: 68/255, blue: 70/255, alpha: 0.9)
        }
    }

    var expirationMessage: String {
        switch self {
        case .small: return "Expires in 3 days"
        case .medium: return "Expires in 2 days"
        case .large: return "Expires in 1 day"
        }
    }

    var expirationDate: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        let expiryDate = calendar.date(byAdding: .day, value: daysUntilExpiry, to: Date())!
        return dateFormatter.string(from: expiryDate)
    }

    var daysUntilExpiry: Int {
        switch self {
        case .small: return 3
        case .medium: return 2
        case .large: return 1
        }
    }
}

class DiscountProvider {
    private var currentIndex = 0
    private var barcodeDiscounts: [String: Discount] = [:]

    func getDiscountForBarcode(_ barcode: Barcode) -> Discount {
        let barcodeData = barcode.data ?? ""
        if let discount = barcodeDiscounts[barcodeData] {
            return discount
        }

        let discount = Discount.allCases[currentIndex]
        barcodeDiscounts[barcodeData] = discount
        currentIndex = (currentIndex + 1) % Discount.allCases.count

        return discount
    }
}

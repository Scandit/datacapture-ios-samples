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

struct Product: Hashable, Comparable {
    let identifier: String?
    let itemDataList: [String]
    var quantity: Int = 1
    var quantityToPick: Int
    var inList: Bool

    static func < (lhs: Product, rhs: Product) -> Bool {
        let id1 = lhs.identifier
        let id2 = rhs.identifier
        if let id1, let id2 {
            return id1 < id2
        }
        if id1 != nil {
            return true
        }
        return lhs.itemDataList.min() ?? "" < rhs.itemDataList.min() ?? ""
    }
}

struct PickItem {
    let productIdentifier: String?
    let data: String
    let inList: Bool
    // Product is in list but the pick exceeds the quantity to pick
    let extraPick: Bool

    static func < (lhs: PickItem, rhs: PickItem) -> Bool {
        let id1 = lhs.productIdentifier
        let id2 = rhs.productIdentifier
        if let id1, let id2 {
            return id1 < id2
        }
        if id1 != nil {
            return true
        }
        return lhs.data < rhs.data
    }
}

class PickSessionStore {
    let productsToPick: Set<BarcodePickProduct>
    let itemDataToProductIdentifier: [String: String]

    init(productsToPick: Set<BarcodePickProduct>, itemDataToProductIdentifier: [String: String]) {
        self.productsToPick = productsToPick
        self.itemDataToProductIdentifier = itemDataToProductIdentifier
    }

    private(set) var pickedItems: [PickItem] = []
    private(set) var inventoryItems: [PickItem] = []

    private func productToPickForIdentifier(_ identifier: String) -> BarcodePickProduct? {
        productsToPick.first { $0.identifier == identifier }
    }

    private func isCodeInList(_ code: String) -> Bool {
        guard let productIdentifier = itemDataToProductIdentifier[code] else {
            return false
        }
        return productToPickForIdentifier(productIdentifier) != nil
    }

    func update(pickedItems: Set<String>, scannedItems: Set<String>) {
        updatePickedItems(pickedItems)
        updateScannedItems(scannedItems.subtracting(pickedItems))
    }

    private func updatePickedItems(_ items: Set<String>) {
        pickedItems = items.reduce(
            [],
            { partialResult, code in
                let productIdentifier = itemDataToProductIdentifier[code]
                let isList = isCodeInList(code)
                let newItem: PickItem
                if let productIdentifier, let productToPick = productToPickForIdentifier(productIdentifier) {
                    let alreadyScannedProductCount = partialResult.reduce(0) { partialResult, item in
                        partialResult + (item.productIdentifier == productIdentifier ? 1 : 0)
                    }
                    let extraPick = alreadyScannedProductCount >= productToPick.quantityToPick
                    newItem = PickItem(
                        productIdentifier: productIdentifier,
                        data: code,
                        inList: isList,
                        extraPick: extraPick
                    )
                } else {
                    newItem = PickItem(
                        productIdentifier: productIdentifier,
                        data: code,
                        inList: false,
                        extraPick: false
                    )
                }
                return partialResult + [newItem]
            }
        ).sorted(by: <)
    }

    private func updateScannedItems(_ items: Set<String>) {
        inventoryItems = items.map { code in
            let productIdentifier = itemDataToProductIdentifier[code]
            return PickItem(
                productIdentifier: productIdentifier,
                data: code,
                inList: isCodeInList(code),
                extraPick: false
            )
        }.sorted(by: <)
    }
}

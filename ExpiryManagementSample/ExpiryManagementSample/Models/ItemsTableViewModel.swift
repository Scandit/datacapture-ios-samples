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

class ItemsTableViewModel {
    private let parser: BarcodeParser?
    private var items: [Item] = [] {
        didSet {
            onDataUpdated?()
        }
    }
    private var barcodes: [Barcode] = []

    var onDataUpdated: (() -> Void)? {
        didSet {
            onDataUpdated?()
        }
    }

    init(parser: BarcodeParser?) {
        self.parser = parser
    }

    func addBarcode(_ barcode: Barcode) {
        var isExpired = false
        if let data = barcode.data, let parser {
            isExpired = parser.isItemExpired(barcodeData: data)
        }
        barcodes.append(barcode)

        if let itemIndex = items.firstIndex(where: { item in
            return item.data == barcode.data && item.symbology == barcode.symbology
        }) {
            let item = items[itemIndex]
            items[itemIndex] = item.copyWithIncreasedQuantity()
        } else {
            items.append(.init(barcode: barcode, isExpired: isExpired))
        }
    }

    func allBarcodes() -> [Barcode] {
        barcodes
    }

    func clear() {
        barcodes.removeAll()
        items.removeAll()
    }

    func count() -> Int {
        items.count
    }

    func numberOfItems() -> Int {
        return items.reduce(0) { partialResult, item in
            partialResult + item.quantity
        }
    }

    func itemAtIndex(_ index: Int) -> Item {
        items[index]
    }

    func deleteItemAtIndex(_ index: Int) {
        let item = itemAtIndex(index)
        barcodes.removeAll { $0.matchesItem(item) }
        items.remove(at: index)
    }

    func itemForBarcode(barcode: Barcode) -> Item? {
        guard let barcodeData = barcode.data else {
            return nil
        }

        return items.first { item in
            item.data == barcodeData && item.symbology == barcode.symbology
        }
    }
}

private extension Barcode {
    func matchesItem(_ item: Item) -> Bool {
        guard let data else {
            return false
        }
        return symbology == item.symbology && data == item.data
    }
}

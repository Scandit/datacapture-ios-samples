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

@MainActor
class SparkScanViewModel: NSObject, ObservableObject {
    @Published var items: [Item] = []
    @Published var totalItemsCount: Int = 0

    lazy var sparkScanViewController: SparkScanViewController = {
        let viewController = SparkScanViewController()
        viewController.delegate = self
        return viewController
    }()

    private func item(for barcode: Barcode) -> Item? {
        items.first { $0.symbology == barcode.symbology && $0.data == barcode.data }
    }

    func addItem(_ item: Item) {
        items.insert(item, at: 0)
        updateTotalCount()
    }

    func increaseQuantity(for item: Item, with thumbnail: UIImage?) {
        if let index = items.firstIndex(of: item) {
            var updatedItem = items.remove(at: index)
            updatedItem.increaseQuantity(with: thumbnail)
            items.insert(updatedItem, at: 0)
            updateTotalCount()
        }
    }

    func clearItems() {
        items.removeAll()
        updateTotalCount()
    }

    private func updateTotalCount() {
        totalItemsCount = items.reduce(0) { $0 + $1.quantity }
    }
}

extension SparkScanViewModel: SparkScanViewControllerDelegate {
    nonisolated func sparkScanViewController(
        _ viewController: SparkScanViewController,
        didScanBarcode barcode: Barcode,
        thumbnail: UIImage?
    ) {
        Task { @MainActor in
            if !barcode.isRejected {
                if let existingItem = item(for: barcode) {
                    increaseQuantity(for: existingItem, with: thumbnail)
                } else {
                    addItem(Item(barcode: barcode, number: items.count + 1, image: thumbnail))
                }
            }
        }
    }

    nonisolated func sparkScanViewController(
        _ viewController: SparkScanViewController,
        feedbackFor barcode: Barcode
    ) -> SparkScanBarcodeFeedback? {
        guard !barcode.isRejected else {
            return SparkScanBarcodeErrorFeedback(
                message: "Wrong barcode",
                resumeCapturingDelay: 60
            )
        }
        return SparkScanBarcodeSuccessFeedback()
    }
}

private extension Barcode {
    var isRejected: Bool {
        data == "123456789"
    }
}

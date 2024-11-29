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
import UIKit

class WeightedItemCell: UITableViewCell {
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var barcodeDataLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    var hideSeparator: Bool {
        get { separatorView.isHidden }
        set { separatorView.isHidden = newValue }
    }

    func configure(with item: Item, title: String) {
        guard item.type == .weighted else { return }
        itemNameLabel.text = title
        barcodeDataLabel.text = item.data
        weightLabel.text = item.weight
        unitPriceLabel.text = item.unitPrice
        quantityLabel.text = "QTY \(item.quantity)"
        quantityLabel.isHidden = item.quantity <= 1
    }
}

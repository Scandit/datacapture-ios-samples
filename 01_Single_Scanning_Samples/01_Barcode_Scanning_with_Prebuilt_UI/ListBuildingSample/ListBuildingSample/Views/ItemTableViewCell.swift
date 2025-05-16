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

class ItemTableViewCell: UITableViewCell {
    /// This identifier is also in Main storyboard.
    static let identifier = "ItemTableViewCell"

    @IBOutlet private weak var stackedImageView: StackedImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!

    func configure(with item: Item) {
        titleLabel.text = item.data
        subtitleLabel.text = item.symbologyReadableName
        quantityLabel.text = "Qty: \(item.quantity)"
        quantityLabel.isHidden = item.quantity < 2
        stackedImageView.images = item.images?.suffix(3).compactMap {
            guard let cgImage = $0.cgImage else { return nil }
            return UIImage(
                cgImage: cgImage,
                scale: $0.scale,
                orientation: .right
            )
        }
    }
}

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

class ListCell: UITableViewCell {
    static let reuseIdentifier = "ListCell"

    private enum Constants {
        static let imageBackgroundcolor = UIColor(red: 0.945, green: 0.961, blue: 0.973, alpha: 1.0)
        static let imageSize: CGFloat = 48

        static let symbologyFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let dataTextColor = UIColor(red: 0.529, green: 0.584, blue: 0.631, alpha: 1.0)
        static let dataFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let quantityTextColor = UIColor(red: 0.376, green: 0.435, blue: 0.482, alpha: 1.0)
        static let quantityFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

        /// Creates a separation to the next cell
        static let containerBottomMargin: CGFloat = 4
        static let imageMargin: CGFloat = 16
        static let imageToNameHorizontalSpacing: CGFloat = 16
        static let nameToDataVerticalSpacing: CGFloat = 4
        static let quantityMargin: CGFloat = 16
    }

    let containerView = UIView()
    let itemImageView = UIImageView()
    let nameLabel = UILabel()
    let dataLabel = UILabel()
    let quantityLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        addConstraints([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                constant: Constants.containerBottomMargin)
        ])

        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.backgroundColor = Constants.imageBackgroundcolor
        containerView.addSubview(itemImageView)
        addConstraints([
            itemImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                   constant: Constants.imageMargin),
            itemImageView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                               constant: Constants.imageMargin),
            itemImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            itemImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize)
        ])

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        nameLabel.font = Constants.symbologyFont
        addConstraints([
            nameLabel.topAnchor.constraint(equalTo: itemImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor,
                                                    constant: Constants.imageToNameHorizontalSpacing)
        ])

        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dataLabel)
        dataLabel.textColor = Constants.dataTextColor
        dataLabel.font = Constants.dataFont
        addConstraints([
            dataLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dataLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                           constant: Constants.nameToDataVerticalSpacing)
        ])

        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(quantityLabel)
        quantityLabel.textColor = Constants.quantityTextColor
        quantityLabel.font = Constants.quantityFont
        addConstraints([
            quantityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                    constant: -Constants.quantityMargin),
            quantityLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        nameLabel.text = nil
        dataLabel.text = nil
        quantityLabel.text = nil
        quantityLabel.isHidden = true
    }

    func configureWithScannedItem(_ item: ScannedItem, index: Int) {
        let displayIndex = index + 1
        nameLabel.text = item.quantity > 1 ? "Non-unique item \(displayIndex)" : "Item \(displayIndex)"
        dataLabel.text = "\(item.symbology): \(item.data)"
        if item.quantity > 1 {
            quantityLabel.isHidden = false
            quantityLabel.text = "Qty: \(item.quantity)"
        }
    }
}

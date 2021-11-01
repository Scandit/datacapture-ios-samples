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

import UIKit

final class ModeCell: UICollectionViewCell {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override var isSelected: Bool {
        didSet {
            update()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            update()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = nil
    }

    private func setup() {
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Neue", size: 16)
    }

    private func update() {
        if self.isSelected || self.isHighlighted {
            self.contentView.backgroundColor = .white
            self.label.textColor = UIColor(red: 27/255, green: 32/255, blue: 38/255, alpha: 1)
        } else {
            self.contentView.backgroundColor = nil
            self.label.textColor = .white
        }
    }

}

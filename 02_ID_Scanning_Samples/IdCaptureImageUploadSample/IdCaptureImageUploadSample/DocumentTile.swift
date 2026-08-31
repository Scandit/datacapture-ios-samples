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

/// A tappable tile that shows a placeholder prompt until an image is chosen, then its thumbnail.
final class DocumentTile: UIControl {

    private let placeholderLabel = UILabel()
    private let thumbnailView = UIImageView()

    init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true

        placeholderLabel.text = placeholder
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = .preferredFont(forTextStyle: .body)
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false

        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.isUserInteractionEnabled = false
        thumbnailView.isHidden = true

        for subview in [placeholderLabel, thumbnailView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                subview.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            ])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage?) {
        thumbnailView.image = image
        thumbnailView.isHidden = image == nil
        placeholderLabel.isHidden = image != nil
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.4 }
    }
}

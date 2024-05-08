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

final class HintView: UIView {
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 4.0
        backgroundColor = .white.withAlphaComponent(0.8)

        addSubview(label)
        label.textColor = UIColor(red: 0.071, green: 0.086, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "SFProDisplay-Bold", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16.0),
            trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16.0),
            topAnchor.constraint(equalTo: label.topAnchor, constant: -8.0),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

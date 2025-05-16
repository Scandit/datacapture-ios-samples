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

class StockOverlay: UIView {

    private enum Constants {
        static let contentWidth: CGFloat = 171
        static let contentHeight: CGFloat = 56
        static let taskLabelToContentHorizontalSpace: CGFloat = 16
        static let taskLabelToContentVerticalSpace: CGFloat = 10
        static let taskLabelTextColor: UIColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
        static let taskLogoBackgroundColor: UIColor = UIColor(red: 0.35, green: 0.84, blue: 0.78, alpha: 1.0)
    }

    private let model: StockModel

    private(set) var shouldUpdateConstraints = true

    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.contentHeight / 2
        return view
    }()

    private lazy var taskLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Constants.taskLabelTextColor
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.textAlignment = .center
        label.attributedText = self.taskAttributedText
        return label
    }()

    private lazy var barcodeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = Constants.taskLabelTextColor
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = true
        label.text = self.model.barcodeData
        return label
    }()

    private lazy var effectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blur)

        return blurView
    }()

    init(with model: StockModel) {
        self.model = model
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.contentWidth, height: Constants.contentHeight))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(contentView)
        contentView.addSubview(effectView)
        contentView.addSubview(taskLabel)
        contentView.addSubview(barcodeLabel)
        update()
        updateConstraints()
    }

    override func updateConstraints() {
        if shouldUpdateConstraints {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            effectView.translatesAutoresizingMaskIntoConstraints = false
            taskLabel.translatesAutoresizingMaskIntoConstraints = false
            barcodeLabel.translatesAutoresizingMaskIntoConstraints = false
            addConstraints([
                widthAnchor.constraint(lessThanOrEqualToConstant: Constants.contentWidth),
                heightAnchor.constraint(equalToConstant: Constants.contentHeight),

                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

                taskLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: Constants.taskLabelToContentHorizontalSpace
                ),
                taskLabel.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: Constants.taskLabelToContentVerticalSpace
                ),
                taskLabel.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -Constants.taskLabelToContentHorizontalSpace
                ),
                taskLabel.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor,
                    constant: -Constants.taskLabelToContentVerticalSpace
                ),

                barcodeLabel.centerYAnchor.constraint(equalTo: taskLabel.centerYAnchor),
                barcodeLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor),
                barcodeLabel.widthAnchor.constraint(equalTo: taskLabel.widthAnchor),
                barcodeLabel.heightAnchor.constraint(equalTo: taskLabel.heightAnchor, multiplier: 0.5),

                effectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                effectView.topAnchor.constraint(equalTo: contentView.topAnchor),
                effectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                effectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
            contentView.setContentHuggingPriority(.required, for: .horizontal)
            shouldUpdateConstraints.toggle()
        }
        super.updateConstraints()
    }

    private func update() {
        taskLabel.attributedText = taskAttributedText
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleShowingBarcodeData))
        contentView.addGestureRecognizer(tapRecognizer)
    }

    @objc private func toggleShowingBarcodeData() {
        taskLabel.isHidden.toggle()
        barcodeLabel.isHidden = !taskLabel.isHidden
    }

    private var taskAttributedText: NSAttributedString {
        let firstLineAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
        ]
        let attributedString = NSMutableAttributedString(
            string: "Report stock count",
            attributes: firstLineAttributes
        )
        attributedString.append(NSAttributedString(string: "\n"))
        let secondLineAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)
        ]
        let secondLine = NSAttributedString(
            string: "Shelf: \(model.shelfCount) Back: \(model.backroomCount)",
            attributes: secondLineAttributes
        )
        attributedString.append(secondLine)
        return attributedString
    }

}

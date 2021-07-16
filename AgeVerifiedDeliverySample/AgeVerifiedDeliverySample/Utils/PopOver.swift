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

import Foundation
import UIKit
public class PopOver<View: UIView>: UIView {

    public let content: View = (View.self as View.Type).init()

    private let arrow = PopOverArrow()

    private let contentContainer = UIView()

    private let triangleHeight: CGFloat = 10

    public var cornerRadius: CGFloat = 6 {
        didSet {
            contentContainer.layer.cornerRadius = cornerRadius
        }
    }

    public override var backgroundColor: UIColor? {
        get {
            return contentContainer.backgroundColor
        }
        set {
            contentContainer.backgroundColor = newValue
            arrow.backgroundColor = newValue
        }
    }

    public var margins: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) {
        didSet {
            self.contentTopConstraint.constant = margins.top
            self.contentLeftConstraint.constant = margins.left
            self.contentBottomConstraint.constant = margins.bottom
            self.contentRightConstraint.constant = margins.right
        }
    }

    public var tipCenter: CGPoint {
        get {
            let center = self.center
            let b = self.bounds
            let deltaY = b.maxY - (b.maxY - b.minY) / 2

            return CGPoint(
                x: center.x, // Always centered horizontally
                y: center.y + deltaY
            )
        }
        set {
            let tipCenter = self.tipCenter
            let deltaX = newValue.x - tipCenter.x
            let deltaY = newValue.y - tipCenter.y
            self.center = CGPoint(
                x: self.center.x + deltaX,
                y: self.center.y + deltaY
            )
        }
    }

    init() {
        super.init(frame: .zero)
        self.setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private var contentTopConstraint: NSLayoutConstraint!
    private var contentLeftConstraint: NSLayoutConstraint!
    private var contentBottomConstraint: NSLayoutConstraint!
    private var contentRightConstraint: NSLayoutConstraint!

    func setupUI() {
        [arrow, contentContainer, content].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        self.addSubview(arrow)
        self.addSubview(contentContainer)
        contentContainer.addSubview(content)

        contentTopConstraint = content.topAnchor
            .constraint(equalTo: contentContainer.topAnchor, constant: margins.top)
        contentLeftConstraint = content.leftAnchor
            .constraint(equalTo: contentContainer.leftAnchor, constant: margins.left)
        contentBottomConstraint = contentContainer.bottomAnchor
            .constraint(equalTo: content.bottomAnchor, constant: margins.bottom)
        contentRightConstraint = contentContainer.rightAnchor
            .constraint(equalTo: content.rightAnchor, constant: margins.right)
        [contentTopConstraint, contentLeftConstraint, contentBottomConstraint, contentRightConstraint].forEach {
            $0?.priority = .required
            $0?.isActive = true
        }

        NSLayoutConstraint.activate([
            contentContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentContainer.widthAnchor.constraint(equalTo: self.widthAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentContainer.widthAnchor.constraint(
                greaterThanOrEqualTo: arrow.widthAnchor, constant: cornerRadius * 2),
            contentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 8)
        ])

        [self, contentContainer, content].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }

        let arrowWidth = arrow.widthAnchor.constraint(equalToConstant: (triangleHeight+1) * 2)
        arrowWidth.priority = .required
        let arrowHeight = arrow.heightAnchor.constraint(equalToConstant: (triangleHeight+1))
        arrowHeight.priority = .required

        NSLayoutConstraint.activate([
            arrow.topAnchor.constraint(equalTo: self.topAnchor),
            arrow.bottomAnchor.constraint(equalTo: contentContainer.topAnchor),
            arrow.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            arrowWidth,
            arrowHeight
        ])

        contentContainer.clipsToBounds = true
        contentContainer.layer.cornerRadius = cornerRadius

        super.backgroundColor = .clear
        self.backgroundColor = .white
    }

    public override func sizeToFit() {
        self.frame.size = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

private class PopOverArrow: UIView {

    private let maskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    func setupUI() {
        setupMask()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupMask()
    }

    // swiftlint:disable all
    func setupMask() {
        let w = self.bounds.width
        let h = self.bounds.height
        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w/2, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.close()

        maskLayer.path = path.cgPath

        self.layer.mask = maskLayer
    }
    // swiftlint:enable all
}

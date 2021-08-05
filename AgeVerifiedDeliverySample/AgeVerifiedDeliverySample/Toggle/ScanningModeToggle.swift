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

enum ScanningMode {
    case barcode
    case viz
}

final class ScanningModeToggle: UIView {

    @IBOutlet private var backgroundLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var barcodeImageView: UIImageView!
    @IBOutlet private var vizImageView: UIImageView!

    private var gestureRecognizer: UITapGestureRecognizer?
    private var leftSwipeRecognizer: UISwipeGestureRecognizer?
    private var rightSwipeRecognizer: UISwipeGestureRecognizer?

    weak var delegate: DocumentTypeToggleListener?

    private(set) var state: ScanningMode = .barcode

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        loadNib()
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleTapped))
        leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toggleSwipedLeft))
        leftSwipeRecognizer?.direction = .left
        rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toggleSwipedRight))
        rightSwipeRecognizer?.direction = .right
        guard let gestureRecognizer = gestureRecognizer,
            let leftSwipeRecognizer = leftSwipeRecognizer,
            let rightSwipeRecognizer = rightSwipeRecognizer else { return }
        addGestureRecognizer(gestureRecognizer)
        addGestureRecognizer(leftSwipeRecognizer)
        addGestureRecognizer(rightSwipeRecognizer)
    }

    @objc private func toggleSwipedLeft() {
        if state == .viz {
            switchToggle()
        }
    }

    @objc private func toggleSwipedRight() {
        if state == .barcode {
            switchToggle()
        }
    }

    @objc private func toggleTapped() {
        switchToggle()
    }

    private func switchToggle() {
        UIView.animate(withDuration: 0.4) {
            switch self.state {
            case .barcode:
                self.setVizScanning()
            case .viz:
                self.setBarcodeScanning()
            }
            self.layoutIfNeeded()
        }
        delegate?.toggleDidChange(newState: state)
    }

    private func setVizScanning() {
        self.state = .viz
        self.backgroundLeadingConstraint.isActive = false
        self.barcodeImageView.tintColor = .white
        self.vizImageView.tintColor = .black
    }

    private func setBarcodeScanning() {
        self.state = .barcode
        self.backgroundLeadingConstraint.isActive = true
        self.barcodeImageView.tintColor = .black
        self.vizImageView.tintColor = .white
    }

    func reset() {
        setBarcodeScanning()
    }

    private func loadNib() {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)),
                                                  owner: self,
                                                  options: nil)?.first as? UIView
        else { fatalError("Cannot load nib named \(String(describing: self))") }
        addSubview(view)
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

}

protocol DocumentTypeToggleListener: AnyObject {
    func toggleDidChange(newState: ScanningMode)
}

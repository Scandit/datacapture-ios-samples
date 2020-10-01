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

class TouchIgnoringTextField: UITextField {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

protocol NibLoadable {
    func loadNib()
}

extension NibLoadable where Self: UIView {
    func loadNib() {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)),
                                                  owner: self,
                                                  options: nil)?.first as? UIView
            else { fatalError("Cannot load nib named \(String(describing: self))") }
        addSubview(view)
        view.constrainToFill(superview: self)
    }
}

fileprivate extension UIView {
    func constrainToFill(superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            widthAnchor.constraint(equalTo: superview.widthAnchor),
            heightAnchor.constraint(equalTo: superview.heightAnchor)
        ])
    }
}

class StockOverlay: UIView, NibLoadable {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var countTextField: UITextField!

    private var shouldClearContents = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func bind(to barcode: String) {
        let lastDigit = barcode.last!.wholeNumberValue!
        if lastDigit % 2 == 0 {
            backgroundImageView.tintColor = .red
        } else {
            backgroundImageView.tintColor = .white
        }
    }

    private func commonInit() {
        loadNib()
        let inputView = StockInputView(frame: CGRect(x: 0,
                                                     y: 0,
                                                     width: UIScreen.main.bounds.width,
                                                     height: 268))
        inputView.delegate = self
        countTextField.inputView = inputView
    }

    @IBAction func didTapOnOverlay(_ sender: Any) {
        backgroundImageView.tintColor = .white
        countTextField.becomeFirstResponder()
    }
}

extension StockOverlay: StockInputHandling {
    func stockInputView(_ view: StockInputView, didReceive value: StockInputValue) {
        switch value {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if shouldClearContents {
                countTextField.text = ""
                shouldClearContents = false
            }
            countTextField.text?.append("\(value.rawValue)")
        case .delete:
            guard var text = countTextField.text, text.count > 0 else { return }
            text.removeLast()
            countTextField.text = text
        case .accept:
            countTextField.resignFirstResponder()
        }
    }
}

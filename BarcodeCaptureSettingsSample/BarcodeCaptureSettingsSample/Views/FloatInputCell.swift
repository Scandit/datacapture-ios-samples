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

protocol FloatInputCellDelegate: AnyObject {
    func didChange(value: CGFloat, forCell cell: FloatInputCell)
}

class FloatInputCell: UITableViewCell {

    weak var delegate: FloatInputCellDelegate?

    private var textField: UITextField!

    private lazy var numberFormatter = NumberFormatter(maximumFractionDigits: 2)

    var value: CGFloat {
        get {
            guard let text = textField.text, let value = numberFormatter.number(from: text) else {
                return 0
            }

            return CGFloat(value.floatValue)
        }
        set {
            textField.text = numberFormatter.string(from: newValue)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startEditing() {
        textField.becomeFirstResponder()
    }

    private func setupTextField() {
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 28))
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad

        textField.font = UITableViewCell.defaultDetailTextFont
        textField.textColor = UITableViewCell.defaultDetailTextColor

        accessoryView = textField
    }

    @objc func textFieldChanged(_ textField: UITextField) {
        delegate?.didChange(value: value, forCell: self)
    }

    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = numberFormatter.string(from: value)
    }
}

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

protocol TextEditCellDelegate: AnyObject {
    func didChange(value: String, forCell cell: TextEditCell)
}

class TextEditCell: UITableViewCell {

    weak var delegate: TextEditCellDelegate?

    private var textField: UITextField!

    var value: String {
        get {
            return textField.text.valueOrEmpty
        }
        set {
            textField.text = newValue
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextField() {
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 28))
        textField.isUserInteractionEnabled = false
        textField.textAlignment = .right
        textField.font = UITableViewCell.defaultDetailTextFont
        textField.textColor = UITableViewCell.defaultDetailTextColor

        accessoryView = textField
    }
}

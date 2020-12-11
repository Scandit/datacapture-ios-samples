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

protocol SwitchCellDelegate: AnyObject {
    func didChange(value: Bool, forSwitchCell switchCell: SwitchCell)
}

class SwitchCell: UITableViewCell {

    weak var delegate: SwitchCellDelegate?

    private var switchButton: UISwitch!

    var isOn: Bool {
        get {
            return switchButton.isOn
        }
        set {
            switchButton.setOn(newValue, animated: true)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwitch()
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSwitch() {
        switchButton = UISwitch()
        switchButton.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        accessoryView = switchButton
    }

    @objc func switchChanged(switchButton: UISwitch) {
        delegate?.didChange(value: switchButton.isOn, forSwitchCell: self)
    }

}

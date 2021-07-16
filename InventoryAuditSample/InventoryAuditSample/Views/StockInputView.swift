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

enum StockInputValue: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case delete = 10
    case accept = 11
}

protocol StockInputHandling: AnyObject {
    func stockInputView(_ view: StockInputView,
                        didReceive value: StockInputValue)
}

class StockInputView: UIView, NibLoadable {

    weak var delegate: StockInputHandling?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        loadNib()
        backgroundColor = UIColor(sdcHexString: "#00000033")
    }

    @IBAction private func buttonDidTap(_ sender: UIButton) {
        if let value = StockInputValue(rawValue: sender.tag) {
            delegate?.stockInputView(self, didReceive: value)
        }
    }
}

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

protocol SliderCellDelegate: AnyObject {
    func didChange(value: CGFloat, forCell cell: SliderCell)
}

class SliderCell: UITableViewCell {

    weak var delegate: SliderCellDelegate?

    @IBOutlet private var slider: UISlider!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel! {
        didSet {
            valueLabel.font = UITableViewCell.defaultDetailTextFont
            valueLabel.textColor = UITableViewCell.defaultDetailTextColor
        }
    }

    var minimumValue: Float {
        get {
            return slider.minimumValue
        }
        set {
            slider.minimumValue = newValue
        }
    }
    var maximumValue: Float {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue
        }
    }

    var value: CGFloat {
        get {
            if let roundingRule = roundingRule {
                return CGFloat(slider.value.rounded(roundingRule))
            }
            return CGFloat(slider.value.rounded(toNumberOfDecimalPlaces: maximumNumberOfDecimalPlaces))
        }
        set {
            slider.value = Float(newValue)
        }
    }

    /// Specify a rounding rule to use for the slider value, to e.g. restrict the values to round numbers
    var roundingRule: FloatingPointRoundingRule? {
        didSet {
            if let roundingRule = roundingRule {
                slider.value = slider.value.rounded(roundingRule)
            }
        }
    }

    var maximumNumberOfDecimalPlaces: Int = 2 {
        didSet {
            numberFormatter.maximumFractionDigits = maximumNumberOfDecimalPlaces
            slider.value = slider.value.rounded(toNumberOfDecimalPlaces: maximumNumberOfDecimalPlaces)
        }
    }

    lazy var numberFormatter = NumberFormatter(maximumFractionDigits: maximumNumberOfDecimalPlaces)

    override var textLabel: UILabel? {
        return self.titleLabel
    }

    override var detailTextLabel: UILabel? {
        return self.valueLabel
    }

    @IBAction func sliderChanged(_ slider: UISlider) {
        slider.value = Float(value)
        detailTextLabel?.text = numberFormatter.string(from: value)
        delegate?.didChange(value: value, forCell: self)
    }

}

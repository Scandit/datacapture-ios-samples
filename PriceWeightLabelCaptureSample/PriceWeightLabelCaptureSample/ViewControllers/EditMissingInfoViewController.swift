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

import Foundation
import UIKit

protocol EditMissingInfoViewControllerDelegate: AnyObject {
    func editMissingInfoViewController(_ viewController: EditMissingInfoViewController, didUpdate item: Item)
    func editMissingInfoViewControllerDidCancel(_ viewController: EditMissingInfoViewController)
}

class EditMissingInfoViewController: UIViewController {
    weak var delegate: EditMissingInfoViewControllerDelegate?
    var item: Item! {
        didSet {
            if isViewLoaded {
                update()
            }
        }
    }
    private var allInfoEntered: Bool {
        (weightTextField.text?.isNumber ?? false) && (unitPriceTextField.text?.isNumber ?? false)
    }

    private var contentLayoutGuide: UILayoutGuide!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var barcodeDataLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightTextFieldUnderline: UIView!
    @IBOutlet weak var unitPriceTextField: UITextField!
    @IBOutlet weak var unitPriceUnderline: UIView!
    @IBOutlet weak var addToListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        contentLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(contentLayoutGuide)
        NSLayoutConstraint.activate([
            contentLayoutGuide.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentLayoutGuide.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            contentLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)

        update()
    }

    private func update() {
        barcodeDataLabel.text = item.data
        weightTextField.text = item.weight
        weightTextField.isEnabled = item.weight == nil
        unitPriceTextField.text = item.unitPrice
        unitPriceTextField.isEnabled = item.unitPrice == nil
        updateAddToListButton()
    }

    private func updateAddToListButton() {
        addToListButton.isEnabled = allInfoEntered
        addToListButton.backgroundColor = addToListButton.isEnabled ? .black900 : .gray300
    }

    private func updateItemInfo() {
        item.weight = weightTextField.text
        item.unitPrice = unitPriceTextField.text
        delegate?.editMissingInfoViewController(self, didUpdate: item)
    }

    @IBAction func addToListButtonPressed(_ sender: Any) {
        updateItemInfo()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.editMissingInfoViewControllerDidCancel(self)
    }

    @IBAction func weightTextFieldDidChange(_ sender: Any) {
        updateAddToListButton()
    }

    @IBAction func unitPriceTextFieldDidChange(_ sender: Any) {
        updateAddToListButton()
    }
}

// MARK: UITextFieldDelegate

extension EditMissingInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == weightTextField {
            weightTextFieldUnderline.backgroundColor = .teal100
            unitPriceUnderline.backgroundColor = .gray400
        } else if textField == unitPriceTextField {
            weightTextFieldUnderline.backgroundColor = .gray400
            unitPriceUnderline.backgroundColor = .teal100
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == weightTextField || textField == unitPriceTextField,
              let text = textField.text as? NSString
        else { return true }

        let newText = text.replacingCharacters(in: range, with: string)
        if newText.isEmpty {
            return true
        }
        return newText.isNumber
    }
}

// MARK: SheetContentViewController

extension EditMissingInfoViewController: SheetContentViewController {
    var sheetPartialContentGuide: UILayoutGuide { contentLayoutGuide }

    func sheetContainerDidBeginDrag(_ viewController: SheetContainerViewController) {
        // Not needed
    }

    func sheetContainer(_ viewController: SheetContainerViewController,
                        willTransitionTo state: SheetContainerViewController.State,
                        animated: Bool) {
        if state == .collapsed {
            weightTextField.resignFirstResponder()
            unitPriceTextField.resignFirstResponder()
        }
    }

    func sheetContainer(_ viewController: SheetContainerViewController,
                        didTransitionTo state: SheetContainerViewController.State,
                        animated: Bool) {
        // Not needed
    }
}

// MARK: Keyboard handling

extension EditMissingInfoViewController {
    @objc func adjustForKeyboard(notification: Notification) {
        guard let endFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
              let durationValue = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else { return }

        let endFrame = view.convert(endFrameValue.cgRectValue, from: view.window)
        let animationCurve = UIView.AnimationCurve(rawValue: curveValue.intValue)!
        let animationDuration = durationValue.doubleValue

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.contentViewBottomConstraint.constant = 0
        } else {
            var value = self.contentViewBottomConstraint.constant
            value += contentView.frame.maxY - endFrame.minY
            self.contentViewBottomConstraint.constant = max(value, 0)
        }

        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) {
            self.view.window?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

// MARK: String helper methods

extension String {
    private static let numberFormatter = NumberFormatter()

    var isNumber: Bool {
        Self.numberFormatter.number(from: self) != nil
    }
}

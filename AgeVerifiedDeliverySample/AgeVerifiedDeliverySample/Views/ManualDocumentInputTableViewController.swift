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

var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/YYYY"
    return dateFormatter
}()

class ManualDocumentInputTableViewController: UITableViewController {

    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    var expirationDate: Date?
    var birthdayDate: Date?
    var fullname: String?

    var mainButtonTapped: (() -> Void)?
    var secondaryButtonTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.backgroundView?.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
        validateForm()
    }

    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 375, height: 326)
        }

        set {
            super.preferredContentSize = newValue
        }
    }

    @IBAction func confirmAction(_ sender: Any) {
        guard
            let deliveryResultViewController = storyboard?
                .instantiateViewController(identifier: "DeliveryResultViewController")
                as? DeliveryResultViewController else { return }
        deliveryResultViewController.configureWith(expirationDate: expirationDate,
                                                   birthDate: birthdayDate,
                                                   document: "Document")
        deliveryResultViewController.mainButtonTapped = mainButtonTapped
        deliveryResultViewController.secondaryButtonTapped = secondaryButtonTapped
        navigationController?.pushViewController(deliveryResultViewController, animated: true)
        navigationController?.navigationBar.isHidden = true
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true) {
            self.secondaryButtonTapped?()
        }
    }

    func presentDatePicker(_ sender: UITextField) {
        guard let controller = storyboard?
                .instantiateViewController(identifier: "DatePickerViewController")
                as? DatePickerViewController else { return }

        controller.didPickDateCompletion = { [weak self] date in
            guard let self = self else { return }
            if sender === self.birthdayTextField {
                self.birthdayDate = date
            } else {
                self.expirationDate = date
            }
            sender.text = dateFormatter.string(from: date)
            self.validateForm()
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    func validateForm() {
        let valid =
            birthdayDate != nil &&
            expirationDate != nil &&
            fullname != nil &&
            !fullname!.isEmpty
        confirmButton.isEnabled = valid
        confirmButton.backgroundColor = confirmButton.isEnabled ? .black : .gray
    }
}

extension ManualDocumentInputTableViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === fullNameTextField { return true }
        presentDatePicker(textField)
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        fullname = textField.text
        validateForm()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard var currentText = textField.text,
              !currentText.isEmpty else {
            fullname = string
            validateForm()
            return true
        }

        guard let replacementRange =
                Range<String.Index>(range, in: currentText) else {
            validateForm()
            return true
        }

        currentText.replaceSubrange(replacementRange,
                                    with: string)
        fullname = currentText
        validateForm()
        return true
    }
}

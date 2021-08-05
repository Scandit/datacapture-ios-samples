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
import ScanditIdCapture

extension Notification.Name {
    static let deliveryResultDidComplete = Notification.Name("deliveryResultDidComplete")
}

class DeliveryResultViewController: UIViewController {

    @IBOutlet weak var deliveryStatusImage: UIImageView!
    @IBOutlet weak var deliveryStatusLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(capturedId: CapturedId) {
        let document = capturedId.documentType == .passport ? "Passport" : "Driver's License"
        configureWith(expirationDate: capturedId.dateOfExpiry?.date,
                      birthDate: capturedId.dateOfBirth?.date,
                      document: document)
    }

    var titleAttributes: [NSAttributedString.Key: Any] {
        return [.foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 16)]
    }

    func configureUnderageDelivery() {
        titleLabel.text = "Verification Failed!"
        deliveryStatusLabel.text = "The recipient is underage."
        deliveryStatusImage.image = #imageLiteral(resourceName: "warning")
        mainButton.setAttributedTitle(NSAttributedString(string: "REFUSE DELIVERY",
                                                         attributes: titleAttributes),
                                      for: .normal)
        secondaryButton.setTitle("RETRY", for: .normal)
    }

    func configureExpiredDocument(_ documentType: String) {
        titleLabel.text = "Verification Failed!"
        deliveryStatusLabel.text = "\(documentType) is expired."
        deliveryStatusImage.image = #imageLiteral(resourceName: "warning")
        mainButton.setAttributedTitle(NSAttributedString(string: "REFUSE DELIVERY",
                                                         attributes: titleAttributes),
                                      for: .normal)
        secondaryButton.setTitle("RETRY", for: .normal)
    }

    func configureSuccessfullDelivery() {
        titleLabel.text = "Verification Successful!"
        deliveryStatusLabel.text = "Confirm delivery to proceed."
        deliveryStatusImage.image = #imageLiteral(resourceName: "check")
        mainButton.setAttributedTitle(NSAttributedString(string: "CONFIRM DELIVERY",
                                                         attributes: titleAttributes),
                                      for: .normal)
        secondaryButton.isHidden = true
        mainStackView.setNeedsLayout()
    }

    func configureWith(expirationDate: Date?, birthDate: Date?, document: String) {
        // Force the loading of the view
        _ = view

        // Expiration Check
        guard let dateOfExpiry = expirationDate,
              dateOfExpiry > Date.today.endOfDay else {
            // Expired Document
            configureExpiredDocument(document)
            return
        }

        // Underage check
        guard let dateOfBirth = birthDate,
              dateOfBirth.yearsSince(Date.today) >= 21 else {
            // Underage
            configureUnderageDelivery()
            return
        }

        // All good!
        configureSuccessfullDelivery()
    }

    @IBAction func mainButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name.deliveryResultDidComplete,
                                            object: nil)
        })
    }

    @IBAction func secondaryButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name.deliveryResultDidComplete,
                                            object: nil)
        })
    }

    override var preferredContentSize: CGSize {
        get {
            let size = mainStackView.systemLayoutSizeFitting(CGSize(width: 0, height: 0),
                                                             withHorizontalFittingPriority: .required,
                                                             verticalFittingPriority: .defaultLow)
            return CGSize(width: size.width+64, height: size.height+64)
        }

        set {
            super.preferredContentSize = newValue
        }
    }
}

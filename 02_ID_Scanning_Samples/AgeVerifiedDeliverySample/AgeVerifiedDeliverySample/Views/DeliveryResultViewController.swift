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

import ScanditIdCapture
import UIKit

class DeliveryResultViewController: UIViewController {

    @IBOutlet weak var deliveryStatusImage: UIImageView!
    @IBOutlet weak var deliveryStatusLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!

    var mainButtonTapped: (() -> Void)?
    var secondaryButtonTapped: (() -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var titleAttributes: [NSAttributedString.Key: Any] {
        [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 16),
        ]
    }

    private lazy var successFeedback = Feedback(
        vibration: Vibration.successHapticFeedback,
        sound: IdCaptureFeedback.defaultSuccessSound
    )

    private lazy var failureFeedback = Feedback(
        vibration: Vibration.failureHapticFeedback,
        sound: IdCaptureFeedback.defaultFailureSound
    )

    func configureWith(_ state: DeliveryLogic.State) {
        // Force the loading of the view
        _ = view

        switch state {
        case .idRequired: configureIdRequired()
        case .expired: configureExpiredDocument()
        case .success: configureSuccessfullDelivery()
        case .underage: configureUnderageDelivery()
        case .timeout: configureTimeOut()
        case .idRejected: configureIdRejected()
        }
        emitFeedback(state: state)
    }

    @IBAction func mainButtonAction(_ sender: Any) {
        dismiss(animated: true) {
            self.mainButtonTapped?()
        }
    }

    @IBAction func secondaryButtonAction(_ sender: Any) {
        dismiss(animated: true) {
            self.secondaryButtonTapped?()
        }
    }

    override var preferredContentSize: CGSize {
        get {
            let size = view.systemLayoutSizeFitting(
                UIView.layoutFittingCompressedSize,
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .fittingSizeLevel
            )
            return size
        }

        set {
            super.preferredContentSize = newValue
        }
    }

    private func emitFeedback(state: DeliveryLogic.State) {
        switch state {
        case .idRejected, .expired, .underage:
            failureFeedback.emit()
        case .success:
            successFeedback.emit()
        case .idRequired, .timeout:
            // no feedback
            break
        }
    }

    private func configureIdRequired() {
        titleLabel.text = "Age Verification Required"
        deliveryStatusLabel.text = "This delivery requires an age verification of the recipient."
        deliveryStatusImage.isHidden = true
        mainButton.setAttributedTitle(
            NSAttributedString(string: "SCAN ID DOCUMENT", attributes: titleAttributes),
            for: .normal
        )
        secondaryButton.isHidden = true
        mainStackView.setNeedsLayout()
    }

    private func configureUnderageDelivery() {
        titleLabel.text = "Verification Failed!"
        deliveryStatusLabel.text = "The recipient is underage."
        deliveryStatusImage.image = #imageLiteral(resourceName: "error")
        mainButton.setAttributedTitle(
            NSAttributedString(string: "REFUSE DELIVERY", attributes: titleAttributes),
            for: .normal
        )
        secondaryButton.setTitle("RETRY", for: .normal)
    }

    private func configureExpiredDocument() {
        titleLabel.text = "Verification Failed!"
        deliveryStatusLabel.text = "Document is expired."
        deliveryStatusImage.image = #imageLiteral(resourceName: "error")
        mainButton.setAttributedTitle(
            NSAttributedString(string: "REFUSE DELIVERY", attributes: titleAttributes),
            for: .normal
        )
        secondaryButton.setTitle("RETRY", for: .normal)
    }

    private func configureSuccessfullDelivery() {
        titleLabel.text = "Verification Successful!"
        deliveryStatusLabel.text = "Confirm delivery to proceed."
        deliveryStatusImage.image = #imageLiteral(resourceName: "ok")
        mainButton.setAttributedTitle(
            NSAttributedString(string: "CONFIRM DELIVERY", attributes: titleAttributes),
            for: .normal
        )
        secondaryButton.isHidden = true
        mainStackView.setNeedsLayout()
    }

    private func configureTimeOut() {
        titleLabel.text = "Can’t scan?"
        deliveryStatusImage.image = #imageLiteral(resourceName: "error")

        deliveryStatusLabel.text = "Try scanning the other side of the document or a different document."
        mainButton.setAttributedTitle(
            NSAttributedString(string: "OK", attributes: titleAttributes),
            for: .normal
        )
        secondaryButton.isHidden = true
        mainStackView.setNeedsLayout()
    }

    private func configureIdRejected() {
        titleLabel.text = "Document not supported"
        deliveryStatusLabel.text = "Try scanning the other side of the document or a different document."
        deliveryStatusImage.image = #imageLiteral(resourceName: "error")
        mainButton.setAttributedTitle(
            NSAttributedString(string: "OK", attributes: titleAttributes),
            for: .normal
        )
        secondaryButton.isHidden = true
        mainStackView.setNeedsLayout()
    }
}

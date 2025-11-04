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

class ScanViewController: UIViewController {

    typealias CompletionHandler = () -> Void

    private enum Constants {
        static let shownDurationInContinuousMode: TimeInterval = 0.5
    }

    var context: DataCaptureContext {
        SettingsManager.current.context
    }

    var camera: Camera? {
        SettingsManager.current.camera
    }

    var idCapture: IdCapture {
        SettingsManager.current.idCapture
    }

    private var dismissResultTimer: Timer?

    private lazy var resultLabel: UILabel = makeResultLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on. We want to display camera frames as soon as the view moves to the window. That's why
        // this call is made in `viewWillAppear` call.
        camera?.switch(toDesiredState: .on)
        idCapture.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable ID capture as well.
        idCapture.isEnabled = false
        // Reset IdCapture to discard front side captures when using Front & Back mode
        idCapture.reset()
        camera?.switch(toDesiredState: .off)
    }

    private func setup() {
        // Register self as a listener to get informed whenever a new captured ID got recognized.*-+
        SettingsManager.current.idCaptureListener = self

        // To visualize the on-going ID capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        let captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        SettingsManager.current.captureView = captureView
    }

    private func display(capturedId: CapturedId) {
        if SettingsManager.current.isContinuousModeEnabled {
            dismissResultTimer?.invalidate()
            resultLabel.isHidden = false
            var result = capturedId.fullName ?? ""
            if let date = capturedId.dateOfBirth {
                result += "\n" + date.description
            }
            resultLabel.text = result
            dismissResultTimer = Timer.scheduledTimer(
                withTimeInterval: 2,
                repeats: false,
                block: { _ in
                    self.resultLabel.isHidden = true
                }
            )
            idCapture.isEnabled = true
        } else {
            resultLabel.isHidden = true
            let detail = ResultViewController(capturedId: capturedId)
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }

    private func showAlert(title: String? = nil, message: String? = nil, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: { _ in
                        completion()
                    }
                )
            )

            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ScanViewController: IdCaptureListener {
    func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason rejectionReason: RejectionReason) {
        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false
        showAlert(
            title: "Document rejected",
            message: rejectionReason.description,
            completion: {
                // Resume the idCapture.
                idCapture.isEnabled = true
            }
        )
    }

    func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false
        DispatchQueue.main.async { [unowned self] in
            display(capturedId: capturedId)
        }
    }
}

extension ScanViewController {
    func makeResultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0, alpha: 0.1)
        label.textColor = .white
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
        ])
        return label
    }
}

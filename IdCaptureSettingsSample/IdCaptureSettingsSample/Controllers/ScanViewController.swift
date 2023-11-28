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

class ScanViewController: UIViewController {

    typealias CompletionHandler = () -> Void

    private enum Constants {
        static let shownDurationInContinuousMode: TimeInterval = 0.5
    }

    var context: DataCaptureContext {
        return SettingsManager.current.context
    }

    var camera: Camera? {
        return SettingsManager.current.camera
    }

    var idCapture: IdCapture {
        return SettingsManager.current.idCapture
    }

    private var isScanningBackSide: Bool = false
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
        isScanningBackSide = false
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
            var result = capturedId.fullName
            if let date = capturedId.dateOfBirth {
                result += "\n" + date.description
            }
            resultLabel.text = result
            dismissResultTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                self.resultLabel.isHidden = true
            })
            idCapture.isEnabled = true
        } else {
            resultLabel.isHidden = true
            let detail = ResultViewController(capturedId: capturedId)
            self.navigationController?.pushViewController(detail, animated: true)
        }

        // Reset the state so that when we come back we can scan new IDs.
        isScanningBackSide = false
    }

    private func isSingleSided(documentType: DocumentType) -> Bool {
        documentType == .passport
    }

    private func shouldSuggestBackSideCapture(for capturedId: CapturedId) -> Bool {
        guard let vizResult = capturedId.vizResult else { return false }

        return SettingsManager.current.supportedSides == .frontAndBack &&
            !isSingleSided(documentType: capturedId.documentType) &&
            vizResult.capturedSides == .frontOnly
    }

    private func suggestBackSideCapture(onConfirm: @escaping () -> Void, onReject: @escaping () -> Void) {
        let message = "This document has additional data on the back of the card"
        let alertController = UIAlertController(title: "Back of Card",
                                                message: message,
                                                preferredStyle: .alert)
        [ UIAlertAction(title: "Scan", style: .default, handler: { _ in onConfirm() }),
          UIAlertAction(title: "Skip", style: .cancel, handler: { _ in onReject() }) ]
            .forEach(alertController.addAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension ScanViewController: IdCaptureListener {
    func idCapture(_ idCapture: IdCapture, didCaptureIn session: IdCaptureSession, frameData: FrameData) {
        guard let capturedId = session.newlyCapturedId else { return }

        // Pause the idCapture to not capture while showing the result.
        idCapture.isEnabled = false

        if !isScanningBackSide && shouldSuggestBackSideCapture(for: capturedId) {
            DispatchQueue.main.async { [unowned self] in
                suggestBackSideCapture(onConfirm: { [unowned self] in
                    idCapture.isEnabled = true
                    isScanningBackSide = true
                }, onReject: { [unowned self] in
                    display(capturedId: capturedId)
                    /*
                     * If we want to skip scanning the back of the document, we have to call
                     * `IdCapture().reset()` to allow for another front IDs to be scanned.
                     */
                    self.idCapture.reset()
                })
            }
        } else {
            DispatchQueue.main.async { [unowned self] in
                display(capturedId: capturedId)
            }
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
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
        return label
    }
}

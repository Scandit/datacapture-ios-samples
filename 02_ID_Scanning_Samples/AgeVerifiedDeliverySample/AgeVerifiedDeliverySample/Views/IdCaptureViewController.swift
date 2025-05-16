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

class IdCaptureViewController: UIViewController {

    private lazy var context = DataCaptureContext.licensed
    private lazy var camera = Camera.default
    private lazy var captureView = DataCaptureView(context: context, frame: view.bounds)

    private lazy var idCaptureSettings = {
        let settings = IdCaptureSettings()

        // We are interested in Id Cards, Driver's Licenses and Passports from any region
        settings.acceptedDocuments = [
            IdCard(region: .any),
            DriverLicense(region: .any),
            Passport(region: .any),
        ]

        // Single sided scanner with all zones
        settings.scannerType = SingleSideScanner(
            enablingBarcode: true,
            machineReadableZone: true,
            visualInspectionZone: true
        )
        settings.rejectExpiredIds = true
        settings.rejectHolderBelowAge = 21

        return settings
    }()

    private lazy var idCapture = {
        let idCapture = IdCapture(
            context: context,
            settings: idCaptureSettings
        )
        // Set an empty Feedback because we want to override the default feedback implemented by
        // the SDK to reject documents without a date of birth.
        let idCaptureFeedback = IdCaptureFeedback()
        idCaptureFeedback.idCaptured = Feedback(vibration: nil, sound: nil)
        idCaptureFeedback.idRejected = Feedback(vibration: nil, sound: nil)
        idCapture.feedback = idCaptureFeedback
        idCapture.addListener(self)
        return idCapture
    }()

    private lazy var idCaptureOverlay = IdCaptureOverlay(
        idCapture: idCapture,
        view: captureView
    )

    @IBOutlet private weak var dimmingOverlay: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        context.setFrameSource(camera, completionHandler: nil)
        layoutIdCapture()
        enableCamera(enabled: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        captureView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        captureView.isHidden = false
    }

    private func layoutIdCapture() {
        idCaptureOverlay = IdCaptureOverlay(
            idCapture: idCapture,
            view: captureView
        )
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        NSLayoutConstraint.activate([
            captureView.topAnchor.constraint(equalTo: view.topAnchor),
            captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func reset() {
        enableCamera(enabled: true)
        idCapture.isEnabled = true
        idCapture.reset()
    }

    private func enableCamera(enabled: Bool) {
        camera?.switch(toDesiredState: enabled ? .on : .off)
        dimmingOverlay.isHidden = enabled
    }

    private func stopScanning() {
        enableCamera(enabled: false)
        idCapture.isEnabled = false
    }

    private func showResultViewController(capturedId: CapturedId) {
        let state = DeliveryLogic.stateFor(capturedId)
        switch state {
        case .idRejected:
            showRejectedResultViewController(state: .idRejected)
        default:
            showResultViewController(state: state) {
                self.navigationController?.popViewController(animated: true)
            } secondaryTapped: {
                self.reset()
            }
        }
    }

    private func showNonCompliantResultViewController(state: DeliveryLogic.State) {
        showResultViewController(state: state) {
            self.navigationController?.popViewController(animated: true)
        } secondaryTapped: {
            self.reset()
        }
    }

    private func showRejectedResultViewController(state: DeliveryLogic.State) {
        assert(Thread.isMainThread)
        showResultViewController(state: state) {
            self.reset()
        }
    }

    private func showResultViewController(
        state: DeliveryLogic.State,
        mainTapped: (() -> Void)?,
        secondaryTapped: (() -> Void)? = nil
    ) {
        stopScanning()
        let deliveryResultViewController = DeliveryResultViewController.instantiateFrom(storyboard: storyboard)
        deliveryResultViewController.configureWith(state)
        deliveryResultViewController.mainButtonTapped = mainTapped
        deliveryResultViewController.secondaryButtonTapped = secondaryTapped
        present(deliveryResultViewController, animated: true, completion: nil)
    }
}

extension IdCaptureViewController: IdCaptureListener {
    func idCapture(
        _ idCapture: IdCapture,
        didCapture capturedId: CapturedId
    ) {
        DispatchQueue.main.async {
            self.showResultViewController(capturedId: capturedId)
        }
    }

    func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason rejectionReason: RejectionReason) {
        DispatchQueue.main.async {
            switch rejectionReason {
            case .documentExpired:
                self.showNonCompliantResultViewController(state: .expired)
            case .holderUnderage:
                self.showNonCompliantResultViewController(state: .underage)
            case .timeout:
                self.showRejectedResultViewController(state: .timeout)
            default:
                self.showRejectedResultViewController(state: .idRejected)
            }
        }
    }
}

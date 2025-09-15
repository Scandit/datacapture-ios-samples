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

import ScanditCaptureCore
import ScanditIdCapture
import UIKit

class IdCaptureViewController: UIViewController {

    private enum Mode: String, CaseIterable {
        case barcode = "Barcode"
        case mrz = "MRZ"
        case viz = "VIZ"
    }

    private enum Constants {
        static let modeCollectionHeight: CGFloat = 80

        enum Message {
            static let timeout =
                "Document capture failed. Make sure the document is well lit and free of glare. "
                + "Alternatively, try scanning another document"
            static let rejected = "Document not supported. Try scanning another document"
        }
    }

    private lazy var context = {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        return DataCaptureContext.shared
    }()
    private var camera: Camera?
    private var idCapture: IdCapture!
    private var captureView: DataCaptureView!
    private var overlay: IdCaptureOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupModeCollection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        idCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable id capture as well.
        idCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    private func setupRecognition() {
        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the IdCapture mode.
        let recommendedCameraSettings = IdCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // To visualize the on-going id capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: .zero)
        view.addSubview(captureView)
        captureView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.modeCollectionHeight),
        ])
        configure(mode: .barcode)
    }

    private func setupModeCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let modeCollection = ModeCollectionViewController(collectionViewLayout: layout)
        modeCollection.items = Mode.allCases.map(\.rawValue)
        addChild(modeCollection)
        view.addSubview(modeCollection.view)
        modeCollection.view.translatesAutoresizingMaskIntoConstraints = false
        modeCollection.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        modeCollection.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        modeCollection.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        modeCollection.view.heightAnchor.constraint(equalToConstant: Constants.modeCollectionHeight).isActive = true
        modeCollection.delegate = self
        modeCollection.selectItem(atIndex: 0)
    }

    private func configure(mode: IdCaptureViewController.Mode) {
        context.removeAllModes()
        idCapture?.removeListener(self)
        if overlay != nil {
            captureView?.removeOverlay(overlay)
        }

        let settings = IdCaptureSettings()

        // We are interested in Id Cards, Driver's Licenses and Passports from any region
        settings.acceptedDocuments = [
            IdCard(region: .any),
            DriverLicense(region: .any),
            Passport(region: .any),
        ]

        // Single sided scanner with selected zone
        settings.scannerType = SingleSideScanner(
            enablingBarcode: mode == .barcode,
            machineReadableZone: mode == .mrz,
            visualInspectionZone: mode == .viz
        )

        // Visual Inspection Zone optionally returns a cropped document
        if mode == .viz {
            settings.resultShouldContainImage(true, for: .croppedDocument)
        }

        idCapture = IdCapture(context: context, settings: settings)
        idCapture.addListener(self)

        overlay = IdCaptureOverlay(idCapture: idCapture, view: captureView)
        overlay.idLayoutStyle = .rounded
    }
}

extension IdCaptureViewController: ModeCollectionViewControllerDelegate {

    func selectedItem(atIndex index: Int) {
        configure(mode: Mode.allCases[index])
    }

}

extension IdCaptureViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        // Pause IdCapture to disable capture whilst showing the result.
        idCapture.isEnabled = false

        // Show the result
        DispatchQueue.main.async {
            self.display(capturedId: capturedId)
        }
    }

    func idCapture(_ idCapture: IdCapture, didReject capturedId: CapturedId?, reason: RejectionReason) {
        // Implement to handle documents recognized in a frame, but rejected.
        // A document or its part is considered rejected when (a) it's valid, but not enabled in the settings,
        // (b) it's a barcode of a correct symbology or a Machine Readable Zone (MRZ),
        // but the data is encoded in an unexpected/incorrect format.

        // Pause idCapture to disable capture whilst showing the result.
        idCapture.isEnabled = false
        let message = reason == .timeout ? Constants.Message.timeout : Constants.Message.rejected
        showAlert(
            message: message,
            completion: {
                // Resume IdCapture.
                idCapture.isEnabled = true
            }
        )
    }

    func display(capturedId: CapturedId) {
        let detail = ResultViewController(capturedId: capturedId)
        self.navigationController?.pushViewController(detail, animated: true)
    }

    func showAlert(title: String? = nil, message: String? = nil, completion: @escaping () -> Void) {
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

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

// swiftlint:disable:next type_body_length
class MainViewController: UIViewController {

    private enum DocumentType: String, CaseIterable {

        case drivingLicense = "Driver's License"
        case passport = "Passport / Visa"

        var documentType: IdDocumentType {
            switch self {
            case .drivingLicense:
                return .aamvaBarcode
            case .passport:
                return .passportMRZ
            }
        }
    }

    private lazy var context = DataCaptureContext.licensed
    private lazy var camera = Camera.default
    private lazy var captureView = DataCaptureView(context: context, frame: view.bounds)

    private var idCaptureSettings = IdCaptureSettings()

    private lazy var idCapture = IdCapture(context: nil,
                                   settings: idCaptureSettings)
    private lazy var idCaptureOverlay = IdCaptureOverlay(idCapture: idCapture,
                                                 view: captureView)

    @IBOutlet private weak var scanningModeToggle: ScanningModeToggle!
    @IBOutlet private weak var manualScanButton: UIButton!
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var dimmingOverlay: UIView!

    private lazy var documentSelectionTooltip: PopOver<UILabel> = {
        let tooltip = PopOver<UILabel>()
        tooltip.content.text = "Choose your document and start scanning."
        tooltip.content.numberOfLines = 0
        tooltip.content.textAlignment = .center
        tooltip.content.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tooltip.anchorEdge = .bottom
        tooltip.margins = .init(top: 12, left: 12, bottom: 12, right: 12)
        return tooltip
    }()

    private var frontSideTooltipWasShown = false
    private var dlScanningMode = ScanningMode.barcode {
        didSet {
            configureUI()
            configureIdCapture()
        }
    }

    private var mode: DocumentType = .drivingLicense {
        didSet {
            configureUI()
            configureIdCapture()
        }
    }

    private var supportedDocument: IdDocumentType {
        switch mode {
        case .drivingLicense:
            switch dlScanningMode {
            case .barcode:
                return .aamvaBarcode
            case .viz:
                return .dlVIZ
            }
        case .passport:
            return .passportMRZ
        }
    }

    private var manualScanTimer: Timer?
    private var frontScanTimer: Timer?
    private var cantRecognizeDocumentTimer: Timer?
    private var verificationDidCompleteToken: NSObjectProtocol?

    private func stopManualScanTimer() {
        manualScanTimer?.invalidate()
        manualScanTimer = nil
    }

    private func stopFrontScanTimer() {
        frontScanTimer?.invalidate()
        frontScanTimer = nil
        frontSideTooltipWasShown = false
    }

    private func stopCantRecognizeDocumentTimer() {
        cantRecognizeDocumentTimer?.invalidate()
        cantRecognizeDocumentTimer = nil
    }

    private func startManualScanTimer() {
        guard manualScanTimer == nil else { return }
        manualScanTimer = Timer(timeInterval: 20, repeats: false, block: { [unowned self] _ in
            self.stopManualScanTimer()
            self.manualScanButton.isHidden = false
        })
        RunLoop.main.add(manualScanTimer!, forMode: .default)
    }

    private func startCantRecognizeDocumentTimer() {
        guard cantRecognizeDocumentTimer == nil else { return }
        cantRecognizeDocumentTimer = Timer(timeInterval: 5, repeats: false, block: { [unowned self] _ in
            self.stopFrontScanTimer()
            self.stopManualScanTimer()
            self.showResultViewController()
        })
        RunLoop.main.add(cantRecognizeDocumentTimer!, forMode: .default)
    }

    private func startFrontScanTimer() {
        guard frontScanTimer == nil else { return }
        guard mode == .drivingLicense, dlScanningMode == .barcode else { return }
        frontScanTimer = Timer(timeInterval: 8, repeats: false, block: { [unowned self] _ in
            self.stopFrontScanTimer()
            self.frontSideTooltipWasShown = true
        })
        RunLoop.main.add(frontScanTimer!, forMode: .default)
    }

    private func configureIdCapture() {
        idCapture.removeListener(self)
        captureView.removeOverlay(idCaptureOverlay)
        context.removeAllModes()
        let settings = idCaptureSettings
        settings.supportedDocuments = supportedDocument
        idCapture = IdCapture(context: context, settings: settings)
        idCapture.isEnabled = true
        idCapture.addListener(self)
        idCaptureOverlay = IdCaptureOverlay(idCapture: idCapture,
                                            view: captureView)
        idCaptureOverlay.setIdLayout(.auto)
    }

    private func configureUI() {
        switch mode {
        case .passport:
            stopFrontScanTimer()
            instructionLabel.text = "Align Character Strip"
        case .drivingLicense:
            switch dlScanningMode {
            case .barcode:
                instructionLabel.text = "Align Back of License"
            case .viz:
                instructionLabel.text = "Align Front of License"
            }
        }
        scanningModeToggle.isHidden = mode == .passport
    }

    private func setupCaptureView() {
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        captureView.translatesAutoresizingMaskIntoConstraints = false
        captureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        captureView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func setupDocumentSelectionTooltip() {
        view.addSubview(documentSelectionTooltip)
        documentSelectionTooltip.translatesAutoresizingMaskIntoConstraints = false
        documentSelectionTooltip.leadingAnchor.constraint(equalTo: modeCollection.view.leadingAnchor,
                                                          constant: 16).isActive = true
        documentSelectionTooltip.bottomAnchor.constraint(equalTo: modeCollection.view.topAnchor).isActive = true
        documentSelectionTooltip.widthAnchor.constraint(equalToConstant: 126).isActive = true
        documentSelectionTooltip.heightAnchor.constraint(equalToConstant: 96).isActive = true
    }

    lazy var modeCollection: ModeCollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let modeCollection = ModeCollectionViewController(collectionViewLayout: layout)
        modeCollection.items = DocumentType.allCases.map(\.rawValue)
        return modeCollection
    }()

    private func setupModeCollection() {
        addChild(modeCollection)
        view.addSubview(modeCollection.view)
        modeCollection.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeCollection.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modeCollection.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modeCollection.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        modeCollection.delegate = self
        modeCollection.selectItem(atIndex: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCaptureView()
        setupModeCollection()
        setupDocumentSelectionTooltip()

        scanningModeToggle.delegate = self
        context.setFrameSource(camera, completionHandler: nil)

        configureUI()
        reset()
        startFrontScanTimer()
    }

    private func reset() {
        camera?.switch(toDesiredState: .on)
        manualScanButton.isHidden = true
        dimmingOverlay.isHidden = true
        startScanning()
    }

    private func startScanning() {
        // Reset the timers
        stopFrontScanTimer()
        stopManualScanTimer()
        stopCantRecognizeDocumentTimer()
        // Start scanning
        configureIdCapture()
    }

    private func stopScanning() {
        dimmingOverlay.isHidden = false
        idCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
        captureView.removeOverlay(idCaptureOverlay)
    }

    @IBAction private func manualScanAction(_ sender: Any) {
        stopCantRecognizeDocumentTimer()
        showManualInput()
    }

    private func showManualInput() {
        let identifier = "ManualDocumentInputTableTableViewController"
        guard
            let manualDocumentInputVC = storyboard?
                .instantiateViewController(identifier: identifier)
                as? ManualDocumentInputTableViewController else { return }
        stopScanning()
        manualDocumentInputVC.mainButtonTapped = {
            self.reset()
        }
        manualDocumentInputVC.secondaryButtonTapped = {
            self.reset()
        }
        let transitionManager = TransitionManager()
        let navigationController = CompactNavigationController(rootViewController: manualDocumentInputVC)
        navigationController.transitioningDelegate = transitionManager
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.transitionManager = transitionManager
        present(navigationController, animated: true, completion: nil)
    }

    private func showResultViewController(capturedId: CapturedId? = nil) {
        guard
            let deliveryResultViewController = storyboard?
                .instantiateViewController(identifier: "DeliveryResultViewController")
                as? DeliveryResultViewController else { return }
        stopScanning()
        let transitionManager = TransitionManager()
        deliveryResultViewController.transitioningDelegate = transitionManager
        deliveryResultViewController.modalPresentationStyle = .custom
        deliveryResultViewController.transitionManager = transitionManager
        if let capturedId = capturedId {
            deliveryResultViewController.configure(capturedId: capturedId)
            deliveryResultViewController.mainButtonTapped = {
                self.reset()
            }
            deliveryResultViewController.secondaryButtonTapped = {
                self.reset()
            }
        } else {
            switch mode {
            case .drivingLicense:
                switch dlScanningMode {
                case .barcode:
                    deliveryResultViewController.configureUnparsableBarcode()
                    deliveryResultViewController.mainButtonTapped = {
                        self.reset()
                        self.dlScanningMode = .viz
                        self.scanningModeToggle.setVizScanning()
                    }
                case .viz:
                    deliveryResultViewController.configureUnparsableOCR()
                    deliveryResultViewController.mainButtonTapped = {
                        self.showManualInput()
                    }
                }
                deliveryResultViewController.secondaryButtonTapped = {
                    self.reset()
                }
            case .passport:
                deliveryResultViewController.configureUnparsableOCR()
                deliveryResultViewController.mainButtonTapped = {
                    self.showManualInput()
                }
                deliveryResultViewController.secondaryButtonTapped = {
                    self.reset()
                }
            }
        }
        present(deliveryResultViewController, animated: true, completion: nil)
    }

}

extension MainViewController: ModeCollectionViewControllerDelegate {

    func selectedItem(atIndex index: Int) {
        mode = DocumentType.allCases[index]
        stopCantRecognizeDocumentTimer()
        stopManualScanTimer()
        startManualScanTimer()

        if mode == .drivingLicense, dlScanningMode == .barcode {
            stopFrontScanTimer()
            startFrontScanTimer()
        }

        documentSelectionTooltip.isHidden = true
    }

}

extension MainViewController: DocumentTypeToggleListener {

    func toggleDidChange(newState: ScanningMode) {
        dlScanningMode = newState
        stopFrontScanTimer()
        stopCantRecognizeDocumentTimer()
        switch dlScanningMode {
        case .barcode:
            startFrontScanTimer()
        case .viz:
            startManualScanTimer()
        }
    }

}

extension MainViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture,
                   didLocalizeIn session: IdCaptureSession,
                   frameData: FrameData) {
        DispatchQueue.main.async {
            self.startCantRecognizeDocumentTimer()
        }
    }

    func idCapture(_ idCapture: IdCapture,
                   didCaptureIn session: IdCaptureSession,
                   frameData: FrameData) {
        guard let capturedId = session.newlyCapturedId else { return }
        idCapture.isEnabled = false
        DispatchQueue.main.async {
            self.stopFrontScanTimer()
            self.stopManualScanTimer()
            self.showResultViewController(capturedId: capturedId)
        }
    }

    func idCapture(_ idCapture: IdCapture,
                   didRejectIn session: IdCaptureSession,
                   frameData: FrameData) {
        DispatchQueue.main.async {
            self.stopFrontScanTimer()
            self.stopManualScanTimer()
            self.showResultViewController()
        }
    }

}
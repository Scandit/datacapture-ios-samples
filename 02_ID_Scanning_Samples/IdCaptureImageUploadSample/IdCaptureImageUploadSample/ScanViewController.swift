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

/// Main screen: pick a front (and optional back) image or PDF, then scan it from a still image by
/// feeding it through an `ImageFrameSource` instead of the camera.
///
/// Flow:
///  1. Configure the scanner for the document: `SingleSideScanner` for one image, `FullDocumentScanner`
///     for two. Configuring resets the `IdCapture` session.
///  2. Feed the front image as a single frame.
///  3. For a two-sided document, `notifyOnSideCapture` makes `IdCapture` report the front side on its
///     own; we then feed the back image and `IdCapture` reports the complete document.
///  4. Show the captured id, a rejection, or an error.
final class ScanViewController: UIViewController {

    private enum Side { case front, back }

    private var frontImage: UIImage?
    private var backImage: UIImage?
    private var pickingSide: Side = .front
    private let documentPicker = DocumentPicker()

    // Scanning state.
    private var idCapture: IdCapture?
    private var isScanning = false
    private var timeoutWorkItem: DispatchWorkItem?
    /// A context error (e.g. invalid license) seen before the view was ready to present it.
    private var pendingContextError: String?
    /// Give the engine time to process a fed frame before giving up.
    private static let resultTimeout: TimeInterval = 10

    private let frontTile = DocumentTile(placeholder: "Front side")
    private let backTile = DocumentTile(placeholder: "Back side (optional)")
    private let scanButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let scanningLabel = UILabel()
    private var scanningStack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ID Image Upload sample"
        view.backgroundColor = .systemBackground
        setupViews()
        setupIdCapture()
        updateControls()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Clear any previous selection when returning to this screen.
        if isMovingToParent == false {
            resetSelection()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Surface any context error that arrived before the view could present it.
        showContextError()
    }

    private func setupViews() {
        frontTile.accessibilityIdentifier = "tile.front"
        backTile.accessibilityIdentifier = "tile.back"
        frontTile.addTarget(self, action: #selector(didTapFront), for: .touchUpInside)
        backTile.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        scanButton.setTitle("Scan", for: .normal)
        scanButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        scanButton.layer.cornerRadius = 12
        scanButton.accessibilityIdentifier = "button.scan"
        scanButton.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [frontTile, backTile, UIView(), scanButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        scanningLabel.text = "Scanning…"
        scanningLabel.font = .preferredFont(forTextStyle: .headline)
        scanningLabel.textColor = .secondaryLabel
        let scanningStack = UIStackView(arrangedSubviews: [activityIndicator, scanningLabel])
        scanningStack.axis = .vertical
        scanningStack.spacing = 12
        scanningStack.alignment = .center
        scanningStack.translatesAutoresizingMaskIntoConstraints = false
        scanningStack.isHidden = true
        view.addSubview(scanningStack)
        self.scanningStack = scanningStack

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: margins.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -16),
            frontTile.heightAnchor.constraint(equalToConstant: 180),
            backTile.heightAnchor.constraint(equalToConstant: 180),
            scanButton.heightAnchor.constraint(equalToConstant: 52),
            scanningStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func updateControls() {
        frontTile.configure(image: frontImage)
        backTile.configure(image: backImage)
        frontTile.isEnabled = !isScanning
        backTile.isEnabled = !isScanning && frontImage != nil
        scanButton.isEnabled = !isScanning && frontImage != nil
        scanButton.alpha = scanButton.isEnabled ? 1 : 0.5
        scanningStack?.isHidden = !isScanning
        if isScanning { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }

    private func resetSelection() {
        frontImage = nil
        backImage = nil
        updateControls()
    }

    // MARK: - Actions

    @objc private func didTapFront() {
        pickingSide = .front
        documentPicker.present(from: self, source: frontTile) { [weak self] in self?.apply($0) }
    }

    @objc private func didTapBack() {
        pickingSide = .back
        documentPicker.present(from: self, source: backTile) { [weak self] in self?.apply($0) }
    }

    @objc private func didTapScan() {
        guard let front = frontImage, !isScanning else { return }
        isScanning = true
        configureScanner(doubleSided: backImage != nil)
        idCapture?.isEnabled = true
        updateControls()
        feed(image: front)
    }

    // MARK: - Picking

    /// Assigns the picked image(s) to the side currently being picked, or reports a read failure.
    private func apply(_ picked: DocumentPicker.Picked) {
        switch picked {
        case .images(let images):
            guard let first = images.first else { return }
            switch pickingSide {
            case .front:
                frontImage = first
                // A multi-page PDF carries the back side as its second page.
                backImage = images.count >= 2 ? images[1] : nil
            case .back:
                backImage = first
            }
            updateControls()
        case .unreadable:
            showAlert(message: "Could not read the selected file.")
        case .emptyPDF:
            showAlert(message: "The selected PDF has no pages.")
        }
    }

    // MARK: - Scanning

    private func setupIdCapture() {
        Self.initializeDataCaptureContext()
        // This sample has no `DataCaptureView`, so we listen for context status changes to report
        // license/context errors to the user ourselves.
        DataCaptureContext.shared.addListener(self)
        let capture = IdCapture(context: DataCaptureContext.shared, settings: makeSettings(doubleSided: false))
        capture.isEnabled = false
        capture.addListener(self)
        idCapture = capture
    }

    private static func initializeDataCaptureContext() {
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
    }

    private func makeSettings(doubleSided: Bool) -> IdCaptureSettings {
        let settings = IdCaptureSettings()
        settings.acceptedDocuments = [
            IdCard(region: .any),
            DriverLicense(region: .any),
            Passport(region: .any),
        ]
        settings.scanner =
            doubleSided
            ? IdCaptureScanner(physicalDocument: FullDocumentScanner())
            : IdCaptureScanner(
                physicalDocument: SingleSideScanner(
                    enablingBarcode: true,
                    machineReadableZone: true,
                    visualInspectionZone: true
                )
            )
        // Only relevant to the two-sided flow: it makes IdCapture report the front side on its own
        // `didCapture` (with `isCapturingComplete == false`) so we know when to feed the back image.
        // A single-side scan completes in one callback, so the flag has no effect there.
        settings.notifyOnSideCapture = doubleSided
        return settings
    }

    private func configureScanner(doubleSided: Bool) {
        // Resets the IdCapture session and switches between the single- and full-document scanners.
        idCapture?.apply(makeSettings(doubleSided: doubleSided))
    }

    private func feed(image: UIImage) {
        let source = ImageFrameSource(image: image)
        // Re-emit the frame until it is processed.
        source.repeats = true
        DataCaptureContext.shared.setFrameSource(source) {
            source.switch(toDesiredState: .on)
        }
        startTimeout()
    }

    private func startTimeout() {
        cancelTimeout()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.isScanning else { return }
            self.finishScanning()
            self.showAlert(message: "No document was detected in the selected file. Please try another image.")
        }
        timeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.resultTimeout, execute: work)
    }

    private func cancelTimeout() {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
    }

    private func finishScanning() {
        isScanning = false
        cancelTimeout()
        idCapture?.isEnabled = false
        DataCaptureContext.shared.setFrameSource(nil, completionHandler: nil)
        updateControls()
    }

    // MARK: - Alerts

    /// Buffers a context error (e.g. invalid/missing license) and presents it once the view can.
    private func reportContextError(_ message: String) {
        pendingContextError = message
        showContextError()
    }

    private func showContextError() {
        guard let message = pendingContextError, viewIfLoaded?.window != nil, presentedViewController == nil
        else { return }
        pendingContextError = nil
        showAlert(title: "License error", message: message)
    }

    private func showAlert(title: String? = nil, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ScanViewController: IdCaptureListener {

    func idCapture(_ idCapture: IdCapture, didCapture capturedId: CapturedId) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if capturedId.isCapturingComplete {
                self.finishScanning()
                self.navigationController?.pushViewController(
                    ResultViewController(capturedId: capturedId),
                    animated: true
                )
            } else if let back = self.backImage {
                // Only the front of a two-sided document so far; feed the back to complete it.
                self.cancelTimeout()
                self.feed(image: back)
            }
        }
    }

    func idCapture(
        _ idCapture: IdCapture,
        didReject capturedId: CapturedId?,
        reason: RejectionReason
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.finishScanning()
            self.showAlert(message: self.rejectionMessage(for: reason))
        }
    }

    private func rejectionMessage(for reason: RejectionReason) -> String {
        switch reason {
        case .timeout:
            return "The document could not be captured. Please try a clearer image."
        case .singleImageNotRecognized:
            return "No document was detected in the selected image. Please try another image."
        case .notAcceptedDocumentType:
            return "This document type is not supported. Please try another document."
        default:
            return "The document was rejected. Please try another image."
        }
    }
}

extension ScanViewController: DataCaptureContextListener {

    func context(_ context: DataCaptureContext, didChange contextStatus: ContextStatus) {
        // The context has no view to show its status, so surface an invalid status (e.g. a bad or
        // missing license key) to the user.
        guard !contextStatus.isValid else { return }
        let message = contextStatus.message
        DispatchQueue.main.async { [weak self] in self?.reportContextError(message) }
    }

    func context(_ context: DataCaptureContext, didChange frameSource: FrameSource?) {}
    func context(_ context: DataCaptureContext, didAdd mode: DataCaptureMode) {}
    func context(_ context: DataCaptureContext, didRemove mode: DataCaptureMode) {}
}


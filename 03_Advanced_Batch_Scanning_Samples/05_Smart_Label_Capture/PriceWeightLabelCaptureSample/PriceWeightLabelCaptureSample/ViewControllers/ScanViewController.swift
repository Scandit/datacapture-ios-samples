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

import ScanditBarcodeCapture
import ScanditLabelCapture
import UIKit

class ScanViewController: UIViewController {
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var labelCapture: LabelCapture!
    private var captureView: DataCaptureView!
    private var overlay: LabelCaptureBasicOverlay!
    private var scannedItems: [Item] = [] {
        didSet {
            scanResultsViewController?.scannedItems = scannedItems
        }
    }

    private var scanResultsSheetViewController: SheetContainerViewController?
    private var scanResultsViewController: ScanResultsViewController?
    private var editMissingInfoSheetViewController: SheetContainerViewController?
    private var editMissingInfoViewController: EditMissingInfoViewController?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var labelNotFullyScannedView: UIView!
    @IBOutlet weak var guidanceView: UIView!
    @IBOutlet weak var guidanceLabel: UILabel!
    @IBOutlet var dimmingViewTapGestureRecognizer: UITapGestureRecognizer!

    private enum Guidance {
        case pointAtLabelToScan
        case tapAnywhereToResume
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    private func setupUI() {
        guidanceView.layer.cornerRadius = 4
        dimmingView.isHidden = true
        labelNotFullyScannedView.layer.cornerRadius = 4
        labelNotFullyScannedView.alpha = 0.0
    }

    private func startScanning() {
        camera?.switch(toDesiredState: .on)
        labelCapture.isEnabled = true
        dimmingView.isHidden = true
        showGuidance(.pointAtLabelToScan)
    }

    private func pauseScanning() {
        camera?.switch(toDesiredState: .off)
        labelCapture.isEnabled = false
        dimmingView.isHidden = false
        showGuidance(.tapAnywhereToResume)
    }

    private func stopScanning() {
        camera?.switch(toDesiredState: .off)
        labelCapture.isEnabled = false
        dimmingView.isHidden = false
        hideGuidance()
    }

    private func showGuidance(_ guidance: Guidance) {
        switch guidance {
        case .pointAtLabelToScan:
            guidanceView.isHidden = false
            guidanceLabel.text = "Point at a label to scan"
        case .tapAnywhereToResume:
            guidanceView.isHidden = false
            guidanceLabel.text = "Tap anywhere to resume"
        }
    }

    private func hideGuidance() {
        guidanceView.isHidden = true
        guidanceLabel.text = ""
    }

    private func showScanResults() {
        guard scanResultsViewController == nil, let storyboard,
            let viewController = storyboard.instantiateViewController(withIdentifier: "ScanResults")
                as? ScanResultsViewController
        else { return }
        scanResultsViewController = viewController
        viewController.delegate = self
        viewController.scannedItems = scannedItems
        let scanResultsSheet = SheetContainerViewController(content: viewController)
        scanResultsSheetViewController = scanResultsSheet
        scanResultsSheet.delegate = self
        scanResultsSheet.present(in: self, presentingView: containerView)
    }

    private func hideScanResults() {
        guard let scanResultsSheetViewController else { return }
        scanResultsSheetViewController.dismiss()
    }

    private func showEditMissingInfo(for item: Item) {
        guard editMissingInfoViewController == nil, let storyboard,
            let viewController = storyboard.instantiateViewController(withIdentifier: "EditMissingInfo")
                as? EditMissingInfoViewController
        else { return }
        editMissingInfoViewController = viewController
        viewController.delegate = self
        viewController.item = item
        let editMissingInfoSheet = SheetContainerViewController(content: viewController)
        editMissingInfoSheetViewController = editMissingInfoSheet
        editMissingInfoSheet.isExpandedStateAllowed = false
        editMissingInfoSheet.delegate = self
        editMissingInfoSheet.present(in: self, presentingView: containerView)

        UIView.animate(withDuration: 0.3) {
            self.labelNotFullyScannedView.alpha = 1.0
        }
    }

    private func hideEditMissingInfo() {
        guard let editMissingInfoSheetViewController else { return }
        editMissingInfoSheetViewController.dismiss()
    }

    @IBAction func onDimmingViewTapped(_ sender: Any) {
        hideScanResults()
        hideEditMissingInfo()
        startScanning()
    }
}

// MARK: LabelCapture configuration
extension ScanViewController {
    private enum Label: String {
        case regularItem = "regular_item"
        case weightedItem = "weighted_item"
    }

    fileprivate enum Field: String {
        case barcode = "barcode"
        case weight = "weight"
        case unitPrice = "unit_price"
    }

    // Regular item (barcode value not starting with 02, UPC only)
    private var regularItemLabelDefinition: LabelDefinition {
        let barcodeField = CustomBarcode(
            name: Field.barcode.rawValue,
            symbologies: [NSNumber(value: Symbology.ean13UPCA.rawValue)]
        )
        barcodeField.patterns = ["^(?!0?2)\\d+"]
        return LabelDefinition(name: Label.regularItem.rawValue, fields: [barcodeField])
    }

    // Weighted item (barcode value starting with 02, UPC/GS1 DataBar Expanded/Code128 + weight)
    private var weightedItemBarcodeDefinition: LabelDefinition {
        let barcodeField = CustomBarcode(
            name: Field.barcode.rawValue,
            symbologies: [
                NSNumber(value: Symbology.ean13UPCA.rawValue),
                NSNumber(value: Symbology.gs1DatabarExpanded.rawValue),
                NSNumber(value: Symbology.code128.rawValue),
            ]
        )
        barcodeField.patterns = ["^0?2\\d+"]

        let weightField = WeightText(name: Field.weight.rawValue)
        weightField.optional = true

        let unitPrice = UnitPriceText(name: Field.unitPrice.rawValue)
        unitPrice.optional = true

        return LabelDefinition(name: Label.weightedItem.rawValue, fields: [barcodeField, weightField, unitPrice])
    }

    private func setupRecognition() {
        let definitions = [regularItemLabelDefinition, weightedItemBarcodeDefinition]
        guard let labelCaptureSettings = try? LabelCaptureSettings(labelDefinitions: definitions) else {
            return
        }

        // Create context and set the default camera as frame source
        // See DataCaptureContext+Extensions.swift for DataCaptureContext.licensed
        context = DataCaptureContext.licensed
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the LabelCapture mode.
        let recommendedCameraSettings = LabelCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // Create LabelCapture mode and add listener
        labelCapture = LabelCapture(context: context, settings: labelCaptureSettings)
        labelCapture.addListener(self)

        // Create capture view to visualize the frame source and set it up
        captureView = DataCaptureView(context: context, frame: containerView.bounds)
        captureView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        captureView.addControl(TorchSwitchControl())
        containerView.insertSubview(captureView, at: 0)

        // Create overlay to visualize results and set the delegate
        overlay = LabelCaptureBasicOverlay(labelCapture: labelCapture)
        overlay.viewfinder = RectangularViewfinder(style: .square)
        overlay.delegate = self
        captureView.addOverlay(overlay)
    }

    private func indexOfScannedItem(with data: String) -> Int? {
        scannedItems.firstIndex(where: { $0.data == data })
    }

    private func addScannedItem(_ item: Item) {
        if let index = indexOfScannedItem(with: item.data) {
            // Increase quantity
            let item = scannedItems[index]
            item.quantity += 1

            // Move the item to the top of the list
            var items = scannedItems
            items.remove(at: index)
            items.insert(item, at: 0)
            scannedItems = items
            return
        }
        scannedItems.insert(item, at: 0)
    }
}

// MARK: LabelCaptureListener

extension ScanViewController: LabelCaptureListener {
    func labelCapture(_ labelCapture: LabelCapture, didUpdate session: LabelCaptureSession, frameData: FrameData) {
        guard let label = session.capturedLabels.first,
            let type = Label(rawValue: label.name),
            let barcodeField = label.field(for: .barcode),
            let barcodeData = barcodeField.barcode?.data
        else { return }
        labelCapture.isEnabled = false
        Feedback.default.emit()

        let isComplete: Bool
        let item: Item
        switch type {
        case .regularItem:
            item = Item.createRegular(data: barcodeData)
            isComplete = true
        case .weightedItem:
            let weight = label.field(for: .weight)?.text
            let unitPrice = label.field(for: .unitPrice)?.text
            isComplete = weight != nil && unitPrice != nil
            item = Item.createWeighted(data: barcodeData, weight: weight, unitPrice: unitPrice)
        }

        DispatchQueue.main.async {
            self.pauseScanning()
            if isComplete || self.indexOfScannedItem(with: item.data) != nil {
                self.addScannedItem(item)
                self.showScanResults()
            } else {
                self.showEditMissingInfo(for: item)
            }
        }
    }
}

// MARK: LabelCaptureBasicOverlayDelegate

extension ScanViewController: LabelCaptureBasicOverlayDelegate {
    func labelCaptureBasicOverlay(
        _ overlay: LabelCaptureBasicOverlay,
        brushFor field: LabelField,
        of label: CapturedLabel
    ) -> Brush? {
        brush(for: field)
    }

    func labelCaptureBasicOverlay(
        _ overlay: LabelCaptureBasicOverlay,
        brushFor label: CapturedLabel
    ) -> Brush? {
        nil
    }

    func labelCaptureBasicOverlay(
        _ overlay: LabelCaptureBasicOverlay,
        didTap label: CapturedLabel
    ) {
        // Do nothing
    }

    private func brush(for field: LabelField) -> Brush {
        let fillColor: UIColor
        let strokeColor: UIColor
        switch Field(rawValue: field.name) {
        case .barcode:
            fillColor = .teal100.withAlphaComponent(0.5)
            strokeColor = .teal100
        case .weight:
            fillColor = .orange100.withAlphaComponent(0.5)
            strokeColor = .orange100
        case .unitPrice:
            fillColor = .blue100.withAlphaComponent(0.5)
            strokeColor = .blue100
        case .none:
            fillColor = .clear
            strokeColor = .clear
        }
        return Brush(fill: fillColor, stroke: strokeColor, strokeWidth: 1)
    }
}

// MARK: ScanResultsViewControllerDelegate

extension ScanViewController: ScanResultsViewControllerDelegate {
    func scanResultsViewControllerDidPressContinueScanning(_ viewController: ScanResultsViewController) {
        hideScanResults()
        startScanning()
    }

    func scanResultsViewControllerDidPressClearList(_ viewController: ScanResultsViewController) {
        scannedItems = []
    }
}

// MARK: EditMissingInfoViewControllerDelegate

extension ScanViewController: EditMissingInfoViewControllerDelegate {
    func editMissingInfoViewController(_ viewController: EditMissingInfoViewController, didUpdate item: Item) {
        addScannedItem(item)
        hideEditMissingInfo()
        showScanResults()
    }

    func editMissingInfoViewControllerDidCancel(_ viewController: EditMissingInfoViewController) {
        hideEditMissingInfo()
        startScanning()
    }
}

// MARK: SheetContainerViewControllerDelegate

extension ScanViewController: SheetContainerViewControllerDelegate {
    func sheetContainer(
        _ viewController: SheetContainerViewController,
        willTransitionTo state: SheetContainerViewController.State,
        animated: Bool
    ) {
        guard state == .collapsed else { return }
        if viewController == editMissingInfoSheetViewController {
            UIView.animate(withDuration: 0.3) {
                self.labelNotFullyScannedView.alpha = 0.0
            }
        }
    }

    func sheetContainer(
        _ viewController: SheetContainerViewController,
        didTransitionTo state: SheetContainerViewController.State,
        animated: Bool
    ) {
        guard state == .collapsed else { return }
        if viewController == scanResultsSheetViewController {
            scanResultsViewController = nil
            scanResultsSheetViewController = nil
            startScanning()
        } else if viewController == editMissingInfoSheetViewController {
            editMissingInfoViewController = nil
            editMissingInfoSheetViewController = nil
            if scanResultsSheetViewController == nil {
                startScanning()
            }
        }
    }
}

// MARK: CapturedLabel helper methods

private extension CapturedLabel {
    func field(for type: ScanViewController.Field) -> LabelField? {
        fields.first(where: { $0.name == type.rawValue })
    }
}

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
import ScanditParser

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: ItemsTableView!
    @IBOutlet private weak var clearListButton: UIButton!

    private var itemsTableViewModel: ItemsTableViewModel!
    private let context = DataCaptureContext.licensed
    private var parser: BarcodeParser?

    private lazy var sparkScan: SparkScan = {
        let settings = SparkScanSettings()
        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable just Code128 and DataMatrix. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        Set<Symbology>([.code128, .dataMatrix]).forEach {
            settings.set(symbology: $0, enabled: true)
        }

        let mode = SparkScan(settings: settings)
        return mode
    }()

    private var sparkScanView: SparkScanView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure to call the corresponding SparkScan method
        sparkScanView.prepareScanning()
        tableView.viewModel = itemsTableViewModel
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Make sure to call the corresponding SparkScan method
        sparkScanView.stopScanning()
    }

    @IBAction private func didPressClearListButton(_ sender: UIButton) {
        tableView.viewModel?.clear()
    }
}

// MARK: - Update View Methods

extension ViewController {

    private func setupRecognition() {
        sparkScan.addListener(self)
        parser = try? BarcodeParser(context: context)
    }

    private func setupUI() {
        self.title = "Expiry Management"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .white
        // Create the SparkScanView passing the context and the mode.
        sparkScanView = SparkScanView(
            parentView: view,
            context: context,
            sparkScan: sparkScan,
            settings: SparkScanViewSettings()
        )
        // Show the button used to switch to BarcodeCount
        sparkScanView.isBarcodeCountButtonVisible = true
        sparkScanView.feedbackDelegate = self
        sparkScanView.uiDelegate = self
        itemsTableViewModel = ItemsTableViewModel(parser: parser)
        tableView.allowEditing = true
        clearListButton.styleAsSecondaryButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let barcodeCountVC = segue.destination as? BarcodeCountViewController {
            // Stop SparkScan before moving to BarcodeCount
            sparkScan.isEnabled = false
            barcodeCountVC.context = context
            barcodeCountVC.itemsTableViewModel = itemsTableViewModel
        }
    }
}

// MARK: - SparkScanListener Protocol Implementation

extension ViewController: SparkScanListener {

    func sparkScan(_ sparkScan: SparkScan, didScanIn session: SparkScanSession, frameData: FrameData?) {
        guard let barcode = session.newlyRecognizedBarcode, barcode.data != nil else {
            return
        }

        DispatchQueue.main.async {
            self.tableView.viewModel?.addBarcode(barcode)
        }
    }
}

// MARK: - SparkScanFeedbackDelegate Protocol Implementation

extension ViewController: SparkScanFeedbackDelegate {
    func feedback(for barcode: Barcode) -> SparkScanBarcodeFeedback? {
        guard let data = barcode.data else {
            return nil
        }
        // Use sparkscan feedback feature to notify the user if the item is expired
        guard let parser = self.parser, parser.isItemExpired(barcodeData: data) else {
            return SparkScanBarcodeSuccessFeedback()
        }
        return SparkScanBarcodeErrorFeedback(
            message: "Item is expired",
            resumeCapturingDelay: 60
        )
    }
}

// MARK: - SparkScanViewUIDelegate Protocol Implementation

extension ViewController: SparkScanViewUIDelegate {
    func barcodeCountButtonTapped(in view: SparkScanView) {
        // Switch to BarcodeCount
        performSegue(withIdentifier: "ShowBarcodeCount", sender: nil)
    }
}

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

import ScanditBarcodeCapture

class ViewController: UIViewController {
    @IBOutlet private weak var itemsTableViewHeader: ItemsTableViewHeader!
    @IBOutlet private weak var tableView: UITableView!

    private let context = DataCaptureContext.licensed
    private let imageSize = CGSize(width: 56 * UIScreen.main.scale, height: 56 * UIScreen.main.scale)

    private lazy var sparkScan: SparkScan = {
        let settings = SparkScanSettings()
        Set<Symbology>([.ean8, .ean13UPCA, .upce, .code39, .code128, .interleavedTwoOfFive]).forEach {
            settings.set(symbology: $0, enabled: true)
        }
        settings.settings(for: .code39).activeSymbolCounts = Set((7...20).map { NSNumber(value: $0) })

        let mode = SparkScan(context: context, settings: settings)
        return mode
    }()

    private lazy var overlay: SparkScanOverlay = {
        let overlay = SparkScanOverlay(sparkScan: sparkScan)
        return overlay
    }()

    private var sparkScanView: SparkScanView!
    private var camera = Camera.default

    /// The model where all scanned barcode are saved.
    private var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sparkScanView.pauseScanning()
    }

    @IBAction private func didPressClearListButton(_ sender: UIButton) {
        clearItems()
    }
}

// MARK: - Update Model and View Methods

extension ViewController {
    private func clearItems() {
        tableView.performBatchUpdates {
            // Retrieve all the indexPaths, since we've to clear the whole list.
            let indexPaths = items.indexPaths
            // Update the model.
            items = []
            // Update the view.
            itemsTableViewHeader.itemsCount = items.count
            tableView.deleteRows(
                at: indexPaths,
                with: .automatic)
        }
    }

    private func addItem(_ item: Item) {
        tableView.performBatchUpdates {
            // Retrieve the indexPath for the item to be added.
            let indexPath = items.addItemIndexPath
            // Update the model.
            items.append(item)
            // Update the view.
            itemsTableViewHeader.itemsCount = items.count
            tableView.insertRows(
                at: [indexPath],
                with: .right)
        }
    }

    private func setupRecognition() {
        camera?.apply(SparkScan.recommendedCameraSettings)
        context.setFrameSource(camera)
        sparkScan.addListener(self)
    }

    private func setupUI() {
        sparkScanView = SparkScanView(parentView: view,
                                      context: context,
                                      sparkScan: sparkScan,
                                      settings: SparkScanViewSettings())
        sparkScanView.add(overlay)
    }
}

// MARK: - UITableViewDataSource Protocol Implementation

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ItemTableViewCell.identifier,
            for: indexPath)
        guard let itemTableViewCell = tableViewCell as? ItemTableViewCell else {
            fatalError("Unable to deque reusable cell")
        }

        // Retrieve the item to be used for configuring the cell.
        let item = items[indexPath.row]
        // Configure the dequeued cell to show the item.
        itemTableViewCell.configure(with: item)
        return itemTableViewCell
    }
}

// MARK: - SparkScanListener Protocol Implementation

extension ViewController: SparkScanListener {
    func sparkScan(_ sparkScan: SparkScan, didScanIn session: SparkScanSession, frameData: FrameData) {
        if session.newlyRecognizedBarcodes.isEmpty {
            return
        }
        let barcode = session.newlyRecognizedBarcodes.first!
        let thumbnail = frameData.imageBuffers.last?.image?.resize(for: imageSize)

        DispatchQueue.main.async {
            if barcode.data == "123456789" {
                let feedback = SparkScanViewErrorFeedback(message: "This code should not have been scanned",
                                                          resumeCapturingDelay: 60)
                self.sparkScanView.setFeedback(feedback)
            } else {
                self.sparkScanView.setFeedback(SparkScanViewSuccessFeedback())
                self.addItem(.init(
                    barcode: barcode,
                    number: self.items.count + 1,
                    image: thumbnail))
            }
        }
    }
}

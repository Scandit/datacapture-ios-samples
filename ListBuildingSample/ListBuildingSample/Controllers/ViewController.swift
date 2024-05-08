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
        settings.settings(for: .code39).activeSymbolCounts = Set(7...20)

        let mode = SparkScan(settings: settings)
        return mode
    }()

    private var sparkScanView: SparkScanView!

    /// The model where all scanned barcode are saved.
    private var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "List Building"
        setupRecognition()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sparkScanView.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sparkScanView.viewWillDisappear()
    }
}

// MARK: - Update Model and View Methods

extension ViewController {
    private func clearItems() {
        // Retrieve all the indexPaths, since we've to clear the whole list.
        let indexPaths = items.indexPaths
        // Update the model.
        items = []
        // Update the view.
        itemsTableViewHeader.itemsCount = items.totalCount
        tableView.deleteRows(
            at: indexPaths,
            with: .automatic)
    }

    private func addItem(_ item: Item) {
        // Retrieve the indexPath for the item to be added.
        let indexPath = items.addItemIndexPath
        // Update the model.
        items.insert(item, at: indexPath.row)
        // Update the view.
        itemsTableViewHeader.itemsCount = items.totalCount
        tableView.insertRows(
            at: [indexPath],
            with: .right)
    }

    private func increaseQuantity(for item: Item, with thumbnail: UIImage?) {
        if let row = items.firstIndex(of: item) {
            // Move item to the top
            let oldIndexPath = IndexPath(row: row, section: 0)
            let newIndexPath = IndexPath(row: 0, section: 0)
            var updatedItem = self.items.remove(at: row)
            updatedItem.increaseQuantity(with: thumbnail)
            self.items.insert(updatedItem, at: newIndexPath.row)
            itemsTableViewHeader.itemsCount = items.totalCount
            tableView.performBatchUpdates {
                tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            }
            // We need to explicitly reload the row to update the cell contents
            tableView.reloadRows(at: [newIndexPath], with: .none)
        }
    }

    private func item(for barcode: Barcode) -> Item? {
        items.first {
            $0.symbology == barcode.symbology && $0.data == barcode.data
        }
    }

    private func setupRecognition() {
        sparkScan.addListener(self)
    }

    private func setupUI() {
        itemsTableViewHeader.delegate = self
        sparkScanView = SparkScanView(parentView: view,
                                      context: context,
                                      sparkScan: sparkScan,
                                      settings: SparkScanViewSettings())
        sparkScanView.feedbackDelegate  = self
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
    func sparkScan(_ sparkScan: SparkScan, didScanIn session: SparkScanSession, frameData: FrameData?) {
        if session.newlyRecognizedBarcodes.isEmpty {
            return
        }
        let barcode = session.newlyRecognizedBarcodes.first!
        let thumbnail = frameData?.imageBuffers.last?.image?.resize(for: imageSize)

        DispatchQueue.main.async {
            if !barcode.isRejected {
                if let item = self.item(for: barcode) {
                    // Item was scanned before
                    self.increaseQuantity(for: item, with: thumbnail)
                } else {
                    // Item is new
                    self.addItem(.init(
                        barcode: barcode,
                        number: self.items.count + 1,
                        image: thumbnail))
                }
            }
        }
    }
}

// MARK: - SparkScanFeedbackDelegate Protocol Implementation

extension ViewController: SparkScanFeedbackDelegate {
    func feedback(for barcode: Barcode) -> SparkScanBarcodeFeedback? {
        guard !barcode.isRejected else {
            return SparkScanBarcodeErrorFeedback(message: "Wrong barcode",
                                    resumeCapturingDelay: 60)
        }
        return SparkScanBarcodeSuccessFeedback()
    }
}

// MARK: - ItemsTableViewHeaderDelegate Protocol Implementation

extension ViewController: ItemsTableViewHeaderDelegate {
    func itemsTableViewHeaderDidPressClearListButton(_ view: ItemsTableViewHeader) {
        clearItems()
    }
}

// MARK: - Barcode extension

fileprivate extension Barcode {
    var isRejected: Bool {
        return data == "123456789"
    }
}

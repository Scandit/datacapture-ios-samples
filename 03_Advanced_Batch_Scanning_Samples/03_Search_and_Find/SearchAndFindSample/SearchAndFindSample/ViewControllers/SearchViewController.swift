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
import ScanditCaptureCore
import UIKit

class SearchViewController: UIViewController {
    @IBOutlet private weak var itemsTableViewHeader: ItemsTableViewHeader!
    @IBOutlet private weak var tableView: UITableView!

    private enum Constants {
        static let presentFindViewControllerSegue = "presentFindViewControllerSegue"
    }

    private lazy var context = {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        return DataCaptureContext.sharedInstance
    }()

    private let imageSize = CGSize(width: 56 * UIScreen.main.scale, height: 56 * UIScreen.main.scale)
    private let symbologies: Set<Symbology> = [.ean8, .ean13UPCA, .upce, .code39, .code128, .dataMatrix]

    private lazy var sparkScan: SparkScan = {
        let settings = SparkScanSettings()
        symbologies.forEach {
            settings.set(symbology: $0, enabled: true)
        }

        let mode = SparkScan(settings: settings)
        return mode
    }()
    private var sparkScanView: SparkScanView!

    /// The model where all scanned barcode are saved.
    private var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SEARCH & FIND"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupRecognition()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sparkScanView.prepareScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sparkScanView.stopScanning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FindViewController {
            guard !items.isEmpty else { return }
            // Create the Barcode Find Item with the scanned barcode data.
            // If you have more information about the product (such as name or image) that you want
            // to display, you can pass a BarcodeFindItemContent object to the content parameter below.
            var itemsToFind: [BarcodeFindItem] = []
            for item in items {
                let searchOptions = BarcodeFindItemSearchOptions(barcodeData: item.data)
                let itemToFind = BarcodeFindItem(searchOptions: searchOptions, content: nil)
                itemsToFind.append(itemToFind)
            }

            destination.itemsToFind = itemsToFind
            destination.symbologies = symbologies
        }
    }

    @IBAction func unwindFromSearchViewController(segue: UIStoryboardSegue) {}
}

// MARK: - Setup

extension SearchViewController {
    private func setupRecognition() {
        // Register self as a listener to get informed of captured barcodes.
        sparkScan.addListener(self)
    }

    private func setupUI() {
        sparkScanView = SparkScanView(
            parentView: view,
            context: context,
            sparkScan: sparkScan,
            settings: SparkScanViewSettings()
        )
        sparkScanView.isBarcodeFindButtonVisible = true
        sparkScanView.uiDelegate = self
        itemsTableViewHeader.delegate = self
    }
}

// MARK: - SparkScanListener

extension SearchViewController: SparkScanListener {
    func sparkScan(_ sparkScan: SparkScan, didScanIn session: SparkScanSession, frameData: FrameData?) {
        guard let barcode = session.newlyRecognizedBarcode else { return }
        let thumbnail = frameData?.imageBuffers.last?.image?.resizeAndRotate(for: imageSize)

        DispatchQueue.main.async {
            self.addItem(
                .init(
                    barcode: barcode,
                    number: self.items.count + 1,
                    image: thumbnail
                )
            )
        }
    }
}

// MARK: - SparkScanViewUIDelegate

extension SearchViewController: SparkScanViewUIDelegate {
    func barcodeFindButtonTapped(in view: SparkScanView) {
        guard !items.isEmpty else { return }
        self.performSegue(
            withIdentifier: Constants.presentFindViewControllerSegue,
            sender: self
        )
        clearItems()
    }
}

// MARK: - Model and View update Methods

extension SearchViewController {
    private func clearItems() {
        // Retrieve all the indexPaths, since we've to clear the whole list.
        let indexPaths = items.indexPaths
        // Update the model.
        items = []
        // Update the view.
        itemsTableViewHeader.itemsCount = items.count
        tableView.deleteRows(
            at: indexPaths,
            with: .automatic
        )
    }

    private func addItem(_ item: Item) {
        // Retrieve the indexPath for the item to be added.
        let indexPath = items.addItemIndexPath
        // Update the model.
        items.insert(item, at: indexPath.row)
        // Update the view.
        itemsTableViewHeader.itemsCount = items.count
        tableView.insertRows(
            at: [indexPath],
            with: .right
        )
    }

    private func item(for barcode: Barcode) -> Item? {
        items.first {
            $0.symbology == barcode.symbology && $0.data == barcode.data
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ItemTableViewCell.identifier,
            for: indexPath
        )
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

// MARK: - ItemsTableViewHeaderDelegate

extension SearchViewController: ItemsTableViewHeaderDelegate {
    func itemsTableViewHeaderDidPressClearListButton(_ view: ItemsTableViewHeader) {
        clearItems()
    }
}

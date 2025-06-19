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

class PickViewController: UIViewController {

    // Will contain the list of products to pick and the mapping.
    // Please customize this in buildSessionStore().
    var pickSessionStore: PickSessionStore!

    private lazy var context = {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        return DataCaptureContext.sharedInstance
    }()
    private var barcodePick: BarcodePick!
    private var barcodePickView: BarcodePickView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restocking"
        buildSessionStore()
        setupRecognition()
    }

    @IBAction func unwindFromResultListViewController(segue: UIStoryboardSegue) {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barcodePickView.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        barcodePickView.pause()
    }

    private func buildSessionStore() {
        // The list of products to pick and their quantity
        let productsToPick: Set<BarcodePickProduct> = [
            BarcodePickProduct(identifier: "A", quantityToPick: 1),
            BarcodePickProduct(identifier: "B", quantityToPick: 1),
            BarcodePickProduct(identifier: "C", quantityToPick: 1),
        ]

        // A dictionary used to map items data (i.e. the scanned codes) to product identifiers.
        // Different items data can be mapped to the same product identifier.
        // To test the codes defined below use MSPickSampleCodes.pdf, included in this sample
        let itemDataToProductIdentifier = [
            "8414792869912": "A",
            "3714711193285": "A",
            "4951107312342": "A",
            "1520070879331": "A",

            "1318890267144": "B",
            "9866064348233": "B",
            "4782150677788": "B",
            "2371266523793": "B",

            "5984430889778": "C",
            "7611879254123": "C",
        ]

        pickSessionStore = PickSessionStore(
            productsToPick: productsToPick,
            itemDataToProductIdentifier: itemDataToProductIdentifier
        )
    }

    private func setupRecognition() {
        barcodePickView?.stop()
        barcodePickView?.removeFromSuperview()
        context.removeAllModes()

        // The barcode pick process is configured through barcode pick settings
        // and are then applied to the barcode pick instance that manages barcode pick.
        let settings = BarcodePickSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)

        // Create the product provider, passing the list of products to pick and a delegate
        let productProvider = BarcodePickAsyncMapperProductProvider(
            products: pickSessionStore.productsToPick,
            providerDelegate: self
        )

        // Create new Barcode Pick mode with the settings from above.
        barcodePick = BarcodePick(
            context: context,
            settings: settings,
            productProvider: productProvider
        )
        barcodePick.addScanningListener(self)

        // To visualize the on-going barcode pick process on screen, setup a barcode pick view that renders the
        // camera preview and the barcode pick UI.
        let viewSettings = BarcodePickViewSettings()
        barcodePickView = BarcodePickView(
            frame: view.bounds,
            context: context,
            barcodePick: barcodePick,
            settings: viewSettings
        )
        barcodePickView.addActionListener(self)
        barcodePickView.uiDelegate = self
        barcodePickView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barcodePickView)
        view.sendSubviewToBack(barcodePickView)
        NSLayoutConstraint.activate([
            barcodePickView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            barcodePickView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            barcodePickView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barcodePickView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ResultListViewController {
            destination.pickedItems = pickSessionStore.pickedItems
            destination.inventoryItems = pickSessionStore.inventoryItems
            destination.delegate = self
        }
    }
}

extension PickViewController: BarcodePickViewUIDelegate {
    func barcodePickViewDidTapFinishButton(_ view: BarcodePickView) {
        performSegue(withIdentifier: "showList", sender: nil)
    }
}

extension PickViewController: BarcodePickAsyncMapperProductProviderDelegate {
    // This callback is called to retrieve asynchronously product identifiers
    // for the given itemsData (i.e. the scanned codes).
    // Once retrieved, completionHandler should be invoked with a list of SDCBarcodePickProductProviderCallbackItem,
    // consisting each of an itemData string and its product identifier.
    // The product identifier can be null if not found.
    func mapItems(_ items: [String], completionHandler: @escaping ([BarcodePickProductProviderCallbackItem]) -> Void) {
        let result = items.map { data in
            BarcodePickProductProviderCallbackItem(
                itemData: data,
                productIdentifier: pickSessionStore.itemDataToProductIdentifier[data]
            )
        }
        completionHandler(result)
    }
}

extension PickViewController: BarcodePickScanningListener {
    func barcodePick(_ barcodePick: BarcodePick, didUpdate scanningSession: BarcodePickScanningSession) {
        let pickedItems = scanningSession.pickedItems
        let scannedItems = scanningSession.scannedItems
        DispatchQueue.main.async {
            self.pickSessionStore.update(pickedItems: pickedItems, scannedItems: scannedItems)
        }
    }
}

extension PickViewController: BarcodePickActionListener {
    // This method will be called when the user taps on a code that is not picked.
    // completionHandler must be called to confirm or cancel the action.
    func didPickItem(withData data: String, completionHandler: @escaping (Bool) -> Void) {
        // Delay added to simulate server connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler(true)
        }
    }

    // This method will be called when the user taps on a code that is already picked.
    // completionHandler must be called to confirm or cancel the action.
    func didUnpickItem(withData data: String, completionHandler: @escaping (Bool) -> Void) {
        // Delay added to simulate server connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler(true)
        }
    }
}

extension PickViewController: ResultListViewControllerDelegate {
    func resultListViewControllerDidReset(_ viewController: ResultListViewController) {
        buildSessionStore()
        setupRecognition()
    }
}

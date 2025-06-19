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

class FindViewController: UIViewController {

    private enum Constants {
        static let unWindToSearchSegueIdentifier = "unWindToSearchSegueIdentifier"
    }

    private let context = DataCaptureContext.sharedInstance
    private var barcodeFind: BarcodeFind!
    private var barcodeFindView: BarcodeFindView!
    private var foundItems: [BarcodeFindItem]?

    var symbology: Symbology!
    var itemToFind: BarcodeFindItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SEARCH & FIND"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barcodeFindView.startSearching()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barcodeFindView.stopSearching()
    }

    private func setupRecognition() {
        // The barcode find process is configured through barcode find settings
        // and are then applied to the barcode find instance that manages barcode find.
        let settings = BarcodeFindSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable just the symbology of the barcode to find. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: symbology, enabled: true)

        // Create new Barcode Find mode with the settings from above.
        barcodeFind = BarcodeFind(settings: settings)

        // Set the list of items to find.
        let itemList: Set<BarcodeFindItem> = [itemToFind]
        barcodeFind.setItemList(itemList)

        // To visualize the on-going barcode find process on screen, setup a barcode find view that renders the
        // camera preview and the barcode find UI. The view is automatically added to the parent view hierarchy.
        let viewSettings = BarcodeFindViewSettings()
        barcodeFindView = BarcodeFindView(
            parentView: self.view,
            context: context,
            barcodeFind: barcodeFind,
            settings: viewSettings
        )
        barcodeFindView.uiDelegate = self
        barcodeFindView.prepareSearching()
    }
}

extension FindViewController: BarcodeFindViewUIDelegate {
    // This method is called when the user presses the finish button.
    // The foundItems parameter contains the list of items found in the entire session.
    func barcodeFindView(_ view: BarcodeFindView, didTapFinishButton foundItems: Set<BarcodeFindItem>) {
        performSegue(withIdentifier: Constants.unWindToSearchSegueIdentifier, sender: self)
    }
}

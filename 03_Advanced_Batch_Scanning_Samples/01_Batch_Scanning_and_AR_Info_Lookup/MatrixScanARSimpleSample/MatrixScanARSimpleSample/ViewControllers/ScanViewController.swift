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

class ScanViewController: UIViewController {
    private lazy var context = {
        // Enter your Scandit License key here.
        // Your Scandit License key is available via your Scandit SDK web account.
        DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")
        return DataCaptureContext.shared
    }()
    private var barcodeAr: BarcodeAr!
    private var barcodeArView: BarcodeArView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    var configuration: Configuration!
    private var configurationHandler: ConfigurationHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        titleLabel.text = configuration.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barcodeArView.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barcodeArView.stop()
    }

    func setupRecognition() {
        // Configure the Barcode Ar settings.
        let settings = BarcodeArSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)

        // Create BarcodeAr instance.
        barcodeAr = BarcodeAr(context: context, settings: settings)

        // Create and configure BarcodeArView with default view settings.
        let viewSettings = BarcodeArViewSettings()

        // Use the recommended camera settings for the BarcodeAr mode.
        let recommendedCameraSettings = BarcodeAr.recommendedCameraSettings

        // To visualize the on-going Barcode AR process on screen, setup a Barcode AR view that renders the
        // camera preview and the Barcode AR UI. The view is automatically added to the parent view hierarchy.
        barcodeArView = BarcodeArView(
            parentView: containerView,
            barcodeAr: barcodeAr,
            settings: viewSettings,
            cameraSettings: recommendedCameraSettings
        )

        // Apply the configuration to the AR view
        configurationHandler = configuration.handler
        configurationHandler.apply(to: barcodeArView)
    }
}

class VerticalButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.textAlignment = .center
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.width)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(x: 0.0, y: bounds.width, width: bounds.width, height: bounds.height - bounds.width)
    }
}

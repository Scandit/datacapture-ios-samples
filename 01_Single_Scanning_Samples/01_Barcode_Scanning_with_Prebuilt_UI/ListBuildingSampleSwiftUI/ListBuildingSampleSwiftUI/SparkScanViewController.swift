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

import Foundation
import ScanditBarcodeCapture
import UIKit

class SparkScanViewController: UIViewController {
    private var context: DataCaptureContext!
    private var sparkScan: SparkScan!
    private var sparkScanView: SparkScanView!

    weak var delegate: SparkScanViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSparkScan()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sparkScanView.prepareScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sparkScanView.stopScanning()
    }

    private func setupSparkScan() {
        // Create data capture context
        context = DataCaptureContext.initialize(licenseKey: "-- ENTER YOUR SCANDIT LICENSE KEY HERE --")

        // Configure SparkScan settings
        let settings = SparkScanSettings()
        Set<Symbology>([.ean8, .ean13UPCA, .upce, .code39, .code128, .interleavedTwoOfFive]).forEach {
            settings.set(symbology: $0, enabled: true)
        }
        settings.settings(for: .code39).activeSymbolCounts = Set(7...20)

        // Create SparkScan mode
        sparkScan = SparkScan(settings: settings)
        sparkScan.addListener(self)

        // Create SparkScan view
        sparkScanView = SparkScanView(
            parentView: view,
            context: context,
            sparkScan: sparkScan,
            settings: SparkScanViewSettings()
        )
        sparkScanView.feedbackDelegate = self
    }
}

// MARK: - SparkScanListener
extension SparkScanViewController: SparkScanListener {
    func sparkScan(_ sparkScan: SparkScan, didScanIn session: SparkScanSession, frameData: FrameData?) {
        guard let barcode = session.newlyRecognizedBarcode else { return }

        let thumbnail = frameData?.imageBuffers.last?.image?.resize(
            for: CGSize(width: 56, height: 56)
        )

        delegate?.sparkScanViewController(self, didScanBarcode: barcode, thumbnail: thumbnail)
    }
}

// MARK: - SparkScanFeedbackDelegate
extension SparkScanViewController: SparkScanFeedbackDelegate {
    func feedback(for barcode: Barcode) -> SparkScanBarcodeFeedback? {
        delegate?.sparkScanViewController(self, feedbackFor: barcode) ?? SparkScanBarcodeSuccessFeedback()
    }
}

// MARK: - SparkScanViewControllerDelegate
protocol SparkScanViewControllerDelegate: AnyObject {
    func sparkScanViewController(
        _ viewController: SparkScanViewController,
        didScanBarcode barcode: Barcode,
        thumbnail: UIImage?
    )
    func sparkScanViewController(
        _ viewController: SparkScanViewController,
        feedbackFor barcode: Barcode
    ) -> SparkScanBarcodeFeedback?
}

// MARK: - UIImage Extension
private extension UIImage {
    func resize(for size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

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

import UIKit
import ScanditBarcodeCapture

class ScanViewController: UIViewController {

    typealias CompletionHandler = () -> Void

    private enum Constants {
        static let shownDurationInContinuousMode: TimeInterval = 0.5
    }

    var context: DataCaptureContext {
        return SettingsManager.current.context
    }

    var camera: Camera? {
        return SettingsManager.current.camera
    }

    var barcodeCapture: BarcodeCapture {
        return SettingsManager.current.barcodeCapture
    }

    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!

    private var resultView: ResultView?
    private var lastScan = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        barcodeCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    private func setupRecognition() {
        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        SettingsManager.current.captureView = captureView
    }

    private func setupResultViewIfNeeded() -> ResultView {
        if let resultView = resultView {
            return resultView
        }
        let resultView = ResultView()
        resultView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultView)
        NSLayoutConstraint.activate([
            resultView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
        self.resultView = resultView
        return resultView
    }

    private func showResult(_ result: [Barcode], completion: @escaping () -> Void) {
        DispatchQueue.main.async { [unowned self] in
            let result = Result(barcodes: result)
            if SettingsManager.current.isContinuousModeEnabled {
                let resultView = self.setupResultViewIfNeeded()
                resultView.resultLabel.text = result.text
                resultView.isHidden = false
                self.lastScan = NSDate()
            } else {
                let alert = UIAlertController(title: "Scan Results", message: result.text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    completion()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ScanViewController: BarcodeCaptureListener {

    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        if !SettingsManager.current.isContinuousModeEnabled {
            // Stop recognizing barcodes for as long as we are displaying the result.
            // There won't be any new results until the capture mode is enabled again.
            // Note that disabling the capture mode does not stop the camera, the camera
            // continues to stream frames until it is turned off.
            barcodeCapture.isEnabled = false
        }

        showResult(session.newlyRecognizedBarcodes) {
            if !SettingsManager.current.isContinuousModeEnabled {
                // Enable recognizing barcodes when the result is not shown anymore.
                barcodeCapture.isEnabled = true
            }
        }
    }

    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didUpdate session: BarcodeCaptureSession,
                        frameData: FrameData) {
        DispatchQueue.main.async {
            if -self.lastScan.timeIntervalSinceNow > Constants.shownDurationInContinuousMode {
                self.resultView?.isHidden = true
            }
        }
    }
}

private struct Result {
    let barcodes: [Barcode]

    var text: String {
        return barcodes.reduce(into: "") { result, barcode in

            result += "\(barcode.symbology.readableName): "

            if let data = barcode.data {
                result += " \(data)"
            }

            if let addOnData = barcode.addOnData {
                result += " \(addOnData)"
            }

            if let compositeData = barcode.compositeData {
                switch barcode.compositeFlag {
                case .gs1TypeA:
                    result = "CC Type A\n" + result
                case .gs1TypeB:
                    result = "CC Type B\n" + result
                case .gs1TypeC:
                    result = "CC Type C\n" + result
                default:
                    break
                }
                result += "\n\(compositeData)"
            }

            if barcode.symbolCount != -1 {
                result += "\nSymbol Count: \(barcode.symbolCount)\n\n"
            }
        }
    }
}

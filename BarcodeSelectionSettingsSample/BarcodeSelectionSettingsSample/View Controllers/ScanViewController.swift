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

import UIKit
import ScanditBarcodeCapture

struct Result {
    let data: String
    let symbology: Symbology
    let count: Int
}

class ScanViewController: UIViewController {

    private var context: DataCaptureContext {
        return SettingsManager.current.context
    }

    private var camera: Camera? {
        return SettingsManager.current.camera
    }

    private var barcodeSelection: BarcodeSelection {
        return SettingsManager.current.barcodeSelection
    }

    private var captureView: DataCaptureView!
    private var overlay: BarcodeSelectionBasicOverlay!
    private var resultLabel: UILabel!
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        setupResultLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        barcodeSelection.isEnabled = true
        camera?.switch(toDesiredState: .on)
        // When returning from the settings screen, update overlay accordingly.
        SettingsManager.current.createAndSetupBarcodeSelectionBasicOverlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Switch camera off to stop streaming frames.
        barcodeSelection.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    deinit {
        // It is good practice to properly disable the mode.
        barcodeSelection.isEnabled = false
        barcodeSelection.removeListener(self)
    }

    private func setupRecognition() {
        // Register self as a listener to get informed whenever a new barcode is selected/unselected.
        barcodeSelection.addListener(self)

        // To visualize the on-going barcode selection process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Disable the zoom gesture.
        captureView.zoomGesture = nil
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        SettingsManager.current.captureView = captureView
    }

    private func setupResultLabel() {
        resultLabel = UILabel()
        resultLabel.backgroundColor = UIColor(white: 0, alpha: 0.8)
        resultLabel.textColor = .white
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.preferredFont(forTextStyle: .body)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.layer.cornerRadius = 3
        view.addSubview(resultLabel)
        view.addConstraints([
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }

    private func updateResult(results: [Result]) {
        var string = ""
        for i in 0..<results.count {
            let result = results[i]
            string += "\(result.data)\nSymbology: \(result.symbology.description)\nCount: \(result.count)"
            if i < results.count - 1 {
                string += "\n\n"
            }
        }
        DispatchQueue.main.async {
            self.resultLabel.alpha = 1
            self.resultLabel.text = string
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                              target: self,
                                              selector: #selector(self.hideResult),
                                              userInfo: nil,
                                              repeats: false)
        }
    }

    @objc private func hideResult() {
        UIView.animate(withDuration: 0.3) {
            self.resultLabel.alpha = 0
        }
    }
}

extension ScanViewController: BarcodeSelectionListener {
    func barcodeSelection(_ barcodeSelection: BarcodeSelection,
                          didUpdateSelection session: BarcodeSelectionSession,
                          frameData: FrameData?) {
        let results = session.newlySelectedBarcodes.map {
            Result(data: $0.data ?? "[binary result]",
                   symbology: $0.symbology,
                   count: session.count(for: $0))
        }
        if results.count > 0 {
            updateResult(results: results)
        }
    }
}

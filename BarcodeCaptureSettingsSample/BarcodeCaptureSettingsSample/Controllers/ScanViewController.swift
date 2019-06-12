/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import UIKit
import ScanditBarcodeCapture

class ScanViewController: UIViewController {

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

    var resultViewController: ResultViewController {
        return children.first { $0 is ResultViewController } as! ResultViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
        resultViewController.delegate = self
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
        // it's a good idea to first disable barcode tracking as well.
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    func setupRecognition() {
        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(frame: view.bounds)
        captureView.context = context
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
        SettingsManager.current.captureView = captureView
    }

    private func showResult(_ result: [Barcode], completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.resultViewController.isContinuousModeEnabled = SettingsManager.current.isContinuousModeEnabled
            self?.resultViewController.show(barcodes: result, completion: completion)
        }
    }

}

extension ScanViewController: ResultViewControllerDelegate {
    func willShow(resultViewController: ResultViewController) {
        resultViewController.view.superview?.isHidden = false
    }

    func didHide(resultViewController: ResultViewController) {
        resultViewController.view.superview?.isHidden = true
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

}

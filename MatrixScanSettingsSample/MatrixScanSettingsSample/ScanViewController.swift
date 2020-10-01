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
import ScanditCaptureCore
import ScanditBarcodeCapture

class ScanViewController: UIViewController {

    var mode: Mode!
    var cameraResolution: CameraResolution!

    var captureView: DataCaptureView!
    var camera: Camera?
    var context: DataCaptureContext!

    var barcodeTracking: BarcodeTracking!
    var barcodeTrackingOverlay: BarcodeTrackingBasicOverlay!
    var torchControl: TorchSwitchControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        context = DataCaptureContext.licensed
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)
        camera?.apply(cameraSettings(), completionHandler: nil)
        camera?.switch(toDesiredState: .on)
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        barcodeTracking = BarcodeTracking(context: context, settings: barcodeTrackingSettings())
        barcodeTrackingOverlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking, view: captureView)

        torchControl = TorchSwitchControl()
        captureView.addControl(torchControl)
    }

    func cameraSettings() -> CameraSettings {
        let cameraSettings = BarcodeTracking.recommendedCameraSettings

        switch cameraResolution! {
        case .fullHD:
            cameraSettings.preferredResolution = .fullHD
        case .uhd4k:
            cameraSettings.preferredResolution = .uhd4k
        }

        return cameraSettings
    }

    func barcodeTrackingSettings() -> BarcodeTrackingSettings {
        let barcodeTrackingSettings = BarcodeTrackingSettings()
        barcodeTrackingSettings.set(value: true, forProperty: "conv_net_localization")

        switch mode! {
        case .mono:
            barcodeTrackingSettings.set(symbology: .code128, enabled: true)
            barcodeTrackingSettings.set(symbology: .code39, enabled: true)
            barcodeTrackingSettings.set(symbology: .interleavedTwoOfFive, enabled: true)
            barcodeTrackingSettings.set(symbology: .ean13UPCA, enabled: true)
            barcodeTrackingSettings.set(symbology: .upce, enabled: true)
        case .bi:
            barcodeTrackingSettings.set(symbology: .dataMatrix, enabled: true)
            barcodeTrackingSettings.set(symbology: .qr, enabled: true)

        case .both:
            barcodeTrackingSettings.set(symbology: .code128, enabled: true)
            barcodeTrackingSettings.set(symbology: .code39, enabled: true)
            barcodeTrackingSettings.set(symbology: .interleavedTwoOfFive, enabled: true)
            barcodeTrackingSettings.set(symbology: .ean13UPCA, enabled: true)
            barcodeTrackingSettings.set(symbology: .upce, enabled: true)
            barcodeTrackingSettings.set(symbology: .dataMatrix, enabled: true)
            barcodeTrackingSettings.set(symbology: .qr, enabled: true)
        }

        return barcodeTrackingSettings
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

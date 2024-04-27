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

import ScanditBarcodeCapture

extension DataCaptureContext {
	// There is a Scandit sample license key set below here.
	// This license key is enabled for sample evaluation only.
	// If you want to build your own application,
    // get your license key by signing up for a trial at https://ssl.scandit.com/dashboard/sign-up?p=test
    private static let licenseKey = "AujUxmb0QvgqNMrEA2at/w02rYwJABlEoyZzRLQSpOiYfk3Irnb9oQVosJ7SAUotcxjXTX9jb47EY7ODRHqoIFlJnMi1XNOT+QAyDGFoE7VrAztr6CpYz3Md8fjzS7ABIwVBU915lRZuVQyBFlfRx0AkWVTabW3xsWjRc55i28NsRHNkBWZ3gJ1DWzOrFToX5WVmgSJHZ1DpU5B661FSL5R1zhaSTWuqpURUJs5tXW7NWrRgvlY8aDpO4C5pVXD67FH22Bd/fNnhZaNDrWWlUOV2borLR1yMr1xwh7Ng605uYWTjS121lsVNxgMcbCUcpVtOka9K0BIbW2pS60GdYHZFZoTMZfZMXWGi948ROWTBApgiUiZSeypKSN95dtfdchbtbvthv5CjTwjPWVy45qZZak8nXTjZUjFPceRqjIHobC36Xwt7YLRuoYPSZPQkbDHbT4lGs7kjbyT0bRNQL5Aahlj7VNxkNG5GxbI4ZGpBSgQJ1U9Nyq8nNZRGUMtRv1o29thElNGbc+nV73mesw5hYGhGDlNUCkWQeWUIu2sKe4/qHQLZf0h2fI3RY2TyzgrRzQBi5i7yZasVBl0jiSwTVPp/f/xN9kJ038Jr3VGzF+f6ejlWF5hnrlJYfrtsaF4eazxdCN0hWYq8BhWS75EvkgZDep5ES3kaWb83PtMFP53IlhweiqJODhyZAOkPv3vzgJlKYrpVKVyUdwBkP/BWxpGYVxUfOVFGIpFipXEPcetNeCK4cFBpv75oMGtMjWhrN/pZMVRJS7kXlnTaBH4pTGovdj7WG3NA2oAWhTm2Y2QVKWc7YYpl/KiYYxWOp2v0Pb9794R+WUZneVBM3g1gJfQKcImYcwxZv1JppKakajhs+G0EgqJA5CzRBKzeqFK5oct7CTUmVNcSL3Wpgctjte/nKw+Yxlz6yIMFZRQ+XsE50G4R9Nx/s/A5V8x1KkDNSB9NTjYjTtr7+XGt5NlBgKf+VW1R7k6JdjMNMzP+762omXu4MSAd2i0aiPNP1036wkPmy+VDHZ7/PlxhqDgwiK6nLzeXnWmHaFXk3dNvsUWC02J+vOd3XX8KeWbRjM/uSEnTSG2AQFENECYMVy0NxmgvfGIR21PJ75633mv4xFzxMvUpDQRippTDF6DyANn2fEv9ksfmNt3hsHdGWTNvL5ZXr6EDGhnEtA7oBJFTnYiZL6sg6KFJNFoAhTEllcFHlP+MMIDmT15SkuED70PRqz0/a8W4hSwv5PG27ebjotmiLhiECWnDEjYHu2Yz0gN+qeDHnZ/8pBgGpxgtCeFbRE5B2MX+7cMDDmwjxutolH1q1dZodmxgWPie5sH2fcfe6VzArwnlRu65ryi9+3CoqwVk74hlszM0xKETJ3h/Z4aYF0EpUjv190qho2DWcgoq3JmUef3yjidqvjgBuQHvnhtKzFiZNGlxF55GkD/FclcJWvtGC34xBA+CX5/oVB6DViZ8DCYwoc6ZSvMEvfUUIfJf0HfUKv2apcynctDHm7+Ku/9tDEd0nyVFGoRse3z8oEPM0u4Os6DyxRDJatKpIotBvCBXkqO7dtfrCAfQFTJGp/UIO6iylEZjVOdU/Lq+PdEWmhetzZuqclejxuw5I6SwfKgCNIL8HJ/lrCuus1TJkbY7Fnpf884s5cMsV68oPgFIzjHvAxBi0A2JvA=="

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        return DataCaptureContext(licenseKey: licenseKey)
    }
}

class ViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on. To be notified when the camera is completely on, pass non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        barcodeCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        // To be notified when the camera is completely stopped, pass a non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommendedCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommendedCameraSettings)

        // The barcode capturing process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let settings = BarcodeCaptureSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true)

        // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
        // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
        // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
        // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        let symbologySettings = settings.settings(for: .code39)
        symbologySettings.activeSymbolCounts = Set(7...20)

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: settings)

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, view: captureView, style: .frame)
        overlay.viewfinder = RectangularViewfinder(style: .square, lineStyle: .light)
    }

    private func showResult(_ result: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

// MARK: - BarcodeCaptureListener

extension ViewController: BarcodeCaptureListener {

    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcodes.first else {
            return
        }

        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new results until
        // the capture mode is enabled again. Note that disabling the capture mode does not stop the camera, the camera
        // continues to stream frames until it is turned off.
        barcodeCapture.isEnabled = false

        // If you are not disabling barcode capture here and want to continue scanning, consider setting the
        // codeDuplicateFilter when creating the barcode capture settings to around 500 or even -1 if you do not want
        // codes to be scanned more than once.

        // Get the human readable name of the symbology and assemble the result to be shown.
        let symbology = SymbologyDescription(symbology: barcode.symbology).readableName

        var result = "Scanned: "
        if let data = barcode.data {
            result += "\(data) "
        }
        result += "(\(symbology))"

        showResult(result) { [weak self] in
            // Enable recognizing barcodes when the result is not shown anymore.
            self?.barcodeCapture.isEnabled = true
        }
    }

}

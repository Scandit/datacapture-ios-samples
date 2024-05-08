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
import ScanditTextCapture
import ScanditParser

struct ParsedField {
    let key: String
    let value: String
}

class ScannerViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var captureView: DataCaptureView!

    private var textCaptureEnabled: Bool = false
    private var modeBarcodeCapture: BarcodeCapture!
    private var modeTextCapture: TextCapture!

    private var overlay: BarcodeTrackingBasicOverlay!
    private var overlayBarcodeCapture: BarcodeCaptureOverlay!
    private var overlayTextCapture: TextCaptureOverlay!

    private var parser: Parser!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        modeBarcodeCapture.isEnabled = false
        modeTextCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultsViewController = segue.destination as? ResultViewController,
        let parsedFields = sender as? [ParsedField] else {
            return
        }
        resultsViewController.results = parsedFields
    }

    @IBAction func unwindToScanner(segue: UIStoryboardSegue) {
        resumeScanning()
    }

    @IBAction func switchToTextCapture(_ sender: Any) {
        textCaptureEnabled = true
        modeBarcodeCapture.isEnabled = false
        modeTextCapture.isEnabled = true
        captureView.removeOverlay(overlayBarcodeCapture)
        captureView.addOverlay(overlayTextCapture)
    }

    @IBAction func switchToBarcodeCapture(_ sender: Any) {
        textCaptureEnabled = false
        modeTextCapture.isEnabled = false
        modeBarcodeCapture.isEnabled = true
        captureView.removeOverlay(overlayTextCapture)
        captureView.addOverlay(overlayBarcodeCapture)
    }

    private func resumeScanning() {
        if textCaptureEnabled {
            modeTextCapture.isEnabled = true
        } else {
            modeBarcodeCapture.isEnabled = true
        }
        camera?.switch(toDesiredState: .on)
    }

    private func setupRecognition() {
        // Setting up the DataCaptureContext
        context = DataCaptureContext.licensed

        // Setting up the Camera
        let cameraSettings = BarcodeCapture.recommendedCameraSettings
        cameraSettings.preferredResolution = .fullHD
        camera = Camera.default
        camera?.apply(cameraSettings, completionHandler: nil)
        context.setFrameSource(camera, completionHandler: nil)

        // Setting up the DataCaptureView
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.context = context
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)

        // Initializing the parser
        parser = try! Parser(context: context, format: .vin)

        /**
         - strictMode - Accept only VINs with valid checksums.
         - falsePositiveCompensation - Since VINs cannot contain 'Q', 'O', 'I',
         if they appear, assume it's an OCR engine mistake and replace them with similar characters.
         */
        let options = [
            "strictMode": true as NSNumber,
            "falsePositiveCompensation": true as NSNumber
        ]

        try! parser.setOptions(options)

        setupModesAndOverlays()
    }

    private func setupModesAndOverlays() {
        let size = SizeWithUnit(width: FloatWithUnit(value: 0.7, unit: .fraction),
                                height: FloatWithUnit(value: 0.07, unit: .fraction))
        let locationSelection = RectangularLocationSelection(size: size)
        // Setting up TextCapture
        let json = """
        {
            "regex": "[0-9A-Z]{17}",
            "characterWhitelist": "ABCDEFGHJKLMNPRSTUVWXYZ01234567890",
            "properties": {
                "k_out_of_n_filter_threshold": "3",
                "k_out_of_n_filter_window_size": "5"
            }
        }
        """
        let settingsText = try! TextCaptureSettings(jsonString: json)
        settingsText.locationSelection = locationSelection
        modeTextCapture = TextCapture(context: context, settings: settingsText)
        modeTextCapture.addListener(self)
        // Preparing and removing TextCaptureOverlay as BarcodeCaptureOveralay is the default one
        let viewfinder = RectangularViewfinder(style: .square, lineStyle: .bold)
        viewfinder.setSize(size)
        overlayTextCapture = TextCaptureOverlay(textCapture: modeTextCapture, view: nil)
        overlayTextCapture.viewfinder = viewfinder
        // Disabling TextCapture as BarcodeCapture is the default one
        modeTextCapture.isEnabled = false

        // Setting up BarcodeCapture
        let settingsBarcode = BarcodeCaptureSettings()
        settingsBarcode.set(symbology: .code39, enabled: true)
        settingsBarcode.codeDuplicateFilter = 3000
        settingsBarcode.locationSelection = locationSelection
        let symbologySettings = settingsBarcode.settings(for: .code39)
        symbologySettings.activeSymbolCounts = Set(18...22)
        symbologySettings.isColorInvertedEnabled = true
        modeBarcodeCapture = BarcodeCapture(context: context, settings: settingsBarcode)
        modeBarcodeCapture.addListener(self)
        // Preparing BarcodeCaptureOverlay
        overlayBarcodeCapture = BarcodeCaptureOverlay(barcodeCapture: modeBarcodeCapture, view: captureView)
        overlayBarcodeCapture.viewfinder = LaserlineViewfinder(style: .animated)
    }

    private func parseResult(result: String) {
        do {
            var parsedFields = [ParsedField]()
            let parsedData = try parser.parseString(result)
            let vmi = parsedData.fieldsByName["WMI"]?.parsed as? [String: NSObject]
            let region = vmi?["region"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Region", value: region))

            let fullCode = vmi?["fullCode"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Full Code", value: fullCode))

            let numberOfVehicles = vmi?["numberOfVehicles"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Number Of Vehicles", value: numberOfVehicles))

            let vds = parsedData.fieldsByName["VDS"]?.parsed as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "VDS", value: vds))

            let vis = parsedData.fieldsByName["VIS"]?.parsed as? [String: NSObject]

            if let modelYear = vis?["modelYear"] as? [Int] {
                let minModelYear = String((modelYear[0]))
                parsedFields.append(ParsedField(key: "Min Model Year", value: minModelYear))

                let maxModelYear = String((modelYear[1]))
                parsedFields.append(ParsedField(key: "Max Model Year", value: maxModelYear))
            }

            let plant = vis?["plant"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Plant", value: plant))

            let wmiSuffix = vis?["wmiSuffix"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "WMI Suffix", value: wmiSuffix ))

            let serialNumber = vis?["serialNumber"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Serial Number", value: serialNumber))

            let metaData = parsedData.fieldsByName["metadata"]?.parsed as? [String: NSObject]
            let checksum = metaData?["checksum"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Checksum", value: checksum))

            let passedChecksum = metaData?["passedChecksum"] as! Bool
            parsedFields.append(ParsedField(key: "Passed Checksum", value: String(passedChecksum)))

            let standard = metaData?["standard"] as? String ?? "unspecified"
            parsedFields.append(ParsedField(key: "Standard", value: standard))

            guard (standard == "northAmerica" && passedChecksum) || standard != "northAmerica" else {
                showMessage("Invalid Checksum") { [weak self] in
                    self?.resumeScanning()
                }
                return
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ResultSegue", sender: parsedFields)
            }

        } catch {
            showMessage("Parsing Failed") { [weak self] in
                self?.resumeScanning()
            }
        }
    }

    private func showMessage(_ result: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

// MARK: - TextCapureListener
extension ScannerViewController: TextCaptureListener {
    // This function is called whenever objects are updated and it's the right place to react to the scanning results.
    func textCapture(_ textCapture: TextCapture, didCaptureIn session: TextCaptureSession, frameData: FrameData) {
        let capturedText = session.newlyCapturedTexts.first!.value
        textCapture.isEnabled = false
        parseResult(result: capturedText)
    }
}

// MARK: - BarcodeCapureListener
extension ScannerViewController: BarcodeCaptureListener {
    // This function is called whenever objects are updated and it's the right place to react to the scanning results.
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcodes.first?.data else { return }
        barcodeCapture.isEnabled = false
        parseResult(result: barcode)
    }
}

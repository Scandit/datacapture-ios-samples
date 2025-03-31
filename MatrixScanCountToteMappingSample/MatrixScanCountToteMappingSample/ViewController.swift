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

extension DataCaptureContext {
    // Enter your Scandit License key here.
    // Your Scandit License key is available via your Scandit SDK web account.
    private static let licenseKey = "-- ENTER YOUR SCANDIT LICENSE KEY HERE --"

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        return DataCaptureContext(licenseKey: licenseKey)
    }
}

class ViewController: UIViewController {
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCount: BarcodeCount!
    private var barcodeCountView: BarcodeCountView!
    private var shouldRequestMap = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tote Mapping"
        setupRecognition()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .white

        // Create and configure the BarcodeCountView
        createBarcodeCountView()

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on. To be notified when the camera is completely on, pass non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        camera?.switch(toDesiredState: .on)
        resetMode()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera to stanby to stop streaming frames. The camera is stopped asynchronously and will take
        // some time to completely turn off.
        // To be notified when the camera is completely stopped, pass a non nil block as completion to
        // camera?.switch(toDesiredState:completionHandler:)
        camera?.switch(toDesiredState: .standby)

        if isMovingFromParent {
            // Stop the mode when dismissed
            barcodeCountView.stopScanning()
        }
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCount mode.
        let recommendedCameraSettings = BarcodeCount.recommendedCameraSettings
        recommendedCameraSettings.preferredResolution = .uhd4k
        camera?.apply(recommendedCameraSettings)

        // The barcode counting process is configured through barcode count settings
        // and are then applied to the barcode count instance that manages barcode recognition.
        let settings = BarcodeCountSettings()

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
        settings.set(symbology: .arUco, enabled: true)

        // Enable mapping mode
        settings.mappingEnabled = true
        settings.expectsOnlyUniqueBarcodes = true

        // Create new barcode count mode with the settings from above.
        barcodeCount = BarcodeCount(context: context, settings: settings)

        // Register self as a listener to monitor the barcode count session.
        barcodeCount.addListener(self)
    }

    private func createBarcodeCountView() {
        // Remove existing view if it exists
        barcodeCountView?.removeFromSuperview()

        // Configure the mapping flow settings
        let mappingSettings = BarcodeCountMappingFlowSettings()

        // To visualize the Barcode Count UI you need to create a BarcodeCountView and add it to the view hierarchy.
        // BarcodeCountView is designed to be displayed full screen.
        barcodeCountView = BarcodeCountView(forMappingWithFrame: view.bounds,
                                          context: context,
                                          barcodeCount: barcodeCount,
                                            style: .icon,
                                            topLayoutAnchor: nil,
                                          mappingSettings: mappingSettings)
        barcodeCountView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(barcodeCountView)
        barcodeCountView.uiDelegate = self
        barcodeCountView.tapToUncountEnabled = true
        barcodeCountView.shouldDisableModeOnExitButtonTapped = false
        barcodeCountView.shouldShowListButton = false

        // Prepare scanning
        barcodeCountView.prepareScanning(with: context)
    }

    private func showGrid(_ grid: BarcodeSpatialGrid) {
        do {
            let gridEditorViewSettings = BarcodeSpatialGridEditorViewSettings()
            let view = try BarcodeSpatialGridEditorView(
                frame: .zero,
                grid: grid,
                settings: gridEditorViewSettings
            )
            view.delegate = self
            let vc = BarcodeGridEditorViewController(view: view)
            navigationController?.pushViewController(vc, animated: true)
        } catch {
            let alertController = UIAlertController(
                title: "Error",
                message: "Failed to initialize the spatial grid editor view: \(error.localizedDescription)",
                preferredStyle: .alert
            )
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            present(alertController, animated: true)
        }
    }

    @objc func didEnterBackground() {
        resetMode()
    }

    private func resetMode() {
        barcodeCount.reset()
    }
}

extension ViewController: BarcodeCountListener {
    func barcodeCount(_ barcodeCount: BarcodeCount,
                      didUpdate session: BarcodeCountSession,
                      frameData: any FrameData) {
        guard shouldRequestMap else { return }
        shouldRequestMap = false

        guard session.recognizedBarcodes.count > 0,
              let grid = session.spatialMap(withExpectedNumberOfRows: 4, expectedNumberOfColumns: 2) else {
            DispatchQueue.main.async { [weak self] in
                self?.handleMapCreationError()
            }
            return
        }

        DispatchQueue.main.async {
            self.showGrid(grid)
        }
    }

    func barcodeCount(_ barcodeCount: BarcodeCount,
                      didScanIn session: BarcodeCountSession,
                      frameData: FrameData) {

    }

    func handleMapCreationError() {
        let alert = UIAlertController(title: "Unable to map totes",
                                      message: "Please start over and try again",
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            // Recreate the view to restart the flow.
            self?.createBarcodeCountView()
            self?.resetMode()
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}

extension ViewController: BarcodeCountViewUIDelegate {
    func exitButtonTapped(for view: BarcodeCountView) {
        // Trigger map
        shouldRequestMap = true
    }
}

extension ViewController: BarcodeSpatialGridEditorViewDelegate {
    func barcodeSpatialGridEditorView(_ view: BarcodeSpatialGridEditorView,
                                      didFinishEditingWith spatialGrid: BarcodeSpatialGrid) {
        let alert = UIAlertController(title: nil,
                                      message: "This map can now be used during MatrixScanCountToteMappingSample",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        present(alert, animated: true)
    }

    func didCancelEditing(in view: BarcodeSpatialGridEditorView) {
        self.navigationController?.popViewController(animated: true)
    }
}

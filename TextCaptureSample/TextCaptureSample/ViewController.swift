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
import ScanditCaptureCore
import ScanditTextCapture

class ViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var captureView: DataCaptureView!
    private var textCapture: TextCapture!
    private var overlay: TextCaptureOverlay!
    private var settings: Settings = Settings(mode: .gs1ai, scanPosition: .center)
    private var feedback: Feedback!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextCapture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch the camera on. The camera frames will be sent to TextCapture for processing.
        // Additionally the preview will appear on the screen. The camera is started asynchronously,
        // and you may notice a small delay before the preview appears.
        camera?.switch(toDesiredState: .on)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Switch the camera off to stop streaming frames. The camera is stopped asynchronously.
        camera?.switch(toDesiredState: .off)
    }

    private func setupTextCapture() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed
        // Create a new DataCaptureView and fill the screen with it. DataCaptureView will show
        // the camera frames on the screen.
        // the camera preview on the screen. Pass your DataCaptureContext to the view's
        // constructor.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.context = context
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Set the device's default camera as DataCaptureContext's FrameSource. DataCaptureContext
        // passes the frames from it's FrameSource to the added modes to perform capture or
        // tracking.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Since we are going to perform TextCapture in this sample, we initiate the camera with
        // the recommended settings for this mode.
        let cameraSettings = TextCapture.recommendedCameraSettings
        cameraSettings.preferredResolution = .fullHD
        camera?.apply(cameraSettings, completionHandler: nil)

        // Create a mode responsible for recognizing the text. This mode is automatically added
        // to the passed DataCaptureContext.
        textCapture = TextCapture(context: context, settings: textCaptureSettings())

        // Start listening on TextCapture events.
        textCapture.addListener(self)

        // We set the center of the location selection.
        textCapture.pointOfInterest = pointOfInterest()

        // Add TextCaptureOverlay with RectangularViewfinder to DataCaptureView. This will visualize
        // the part of the frame currently taken into account for the text capture.
        let viewFinder = settings.mode.viewfinder

        overlay = TextCaptureOverlay(textCapture: textCapture, view: captureView)
        overlay.brush = .transparent
        overlay.viewfinder = viewFinder

        // Since we additionally validate IBANs in this sample, we don't want to emit feedback
        // every time something is recognized, but every time the recognized text additionally
        // passes our validation. Therefore we disable the default feedback for TextCapture
        // and create a new one, which we will invoke manually.
        let noFeedback = TextCaptureFeedback()
        noFeedback.success = Feedback()
        textCapture.feedback = noFeedback

        feedback = Feedback.default
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController,
            let settingsVC = nc.topViewController as? SettingsViewController {
            textCapture.isEnabled = false
            settingsVC.delegate = self
            settingsVC.settings = settings
        }
    }

    private func textCaptureSettings() -> TextCaptureSettings {
        // While some of the TextCaptureSettings can be modified directly, some of them, like
        // `regex`, would normally be configured by a JSON you receive from us, tailored to your
        // specific use-case. Since in this sample we demonstrate work with several different
        // regular expressions, we simulate this by reading the setting from Settings and
        // creating JSON by hand.

        let jsonSettings =
        """
        {"regex": "\(settings.mode.regex)"}
        """

        guard let textCaptureSettings = try? TextCaptureSettings(jsonString: jsonSettings) else {
            fatalError("Invalid text capture settings json")
        }

        // We will limit the text capture to the specific area. We will move the center of this rectangle
        // depending on whether `.bottom`, `.center`, and `.top` ScanPosition is selected,
        // by controlling TextCapture's `pointOfInterest` property.
        textCaptureSettings.locationSelection = settings.mode.locationSelection

        return textCaptureSettings
    }

    private func pointOfInterest() -> PointWithUnit {
        let poi = CGPoint(x: 0.5, y: settings.scanPosition.scanAreaY)
        return PointWithUnit(point: poi, unit: .fraction)
    }
}

extension ViewController: TextCaptureListener {
    func textCapture(_ textCapture: TextCapture, didCaptureIn session: TextCaptureSession, frameData: FrameData) {
        guard let text = session.newlyCapturedTexts.first else { return }
        textCapture.isEnabled = false
        // Otherwise show an alert with the text recognized.
        // Emit feedback signalling that text was recognized.
        feedback.emit()

        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Text Recognized", message: text.value, preferredStyle: .alert)
            let resume = UIAlertAction(title: "Resume", style: .default, handler: { (_) in
                textCapture.isEnabled = true
            })
            alert.addAction(resume)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: SettingsViewControllerDelegate {
    func didCancel() {
        self.textCapture.isEnabled = true
    }

    func didChangeSettings(_ settings: Settings) {
        self.settings = settings
        let textCaptureSettings = self.textCaptureSettings()
        textCapture.apply(textCaptureSettings) {
            self.textCapture.pointOfInterest = self.pointOfInterest()
            self.overlay.viewfinder = settings.mode.viewfinder
            self.textCapture.isEnabled = true
        }
    }
}

extension SizeWithUnit {
    init(size: CGSize, unit: MeasureUnit) {
        let width = FloatWithUnit(value: size.width, unit: unit)
        let height = FloatWithUnit(value: size.height, unit: unit)
        self.init(width: width, height: height)
    }
}

extension PointWithUnit {
    init(point: CGPoint, unit: MeasureUnit) {
        let x = FloatWithUnit(value: point.x, unit: unit)
        let y = FloatWithUnit(value: point.y, unit: unit)
        self.init(x: x, y: y)
    }
}

extension Settings.Mode {
    private var scanAreaSize: CGSize {
        switch self {
        case .gs1ai:
            return CGSize(width: 0.9, height: 0.1)
        case .lot:
            return CGSize(width: 0.6, height: 0.1)
        }
    }

    var viewfinder: Viewfinder {
        let viewFinder = RectangularViewfinder(style: .square, lineStyle: .light)
        viewFinder.dimming = 0.2
        viewFinder.setSize(SizeWithUnit(size: scanAreaSize, unit: .fraction))
        return viewFinder
    }

    var locationSelection: LocationSelection {
        RectangularLocationSelection(
            size: SizeWithUnit(size: scanAreaSize,
                               unit: .fraction)
        )
    }
}

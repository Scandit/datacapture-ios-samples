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

extension SettingsManager {

    // MARK: Symbologies

    var anySymbologyEnabled: Bool {
        return !barcodeCaptureSettings.enabledSymbologyValues.isEmpty
    }

    func setAllSymbologies(enabled: Bool) {
        if enabled {
            let allSymbologies = Set(Symbology.allCases.map { NSNumber(value: $0.rawValue) })
            barcodeCaptureSettings.enableSymbologies(allSymbologies)
        } else {
            barcodeCaptureSettings.enabledSymbologyValues.forEach { symbologyValue in
                let symbology = Symbology(rawValue: symbologyValue.uintValue)!
                barcodeCaptureSettings.set(symbology: symbology, enabled: false)
            }
        }
        barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
    }

    func isSymbologyEnabled(_ symbology: Symbology) -> Bool {
        return barcodeCaptureSettings.enabledSymbologyValues.contains(NSNumber(value: symbology.rawValue))
    }

    func getSymbologySettings(for symbology: Symbology) -> SymbologySettings {
        return barcodeCaptureSettings.settings(for: symbology)
    }

    func symbologySettingsChanged() {
        // Apply barcode capture settings, which includes symbology settings that might've
        // been potentially updated
        return barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
    }

    // MARK: Composite Types

    var enabledCompositeTypes: CompositeType {
        get {
            return barcodeCaptureSettings.enabledCompositeTypes
        }
        set {
            barcodeCaptureSettings.enabledCompositeTypes = newValue
            barcodeCaptureSettings.enableSymbologies(forCompositeTypes: newValue)
            barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
        }
    }

    // MARK: Feedback

    var feedback: Feedback {
        get {
            return barcodeCapture.feedback.success
        }
        set {
            barcodeCapture.feedback.success = newValue
        }
    }

    var vibration: FeedbackVibration {
        get {
            return internalVibration
        }

        set {
            internalVibration = newValue
            feedback = Feedback(vibration: internalVibration.feedbackVibration,
                                sound: feedback.sound)
        }
    }

    // MARK: Location Selection

    var locationSelection: LocationSelection? {
        get {
            return barcodeCaptureSettings.locationSelection
        }
        set {
            barcodeCaptureSettings.locationSelection = newValue
            barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
        }
    }

    // MARK: Code Duplicate Filter

    var codeDuplicateFilter: TimeInterval {
        get {
            return barcodeCaptureSettings.codeDuplicateFilter
        }
        set {
            barcodeCaptureSettings.codeDuplicateFilter = newValue
            barcodeCapture.apply(barcodeCaptureSettings, completionHandler: nil)
        }
    }
}

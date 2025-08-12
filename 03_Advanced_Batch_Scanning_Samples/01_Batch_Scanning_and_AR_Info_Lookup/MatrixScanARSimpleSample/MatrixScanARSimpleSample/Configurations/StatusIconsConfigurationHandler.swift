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

class StatusIconsConfigurationHandler: NSObject, ConfigurationHandler {
    private let closeToExpiryIcon: ScanditIcon
    private let expiredIcon: ScanditIcon

    private enum ItemState {
        case closeToExpiry
        case expired
    }
    private var barcodeDataToState: [String: ItemState] = [:]

    override init() {
        let builder = ScanditIconBuilder()
            .withIcon(.exclamationMark)
            .withBackgroundShape(.circle)
        closeToExpiryIcon =
            builder
            .withIconColor(.black)
            .withBackgroundColor(.scanditYellow)
            .build()
        expiredIcon =
            builder
            .withIconColor(.white)
            .withBackgroundColor(.scanditRed)
            .build()
    }

    func apply(to barcodeArView: BarcodeArView) {
        barcodeArView.highlightProvider = nil
        barcodeArView.annotationProvider = self
        barcodeArView.uiDelegate = nil
    }

    private func updateStyle(for annotation: BarcodeArStatusIconAnnotation) {
        guard let data = annotation.barcode.data else { return }

        let state: ItemState
        if let currentState = barcodeDataToState[data] {
            state = currentState
        } else {
            // Assign initial state to newly scanned barcodes, alternating between the two available states
            state = barcodeDataToState.count % 2 == 0 ? .closeToExpiry : .expired
            barcodeDataToState[data] = state
        }

        switch state {
        case .closeToExpiry:
            annotation.icon = closeToExpiryIcon
            annotation.text = "Close to expiry"
        case .expired:
            annotation.icon = expiredIcon
            annotation.text = "Item expired"
        }
    }
}

extension StatusIconsConfigurationHandler: BarcodeArAnnotationProvider {
    func annotation(for barcode: Barcode) async -> (any UIView & BarcodeArAnnotation)? {
        let annotation = BarcodeArStatusIconAnnotation(barcode: barcode)
        updateStyle(for: annotation)
        return annotation
    }
}

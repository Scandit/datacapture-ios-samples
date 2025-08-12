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

class PopoversConfigurationHandler: NSObject, ConfigurationHandler {
    private let redBrush: Brush
    private let greenBrush: Brush
    private let checkmarkIcon: ScanditIcon
    private let exclamationMarkIcon: ScanditIcon
    private let xMarkIcon: ScanditIcon

    private enum ItemState {
        case undetermined
        case accepted
        case rejected
    }
    private var barcodeDataToState: [String: ItemState] = [:]
    private weak var barcodeArView: BarcodeArView?

    override init() {
        redBrush = Brush(
            fill: .scanditRed,
            stroke: .clear,
            strokeWidth: 0.0
        )
        greenBrush = Brush(
            fill: .scanditGreen,
            stroke: .clear,
            strokeWidth: 0.0
        )

        let builder = ScanditIconBuilder()
            .withIconColor(.white)
        checkmarkIcon =
            builder
            .withIcon(.checkmark)
            .withBackgroundColor(.scanditGreen)
            .withBackgroundShape(.circle)
            .build()
        exclamationMarkIcon =
            builder
            .withIcon(.exclamationMark)
            .build()
        xMarkIcon =
            builder
            .withIcon(.xMark)
            .withBackgroundColor(.scanditRed)
            .withBackgroundShape(.circle)
            .build()
    }

    func apply(to barcodeArView: BarcodeArView) {
        barcodeArView.highlightProvider = self
        barcodeArView.annotationProvider = self
        barcodeArView.uiDelegate = nil
        self.barcodeArView = barcodeArView
    }

    private func updateStyle(for highlight: BarcodeArCircleHighlight) {
        guard let data = highlight.barcode.data else { return }

        let state: ItemState
        if let currentState = barcodeDataToState[data] {
            state = currentState
        } else {
            // Assign initial state to newly scanned barcodes, alternating between undetermined and accepted
            state = barcodeDataToState.count % 2 == 0 ? .undetermined : .accepted
            barcodeDataToState[data] = state
        }

        switch state {
        case .undetermined:
            highlight.brush = redBrush
            highlight.isPulsing = true
            highlight.icon = exclamationMarkIcon
        case .accepted:
            highlight.brush = greenBrush
            highlight.isPulsing = false
            highlight.icon = checkmarkIcon
        case .rejected:
            highlight.brush = redBrush
            highlight.isPulsing = false
            highlight.icon = xMarkIcon
        }
    }
}

extension PopoversConfigurationHandler: BarcodeArHighlightProvider {
    func highlight(for barcode: Barcode) async -> (any UIView & BarcodeArHighlight)? {
        let highlight = BarcodeArCircleHighlight(barcode: barcode, preset: .icon)
        updateStyle(for: highlight)
        return highlight
    }
}

extension PopoversConfigurationHandler: BarcodeArAnnotationProvider {
    func annotation(for barcode: Barcode) async -> (any UIView & BarcodeArAnnotation)? {
        guard let data = barcode.data,
            let state = barcodeDataToState[data],
            state == .undetermined
        else { return nil }

        let rejectButton = BarcodeArPopoverAnnotationButton(icon: xMarkIcon, text: "Reject")
        let acceptButton = BarcodeArPopoverAnnotationButton(icon: checkmarkIcon, text: "Accept")
        let annotation = BarcodeArPopoverAnnotation(barcode: barcode, buttons: [rejectButton, acceptButton])
        annotation.delegate = self
        return annotation
    }
}

extension PopoversConfigurationHandler: BarcodeArPopoverAnnotationDelegate {
    func barcodeArPopoverAnnotation(
        _ annotation: BarcodeArPopoverAnnotation,
        didTap button: BarcodeArPopoverAnnotationButton,
        at index: Int
    ) {
        guard let data = annotation.barcode.data else { return }
        switch index {
        case 0:
            // Reject button
            barcodeDataToState[data] = .rejected
        case 1:
            // Accept button
            barcodeDataToState[data] = .accepted
        default:
            break
        }

        // Reset the AR view to clear cached annotations and trigger fresh annotation requests
        // from the provider when barcodes are detected again
        barcodeArView?.reset()
    }
}

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

class InfoAnnotationsConfigurationHandler: NSObject, ConfigurationHandler {
    private let highlightBrush: Brush
    private let checkmarkIcon: ScanditIcon
    private let exclamationMarkIcon: ScanditIcon
    private var selectedBarcodeData: Set<String> = []

    override init() {
        highlightBrush = Brush(
            fill: .scanditCyan,
            stroke: .clear,
            strokeWidth: 0.0
        )

        let builder = ScanditIconBuilder()
            .withIconColor(.black)
            .withBackgroundShape(.circle)
            .withBackgroundStrokeColor(.black)
        checkmarkIcon =
            builder
            .withIcon(.checkmark)
            .build()
        exclamationMarkIcon =
            builder
            .withIcon(.exclamationMark)
            .build()
    }

    func apply(to barcodeArView: BarcodeArView) {
        barcodeArView.highlightProvider = self
        barcodeArView.annotationProvider = self
        barcodeArView.uiDelegate = nil
    }

    private func updateStyle(for annotation: BarcodeArInfoAnnotation) {
        guard let data = annotation.barcode.data else { return }
        if selectedBarcodeData.contains(data) {
            annotation.header?.backgroundColor = .scanditYellow
            annotation.header?.icon = exclamationMarkIcon
        } else {
            annotation.header?.backgroundColor = .scanditCyan
            annotation.header?.icon = checkmarkIcon
        }
    }
}

extension InfoAnnotationsConfigurationHandler: BarcodeArHighlightProvider {
    func highlight(for barcode: Barcode) async -> (any UIView & BarcodeArHighlight)? {
        let highlight = BarcodeArCircleHighlight(barcode: barcode, preset: .dot)
        highlight.brush = highlightBrush
        return highlight
    }
}

extension InfoAnnotationsConfigurationHandler: BarcodeArAnnotationProvider {
    private func farAwayAnnotationFor(barcode: Barcode) -> BarcodeArInfoAnnotation {
        let body = BarcodeArInfoAnnotationBodyComponent()
        body.text = "Body text"

        let annotation = BarcodeArInfoAnnotation(barcode: barcode)
        annotation.width = .medium
        annotation.body = [body]
        return annotation
    }

    private func closeUpAnnotationFor(barcode: Barcode) -> BarcodeArInfoAnnotation {
        // Body
        let body1 = BarcodeArInfoAnnotationBodyComponent()
        body1.text = "This is text in a large container.\nIt can have multiple lines"
        body1.textAlignment = .left

        let body2 = BarcodeArInfoAnnotationBodyComponent()
        body2.leftIcon = checkmarkIcon
        body2.text = "Point"
        body2.textAlignment = .left

        let body3 = BarcodeArInfoAnnotationBodyComponent()
        body3.leftIcon = checkmarkIcon
        body3.text = "Point"
        body3.textAlignment = .left

        // Header
        let header = BarcodeArInfoAnnotationHeader()
        header.icon = checkmarkIcon
        header.text = "Header"

        // Footer
        let footer = BarcodeArInfoAnnotationFooter()
        footer.text = "Tap to change color"

        let annotation = BarcodeArInfoAnnotation(barcode: barcode)
        annotation.width = .large
        annotation.body = [body1, body2, body3]
        annotation.header = header
        annotation.footer = footer
        annotation.isEntireAnnotationTappable = true
        annotation.delegate = self
        updateStyle(for: annotation)

        return annotation
    }

    func annotation(for barcode: Barcode) async -> (any UIView & BarcodeArAnnotation)? {
        let farAwayAnnotation = farAwayAnnotationFor(barcode: barcode)
        let closeUpAnnotation = closeUpAnnotationFor(barcode: barcode)
        return BarcodeArResponsiveAnnotation(
            barcode: barcode,
            closeUp: closeUpAnnotation,
            farAway: farAwayAnnotation
        )
    }
}

extension InfoAnnotationsConfigurationHandler: BarcodeArInfoAnnotationDelegate {
    func barcodeArInfoAnnotationDidTap(_ annotation: BarcodeArInfoAnnotation) {
        guard let data = annotation.barcode.data else { return }
        if !selectedBarcodeData.contains(data) {
            selectedBarcodeData.insert(data)
        } else {
            selectedBarcodeData.remove(data)
        }
        updateStyle(for: annotation)
    }
}

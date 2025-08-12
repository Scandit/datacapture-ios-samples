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

class HighlightsConfigurationHandler: NSObject, ConfigurationHandler {
    private let normalBrush: Brush
    private let normalIcon: ScanditIcon?
    private let selectedBrush: Brush
    private let selectedIcon: ScanditIcon?
    private var selectedBarcodeData: Set<String> = []

    override init() {
        normalBrush = Brush(
            fill: .scanditCyan.withAlphaComponent(0.4),
            stroke: .scanditCyan,
            strokeWidth: 2.0
        )
        normalIcon = nil
        selectedBrush = Brush(
            fill: .scanditDarkBlue.withAlphaComponent(0.45),
            stroke: .scanditDarkBlue,
            strokeWidth: 2.0
        )
        selectedIcon = ScanditIconBuilder().withIcon(.checkmark).build()
    }

    func apply(to barcodeArView: BarcodeArView) {
        barcodeArView.highlightProvider = self
        barcodeArView.annotationProvider = nil
        barcodeArView.uiDelegate = self
    }

    private func updateStyle(for highlight: BarcodeArRectangleHighlight) {
        guard let data = highlight.barcode.data else { return }
        if selectedBarcodeData.contains(data) {
            highlight.brush = selectedBrush
            highlight.icon = selectedIcon
        } else {
            highlight.brush = normalBrush
            highlight.icon = normalIcon
        }
    }
}

extension HighlightsConfigurationHandler: BarcodeArHighlightProvider {
    func highlight(for barcode: Barcode) async -> (any UIView & BarcodeArHighlight)? {
        let highlight = BarcodeArRectangleHighlight(barcode: barcode)
        updateStyle(for: highlight)
        return highlight
    }
}

extension HighlightsConfigurationHandler: BarcodeArViewUIDelegate {
    func barcodeAr(
        _ barcodeAr: BarcodeAr,
        didTapHighlightFor barcode: Barcode,
        highlight: any UIView & BarcodeArHighlight
    ) {
        guard let highlight = highlight as? BarcodeArRectangleHighlight, let data = barcode.data else { return }
        if !selectedBarcodeData.contains(data) {
            selectedBarcodeData.insert(data)
        } else {
            selectedBarcodeData.remove(data)
        }
        updateStyle(for: highlight)
    }
}

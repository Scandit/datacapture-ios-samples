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

extension Brush {
    static let scanditTrackedBrush = Brush(fill: .clear, stroke: .scanditBlue, strokeWidth: 3)
    static let scanditAimedBrush = Brush(fill: .scanditBlue, stroke: .clear, strokeWidth: 3)
    static let scanditSelectingBrush = Brush(fill: UIColor.clear, stroke: .scanditBlue, strokeWidth: 3)
    static let scanditSelectedBrush = Brush(fill: UIColor.clear, stroke: .scanditBlue, strokeWidth: 3)

    open override var description: String {
        if strokeColor ~= .scanditBlue || fillColor ~= .scanditBlue {
            return "Blue"
        } else {
            return "Default"
        }
    }
}

private struct ColorWrapper: CustomStringConvertible {
    let uicolor: UIColor

    var description: String {
        var alpha: CGFloat = 0.0
        uicolor.getWhite(nil, alpha: &alpha)
        if alpha == 0 {
            return "Transparent"
        }
        // For simplicity, let's ignore the alpha.
        switch uicolor.withAlphaComponent(1) {
        case .scanditBlue:
            return "Blue"
        case .black:
            return "Default"
        default:
            fatalError("Unhandled color")
        }
    }
}

class OverlayDataSource: DataSource {

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        [styles, brushes, frozenBackgroundColor, hints]
    }()

    lazy var styles: Section = {
        Section(rows: [
            Row.choice(title: "Style",
                       options: BarcodeSelectionBasicOverlayStyle.allCases,
                       getValue: { SettingsManager.current.overlayStyle },
                       didChangeValue: { SettingsManager.current.overlayStyle = $0 },
                       dataSourceDelegate: self.delegate)
        ])
    }()

    lazy var brushes: Section = {
        let style = SettingsManager.current.overlayStyle
        let trackedBrushes = [
            BarcodeSelectionBasicOverlay.defaultTrackedBrush(forStyle: style),
            Brush.scanditTrackedBrush
        ]
        let aimedBrushes = [
            BarcodeSelectionBasicOverlay.defaultAimedBrush(forStyle: style),
            Brush.scanditAimedBrush
        ]
        let selectingBrushes = [
            BarcodeSelectionBasicOverlay.defaultSelectingBrush(forStyle: style),
            Brush.scanditSelectingBrush
        ]
        let selectedBrushes = [
            BarcodeSelectionBasicOverlay.defaultSelectedBrush(forStyle: style),
            Brush.scanditSelectedBrush
        ]
        return Section(rows: [
            Row.choice(title: "Tracked Brush",
                       options: trackedBrushes,
                       getValue: { SettingsManager.current.trackedBrush },
                       didChangeValue: { SettingsManager.current.trackedBrush = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Aimed Brush",
                       options: aimedBrushes,
                       getValue: { SettingsManager.current.aimedBrush },
                       didChangeValue: { SettingsManager.current.aimedBrush = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Selecting Brush",
                       options: selectingBrushes,
                       getValue: { SettingsManager.current.selectingBrush },
                       didChangeValue: { SettingsManager.current.selectingBrush = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Selected Brush",
                       options: selectedBrushes,
                       getValue: { SettingsManager.current.selectedBrush },
                       didChangeValue: { SettingsManager.current.selectedBrush = $0 },
                       dataSourceDelegate: self.delegate)
        ])
    }()

    private static let backgroundColors = [
        ColorWrapper(uicolor: .black),
        ColorWrapper(uicolor: .clear),
        ColorWrapper(uicolor: .scanditBlue.withAlphaComponent(0.5))
    ]
    lazy var frozenBackgroundColor: Section = {
        Section(rows: [
            Row.choice(title: "Frozen Background Color",
                       options: Self.backgroundColors,
                       getValue: { ColorWrapper(uicolor: SettingsManager.current.frozenBackgroundColor) },
                       didChangeValue: { SettingsManager.current.frozenBackgroundColor = $0.uicolor },
                       dataSourceDelegate: self.delegate)
        ])
    }()

    lazy var hints: Section = {
        Section(rows: [
            Row(title: "Should Show Hints",
                kind: .switch,
                getValue: { SettingsManager.current.shouldShowHints },
                didChangeValue: { value in SettingsManager.current.shouldShowHints = value })])
    }()
}

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
    enum Style: CaseIterable, CustomStringConvertible {
        case `default`
        case blue

        var description: String {
            switch self {
            case .default:
                return "Default"
            case .blue:
                return "Blue"
            }
        }
    }

    private static let scanditFilledBrush = Brush(fill: .scanditBlue, stroke: .clear, strokeWidth: 0)
    private static let scanditUnfilledBrush = Brush(fill: .clear, stroke: .scanditBlue, strokeWidth: 3)

    static func scanditTrackedBrush(for overlayStyle: BarcodeSelectionBasicOverlayStyle) -> Brush {
        switch overlayStyle {
        case .frame:
            return scanditUnfilledBrush
        case .dot:
            return scanditFilledBrush
        }
    }

    static func scanditAimedBrush(for overlayStyle: BarcodeSelectionBasicOverlayStyle) -> Brush {
        switch overlayStyle {
        case .frame:
            return scanditFilledBrush
        case .dot:
            return scanditFilledBrush
        }
    }

    static func scanditSelectingBrush(for overlayStyle: BarcodeSelectionBasicOverlayStyle) -> Brush {
        switch overlayStyle {
        case .frame:
            return scanditUnfilledBrush
        case .dot:
            return scanditFilledBrush
        }
    }

    static func scanditSelectedBrush(for overlayStyle: BarcodeSelectionBasicOverlayStyle) -> Brush {
        switch overlayStyle {
        case .frame:
            return scanditUnfilledBrush
        case .dot:
            return scanditFilledBrush
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
        return Section(rows: [
            Row.choice(title: "Tracked Brush",
                       options: Brush.Style.allCases,
                       getValue: { SettingsManager.current.trackedBrushStyle },
                       didChangeValue: { SettingsManager.current.trackedBrushStyle = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Aimed Brush",
                       options: Brush.Style.allCases,
                       getValue: { SettingsManager.current.aimedBrushStyle },
                       didChangeValue: { SettingsManager.current.aimedBrushStyle = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Selecting Brush",
                       options: Brush.Style.allCases,
                       getValue: { SettingsManager.current.selectingBrushStyle },
                       didChangeValue: { SettingsManager.current.selectingBrushStyle = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Selected Brush",
                       options: Brush.Style.allCases,
                       getValue: { SettingsManager.current.selectedBrushStyle },
                       didChangeValue: { SettingsManager.current.selectedBrushStyle = $0 },
                       dataSourceDelegate: self.delegate)
        ])
    }()

    private static let backgroundColors = [
        ColorWrapper(uicolor: .black.withAlphaComponent(0.5)),
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

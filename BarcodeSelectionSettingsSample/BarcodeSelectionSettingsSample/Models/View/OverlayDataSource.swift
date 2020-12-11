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
    static let cyanTrackedBrush = Brush(fill: .clear, stroke: .cyan, strokeWidth: 3)
    static let cyanAimedBrush = Brush(fill: .cyan, stroke: .clear, strokeWidth: 3)
    static let cyanSelectingBrush = Brush(fill: UIColor.clear, stroke: .cyan, strokeWidth: 3)
    static let cyanSelectedBrush = Brush(fill: UIColor.clear, stroke: .cyan, strokeWidth: 3)

    open override var description: String {
        if strokeColor == .cyan || fillColor == .cyan {
            return "Cyan"
        } else {
            return "Default"
        }
    }
}

class OverlayDataSource: DataSource {

    static let trackedBrushes = [BarcodeSelectionBasicOverlay.defaultTrackedBrush, Brush.cyanTrackedBrush]
    static let aimedBrushes = [BarcodeSelectionBasicOverlay.defaultAimedBrush, Brush.cyanAimedBrush]
    static let selectingBrushes = [BarcodeSelectionBasicOverlay.defaultSelectingBrush, Brush.cyanSelectingBrush]
    static let selectedBrushes = [BarcodeSelectionBasicOverlay.defaultSelectedBrush, Brush.cyanSelectedBrush]

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        return [brushes, hints]
    }()

    lazy var brushes: Section = {
        return Section(rows: [
            Row.choice(title: "Tracked Brush",
                       options: OverlayDataSource.trackedBrushes,
                       getValue: { SettingsManager.current.trackedBrush },
                       didChangeValue: { SettingsManager.current.trackedBrush = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Aimed Brush",
                       options: OverlayDataSource.aimedBrushes,
                       getValue: { SettingsManager.current.aimedBrush },
                       didChangeValue: { SettingsManager.current.aimedBrush = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Selecting Brush",
                       options: OverlayDataSource.selectingBrushes,
                       getValue: { SettingsManager.current.selectingBrush },
                       didChangeValue: { SettingsManager.current.selectingBrush = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Selected Brush",
                       options: OverlayDataSource.selectedBrushes,
                       getValue: { SettingsManager.current.selectedBrush },
                       didChangeValue: { SettingsManager.current.selectedBrush = $0 },
                       dataSourceDelegate: self.delegate)
        ])
    }()

    lazy var hints: Section = {
        return Section(rows: [
            Row(title: "Should Show Hints",
                kind: .switch,
                getValue: { SettingsManager.current.shouldShowHints },
                didChangeValue: { value in SettingsManager.current.shouldShowHints = value })])
    }()
}

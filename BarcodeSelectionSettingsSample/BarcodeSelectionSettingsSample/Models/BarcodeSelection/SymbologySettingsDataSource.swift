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

class SymbologySettingsDataSource: DataSource {
    weak var delegate: DataSourceDelegate?

    var symbologySettings: SymbologySettings

    private var supportedExtensions: Set<String> {
        return symbologyDescription.supportedExtensions.filter({ !$0.hasSuffix("add_on") })
    }

    lazy var symbologyDescription: SymbologyDescription = {
        // Get the symbology description for the symbology
        SymbologyDescription(symbology: symbologySettings.symbology)
    }()

    init(delegate: DataSourceDelegate, symbologySettings: SymbologySettings) {
        self.delegate = delegate
        self.symbologySettings = symbologySettings
    }

    // MARK: - Sections

    var sections: [Section] {
        var sections = [general]

        if !symbologyDescription.activeSymbolCountRange.isFixed {
            sections.append(activeSymbolCountRange)
        }

        if !supportedExtensions.isEmpty {
            sections.append(extensions)
        }

        return sections
    }

    // MARK: - General Section

    lazy var general: Section = {
        var rows = [enabled]
        if symbologyDescription.isColorInvertible {
            rows.append(colorInverted)
        }
        return Section(rows: rows)
    }()

    lazy var enabled: Row = {
        Row(title: "Enabled",
            kind: .switch,
            getValue: { self.symbologySettings.isEnabled },
            didChangeValue: { self.symbologySettings.isEnabled = $0 })
    }()

    lazy var colorInverted: Row = {
        Row(title: "Color Inverted",
            kind: .switch,
            getValue: { self.symbologySettings.isColorInvertedEnabled },
            didChangeValue: { self.symbologySettings.isColorInvertedEnabled = $0 })
    }()

    // MARK: - Range Section

    var activeSymbolCountRange: Section {
        let currentMin = self.symbologySettings.activeSymbolCounts.minimum ??
            symbologyDescription.activeSymbolCountRange.minimum
        let currentMax = self.symbologySettings.activeSymbolCounts.maximum ??
            symbologyDescription.activeSymbolCountRange.maximum

        return Section(title: "Range", rows: [
            Row.choice(title: "Minimum",
                       options: Array(symbologyDescription.activeSymbolCountRange.minimum...currentMax),
                       getValue: { currentMin },
                       didChangeValue: { self.symbologySettings.activeSymbolCounts.minimum = $0 },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Maximum",
                       options: Array(currentMin...symbologyDescription.activeSymbolCountRange.maximum),
                       getValue: { currentMax },
                       didChangeValue: { self.symbologySettings.activeSymbolCounts.maximum = $0 },
                       dataSourceDelegate: self.delegate)
            ])
    }

    // MARK: - Extensions Section

    lazy var extensions: Section = {
        return Section(title: "Extensions",
                       rows: supportedExtensions.map({ supportedExtension in
                        Row.option(title: supportedExtension,
                                   getValue: { self.symbologySettings.enabledExtensions.contains(supportedExtension)},
                                   didChangeValue: { self.symbologySettings.set(extension: supportedExtension,
                                                                                enabled: $0) },
                                   dataSourceDelegate: self.delegate)
                       }))
    }()
}

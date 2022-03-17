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

import ScanditCaptureCore

private struct ColorWrapper: CustomStringConvertible {
    let uicolor: UIColor

    var description: String {
        // We need to compare the full alpha version.
        // dotColor will force some alpha so even if we pass a color with alpha = 1, it will get back with 0.7 alpha.
        switch uicolor.withAlphaComponent(1) {
        case .scanditBlue:
            return "Blue"
        default:
            return "White"
        }
    }
}

class ViewfinderDataSource: DataSource {
    private static let frameColors = [ColorWrapper(uicolor: .white), ColorWrapper(uicolor: .scanditBlue)]
    private static let dotColors = [ColorWrapper(uicolor: UIColor(white: 1, alpha: 0.7)),
                                    ColorWrapper(uicolor: .scanditBlue)]

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        return [colors]
    }()

    lazy var colors: Section = {
        return Section(rows: [
            Row.choice(title: "Frame Color",
                       options: Self.frameColors,
                       getValue: { ColorWrapper(uicolor: SettingsManager.current.frameColor) },
                       didChangeValue: { SettingsManager.current.frameColor = $0.uicolor },
                       dataSourceDelegate: self.delegate),
            Row.choice(title: "Dot Color",
                       options: Self.dotColors,
                       getValue: { ColorWrapper(uicolor: SettingsManager.current.dotColor) },
                       didChangeValue: { SettingsManager.current.dotColor = $0.uicolor },
                       dataSourceDelegate: self.delegate)
        ])
    }()
}

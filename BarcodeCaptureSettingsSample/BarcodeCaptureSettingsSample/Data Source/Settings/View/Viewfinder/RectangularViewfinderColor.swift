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

import UIKit

enum RectangularViewfinderColor: CaseIterable, CustomStringConvertible {
    case `default`, blue, black

    init(color: UIColor) {
        if color ~= .blue {
            self = .blue
        } else if color ~= .black {
            self = .black
        } else {
            self = .default
        }
    }

    var description: String {
        switch self {
        case .default: return "Default"
        case .blue: return "Blue"
        case .black: return "Black"
        }
    }

    var uiColor: UIColor {
        switch self {
        case .default: return SettingsManager.current.defaultRectangularViewfinderColor
        case .blue: return .blue
        case .black: return .black
        }
    }
}

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

struct Settings {
    enum Mode: Int {
        case gs1ai, lot

        /// The corresponding regular expression
        var regex: String {
            switch self {
            case .gs1ai:
                return #"((\\(\\d+\\)[\\da-zA-Z]+)+)"#
            case .lot:
                return "([A-Z0-9]{6,8})"
            }
        }
    }

    enum ScanPosition: Int {
        case top
        case center
        case bottom

        /// The scan area height
        var scanAreaHeight: CGFloat { return 0.1 }

        /// The scan area CGRect
        var scanArea: CGRect { return CGRect(x: 0, y: scanAreaY, width: 1, height: scanAreaHeight) }

        /// The scan area y coordinate
        var scanAreaY: CGFloat {
            switch self {
            case .top: return 0.25
            case .center: return 0.5
            case .bottom: return 0.75
            }
        }
    }

    let mode: Mode
    let scanPosition: ScanPosition
}

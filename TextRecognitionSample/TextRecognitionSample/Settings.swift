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
        case iban, gs1ai, price

        /// The corresponding regular expression
        var regex: String {
            switch self {
            case .iban:
                return #"([A-Z]{2}[A-Z0-9]{2}\\s*([A-Z0-9]{4}\\s*){4,8}([A-Z0-9]{1,4}))"#
            case .gs1ai:
                // swiftlint:disable:next line_length
                return #"((\\(01\\)[0-9]{13,14})(\\s*(\\(10\\)[0-9a-zA-Z]{1,20})|(\\(11\\)[0-9]{6})|(\\(17\\)[0-9]{6})|(\\(21\\)[0-9a-zA-Z]{1,20}))+)"#
            case .price:
                return #"((^|\\s+)[0-9]{1,}\\.[0-9]{1,}(\\s+|$))"#
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
            case .top: return 0.2
            case .center: return 0.45
            case .bottom: return 0.7
            }
        }
    }

    let mode: Mode
    let scanPosition: ScanPosition
}

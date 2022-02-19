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

extension Checksum: CaseIterable {
    public static var allCases: [Checksum] {
        return [.mod10, .mod11, .mod47, .mod103, .mod10AndMod10, .mod10AndMod11, .mod43, .mod16]
    }
}

extension Checksum: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mod10:
            return "Mod10"
        case .mod11:
            return "Mod11"
        case .mod47:
            return "Mod47"
        case .mod103:
            return "Mod103"
        case .mod10AndMod10:
            return "Mod10AndMod10"
        case .mod10AndMod11:
            return "Mod10AndMod11"
        case .mod43:
            return "Mod43"
        case .mod16:
            return "Mod16"
        default:
            return "Unknown"
        }
    }
}

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

extension VideoResolution: CaseIterable, CustomStringConvertible, CustomDebugStringConvertible {
    public typealias AllCases = [VideoResolution]
    public static var allCases: AllCases {
        return [.hd, .fullHD, .uhd4k, .auto]
    }

    public var description: String {
        switch self {
        case .hd:
            return "HD"
        case .fullHD:
            return "Full HD"
        case .uhd4k:
            return "Ultra HD 4K"
        case .auto:
            return "Auto"
        }
    }

    public var debugDescription: String {
        return description.lowercased()
    }
}

//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
// See the License for the specific language governing permissions and
// limitations under the License.
//

import ScanditIdCapture

extension CapturedSides: CustomStringConvertible, CaseIterable {
    public var description: String {
        switch self {
        case .frontOnly:
            return "Front Only"
        case .frontAndBack:
            return "Front & Back"
        }
    }

    public static var allCases: [CapturedSides] {
        return [.frontOnly, .frontAndBack]
    }
}

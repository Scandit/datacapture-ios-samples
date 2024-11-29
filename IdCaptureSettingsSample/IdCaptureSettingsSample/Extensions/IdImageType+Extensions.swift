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

extension IdImageType: CustomStringConvertible, CaseIterable {
    public var description: String {
        switch self {
        case .face:
            return "Face"
        case .croppedDocument:
            return "Cropped Document"
        case .frame:
            return "Frame"
        }
    }

    public static var allCases: [IdImageType] {
        return [.face, .croppedDocument, .frame]
    }
}

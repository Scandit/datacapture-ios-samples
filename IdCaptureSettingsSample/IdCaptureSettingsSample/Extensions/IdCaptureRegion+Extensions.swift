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

extension [IdCaptureRegion] {
    public var humanSorted: [IdCaptureRegion] {
        var sorted = self.sorted { $0.description < $1.description }
        if let index = sorted.firstIndex(of: .euAndSchengen) {
            sorted.insert(sorted.remove(at: index), at: sorted.startIndex)
        }
        if let index = sorted.firstIndex(of: .any) {
            sorted.insert(sorted.remove(at: index), at: sorted.startIndex)
        }
        return sorted
    }

    public var supportingText: String {
        if self.isEmpty {
            return "None"
        }
        if self.contains(.any) {
            return IdCaptureRegion.any.description
        }
        return self.map { $0.description }.joined(separator: ", ")
    }
}

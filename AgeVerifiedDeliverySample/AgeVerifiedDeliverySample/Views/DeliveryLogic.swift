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

import Foundation
import ScanditIdCapture

struct DeliveryLogic {
    enum State {
        case idRequired
        case underage
        case expired
        case timeout
        case idRejected
        case success
    }

    static func stateFor(_ capturedId: CapturedId) -> State {
        if capturedId.dateOfBirth?.localDate == nil {
            return .idRejected
        }
        return .success
    }
}

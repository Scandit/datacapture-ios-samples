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
        case timeout(final: Bool)
        case idRejected
        case success
    }

    static private func isDateExpired(_ date: Date) -> Bool {
        return date < Date.today.endOfDay
    }

    static private func isDocumentExpired(_ capturedId: CapturedId) -> Bool {
        if let number = capturedId.isExpired {
            return number.boolValue
        }
        return false
    }

    static private func isDateUnderage(_ date: Date) -> Bool {
        return date.yearsSince(Date.today) < 21
    }

    static func stateFor(_ capturedId: CapturedId) -> State {
        guard let dateOfBirth = capturedId.dateOfBirth?.localDate else { return .idRejected }
        guard !isDocumentExpired(capturedId) else { return .expired }
        guard !isDateUnderage(dateOfBirth) else { return .underage }
        return .success
    }

    static func stateFor(expirationDate: Date, birthDate: Date) -> State {
        guard !isDateExpired(expirationDate) else { return .expired }
        guard !isDateUnderage(birthDate) else { return .underage }
        return .success
    }
}

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

import Foundation
import ScanditIdCapture

enum DocumentType: String, CaseIterable {
    case drivingLicense = "Driver's License"
    case passport = "Passport"
    case militaryId = "Military ID"

    static func documentTypeFor(_ capturedId: CapturedId) -> DocumentType? {
        switch capturedId.documentType {
        case .drivingLicense: return .drivingLicense
        case .passport: return .passport
        case .militaryId: return .militaryId
        default: return nil
        }
    }
}

struct DeliveryLogic {
    enum State {
        case underage
        case expired(String)
        case success
    }

    static private func isDateExpired(_ date: Date) -> Bool {
        return date < Date.today.endOfDay
    }

    static private func isDocumentExpired(_ capturedId: CapturedId) -> Bool {
        guard let dateOfExpiry = capturedId.dateOfExpiry?.date else {
            return capturedId.documentType != .militaryId
        }

        return isDateExpired(dateOfExpiry)
    }

    static private func isDateUnderage(_ date: Date) -> Bool {
        return date.yearsSince(Date.today) < 21
    }

    static private func isDeliveryUnderage(_ capturedId: CapturedId) -> Bool {
        guard let dateOfBirth = capturedId.dateOfBirth?.date else { return false }
        return isDateUnderage(dateOfBirth)
    }

    static func stateFor(_ capturedId: CapturedId) -> State {
        guard !isDocumentExpired(capturedId) else {
            let documentType = DocumentType.documentTypeFor(capturedId)
            let documentTypeString = documentType?.rawValue ?? "Unknown"
            return .expired(documentTypeString)
        }

        guard !isDeliveryUnderage(capturedId) else { return .underage }

        return .success
    }

    static func stateFor(expirationDate: Date, birthDate: Date, documentType: String) -> State {
        guard !isDateExpired(expirationDate) else { return .expired(documentType) }
        guard !isDateUnderage(birthDate) else { return .underage }
        return .success
    }
}

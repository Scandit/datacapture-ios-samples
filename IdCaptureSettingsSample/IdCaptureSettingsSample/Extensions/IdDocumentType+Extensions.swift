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

import ScanditIdCapture

extension IdDocumentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .idCardVIZ:
            return "ID Card VIZ"
        case .idCardMRZ:
            return "ID Card MRZ"
        case .passportMRZ:
            return "Passport MRZ"
        case .swissDLMRZ:
            return "Swiss DL MRZ"
        case .aamvaBarcode:
            return "DL Aamva Barcode"
        case .dlVIZ:
            return "DL VIZ"
        case .ususIdBarcode:
            return "US US ID Barcode"
        case .visaMRZ:
            return "Visa MRZ"
        case .argentinaIdBarcode:
            return "Argentina ID Barcode"
        case .colombiaIdBarcode:
            return "Colombia ID Barcode"
        case .southAfricaDLBarcode:
            return "South Africa DL Barcode"
        case .southAfricaIdBarcode:
            return "South Africa ID Barcode"
        default:
            fatalError("Unknown case \(self)")
        }
    }
}

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

extension CapturedResultType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mrzResult:
            return "MRZ Result"
        case .aamvaBarcodeResult:
            return "Aamva Barcode Result"
        case .usUniformedServicesBarcodeResult:
            return "US Uniformed Services Barcode Result"
        case .vizResult:
            return "VIZ Result"
        case .colombiaDlBarcodeResult:
            return "Colombia DL Barcode Result"
        case .colombiaIdBarcodeResult:
            return "Colombia ID Barcode Result"
        case .argentinaIdBarcodeResult:
            return "Argentina ID Barcode Result"
        case .southAfricaDLBarcodeResult:
            return "South Africa DL Barcode Result"
        case .southAfricaIdBarcodeResult:
            return "South Africa Id Barcode Result"
        case .chinaMainlandTravelPermitMrzResult:
            return "China Mainland Travel Permit MRZ Result"
        case .chinaExitEntryPermitMrzResult:
            return "China Exit-Entry Permit MRZ Result"
        case .chinaOneWayPermitBackMrzResult:
            return "China One-Way Permit MRZ Back Result"
        case .chinaOneWayPermitFrontMrzResult:
            return "China One-Way Permit MRZ Front Result"
        case .apecBusinessTravelCardMrzResult:
            return "APEC Business Travel Card"
        case .usVisaVizResult:
            return "US Visa VIZ"
        default:
            return "No Result"
        }
    }
}

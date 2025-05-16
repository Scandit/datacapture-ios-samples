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

extension [IdCaptureDocument] {
    func contains(documentType: IdCaptureDocumentType) -> Bool {
        self.first { $0.documentType == documentType } != nil
    }
}

extension IdCaptureDocument {
    var subtypeDescription: String {
        if let document = self as? RegionSpecific {
            return document.subtype.description
        }
        return "None"
    }
}

extension IdCaptureDocumentType {
    public func document(region: IdCaptureRegion) -> IdCaptureDocument {
        switch self {
        case .idCard: return IdCard(region: region)
        case .driverLicense: return DriverLicense(region: region)
        case .passport: return Passport(region: region)
        case .visaIcao: return VisaIcao(region: region)
        case .residencePermit: return ResidencePermit(region: region)
        case .healthInsuranceCard: return HealthInsuranceCard(region: region)
        case .regionSpecific: fatalError("regionSpecific not supported by this extension")
        @unknown default: fatalError("Unknown document \(self.rawValue)")
        }
    }
}

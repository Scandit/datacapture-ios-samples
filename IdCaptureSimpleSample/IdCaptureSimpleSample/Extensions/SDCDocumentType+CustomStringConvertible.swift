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

extension DocumentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "None"
        case .consularId:
            return "Consular Id"
        case .drivingLicense:
            return "Driving License"
        case .drivingLicensePublicServicesCard:
            return "Driving License Public Services Card"
        case .employmentPass:
            return "Employment Pass"
        case .finCard:
            return "Fin Card"
        case .id:
            return "Id"
        case .multipurposeId:
            return "Multipurpose Id"
        case .myKAD:
            return "My KAD"
        case .myKID:
            return "My KID"
        case .myPR:
            return "My PR"
        case .myTentera:
            return "My Tentera"
        case .panCard:
            return "Pan Card"
        case .professionalId:
            return "Professional Id"
        case .publicServicesCard:
            return "Public Services Card"
        case .residencePermit:
            return "Residence Permit"
        case .residentId:
            return "Resident Id"
        case .temporaryResidencePermit:
            return "Temporary Residence Permit"
        case .voterId:
            return "Voter Id"
        case .workPermit:
            return "Work Permit"
        case .iKAD:
            return "iKAD"
        case .militaryId:
            return "Military Id"
        case .myKAS:
            return "My KAS"
        case .socialSecurityCard:
            return "Social Security Card"
        case .healthInsuranceCard:
            return "Health Insurance Card"
        case .passport:
            return "Passport"
        case .visa:
            return "Visa"
        case .sPass:
            return "sPass"
        }
    }
}

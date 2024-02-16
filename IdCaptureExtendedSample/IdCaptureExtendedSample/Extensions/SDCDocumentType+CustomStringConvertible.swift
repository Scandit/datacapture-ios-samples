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
        case .diplomaticPassport:
            return "Diplomatic Passport"
        case .servicePassport:
            return "Service Passport"
        case .temporaryPassport:
            return "Temporary Passport"
        case .visa:
            return "Visa"
        case .sPass:
            return "sPass"
        case .addressCard:
            return "Address Card"
        case .alienId:
            return "Alien ID"
        case .alienPassport:
            return "Alien Passport"
        case .greenCard:
            return "Green Card"
        case .minorsId:
            return "Minors ID"
        case .postalId:
            return "Postal ID"
        case .professionalDL:
            return "Professional DL"
        case .taxId:
            return "Tax ID"
        case .weaponPermit:
            return "Weapon Permit"
        case .borderCrossingCard:
            return "Border Crossing Card"
        case .driverCard:
            return "Driver Card"
        case .globalEntryCard:
            return "Global Entry Card"
        case .myPolis:
            return "MyPolis"
        case .nexusCard:
            return "Nesux Card"
        case .passportCard:
            return "Passport Card"
        case .proofOfAgeCard:
            return "Proof of age Card"
        case .refugeeId:
            return "Refugee ID"
        case .tribalId:
            return "Tribal ID"
        case .veteranId:
            return "Veteran ID"
        case .citizenshipCertificate:
            return "Citizenship Certificate"
        case .myNumberCard:
            return "My Number Card"
        case .minorsPassport:
            return "Minors Passport"
        case .minorsPublicServicesCard:
            return "Minors Public Services Card"
        case .apecBusinessTravelCard:
            return "Apec Business Travel Card"
        case .drivingPrivilegeCard:
            return "Driving Privilege Card"
        case .asylumRequest:
            return "Asylum Request"
        case .driverQualificationCard:
            return "Driver Qualification Card"
        case .provisionalDl:
            return "Provisional DL"
        case .refugeePassport:
            return "Refugee Passport"
        case .specialId:
            return "Special ID"
        case .uniformedServicesId:
            return "Uniformed Services ID"
        case .immigrantVisa:
            return "Immigrant Visa"
        case .consularVoterId:
            return "Consular Voter ID"
        case .twicCard:
            return "TWIC Card"
        }
    }
}

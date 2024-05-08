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
import UIKit

class USUniformedServicesResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        guard let usUniformedServicesResult = capturedId.usUniformedServicesBarcodeResult else {
            fatalError("Unexpected null USUniformedServicesResult")
        }
        rows  = [
            SimpleTextCellProvider(value: "\(usUniformedServicesResult.version)", title: "Version"),
            SimpleTextCellProvider(value: usUniformedServicesResult.sponsorFlag, title: "Sponsor Flag"),
            SimpleTextCellProvider(value: "\(usUniformedServicesResult.personDesignatorDocument)",
                                   title: "Person Designator Document"),
            SimpleTextCellProvider(value: "\(usUniformedServicesResult.familySequenceNumber)",
                                   title: "Family Sequence Number"),
            SimpleTextCellProvider(value: "\(usUniformedServicesResult.deersDependentSuffixCode)",
                                   title: "Deers Dependent Suffic Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.deersDependentSuffixDescription,
                                   title: "Deers Dependent Suffix Description"),
            SimpleTextCellProvider(value: "\(usUniformedServicesResult.height)",
                                   title: "Height"),
            SimpleTextCellProvider(value: "\(usUniformedServicesResult.weight)",
                                   title: "Weight"),
            SimpleTextCellProvider(value: usUniformedServicesResult.hairColor,
                                   title: "Hair Color"),
            SimpleTextCellProvider(value: usUniformedServicesResult.eyeColor,
                                   title: "Eye Color"),
            SimpleTextCellProvider(value: usUniformedServicesResult.directCareFlagCode,
                                   title: "Direct Care Flag Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.directCareFlagDescription,
                                   title: "Direct Care Flag Descriptions"),
            SimpleTextCellProvider(value: usUniformedServicesResult.civilianHealthCareFlagCode,
                                   title: "Civilian Health Care Flag Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.civilianHealthCareFlagDescription,
                                   title: "Civilian Health Care Flag Description"),
            SimpleTextCellProvider(value: usUniformedServicesResult.commissaryFlagCode,
                                   title: "Commissary Flag Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.commissaryFlagDescription,
                                   title: "Commissary Flag Description"),
            SimpleTextCellProvider(value: usUniformedServicesResult.mwrFlagCode,
                                   title: "MWR Flag Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.mwrFlagDescription,
                                   title: "MWR Flag Description"),
            SimpleTextCellProvider(value: usUniformedServicesResult.exchangeFlagCode,
                                   title: "Exchange Flag Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.exchangeFlagDescription,
                                   title: "Exchange Flag Description"),
            SimpleTextCellProvider(value: usUniformedServicesResult.champusEffectiveDate.valueOrNil,
                                   title: "Champus Effective Date"),
            SimpleTextCellProvider(value: usUniformedServicesResult.champusExpiryDate.valueOrNil,
                                   title: "Champus Expiry Date"),
            SimpleTextCellProvider(value: usUniformedServicesResult.formNumber,
                                   title: "Form Number"),
            SimpleTextCellProvider(value: usUniformedServicesResult.securityCode,
                                   title: "Security Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.serviceCode,
                                   title: "Service Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.statusCode,
                                   title: "Status Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.statusCodeDescription,
                                   title: "Status Code Description"),
            SimpleTextCellProvider(value: usUniformedServicesResult.branchOfService,
                                   title: "Branch of Service"),
            SimpleTextCellProvider(value: usUniformedServicesResult.rank,
                                   title: "Rank"),
            SimpleTextCellProvider(value: usUniformedServicesResult.payGrade.valueOrNil,
                                   title: "Pay Grade"),
            SimpleTextCellProvider(value: usUniformedServicesResult.sponsorName.valueOrNil,
                                   title: "Sponsor Name"),
            SimpleTextCellProvider(value: usUniformedServicesResult.sponsorPersonDesignatorIdentifier.valueOrNil,
                                   title: "Sponsor Person Designator Identifier"),
            SimpleTextCellProvider(value: usUniformedServicesResult.relationshipCode.valueOrNil,
                                   title: "Relationship Code"),
            SimpleTextCellProvider(value: usUniformedServicesResult.relationshipDescription.valueOrNil,
                                   title: "Relationship Description"),
            SimpleTextCellProvider(value: usUniformedServicesResult.genevaConventionCategory.valueOrNil,
                                   title: "Geneva Convention Category"),
            SimpleTextCellProvider(value: usUniformedServicesResult.bloodType.valueOrNil,
                                   title: "Blood Type")
        ]
    }
}

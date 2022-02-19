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

import UIKit
import ScanditIdCapture

class SouthAfricaDLResultPresenter: ResultPresenter {

    let rows: [CellProvider]

    required init(capturedId: CapturedId) {
        assert(capturedId.capturedResultTypes.contains(.southAfricaDLBarcodeResult))
        guard let southAfricaDLBarcodeResult = capturedId.southAfricaDLBarcodeResult else {
            fatalError("Unexpected null SouthAfricaDLBarcodeResult")
        }
        let commonRows = Self.getCommonRows(for: capturedId)
        var southAfricaDLRows: [CellProvider] = [
            SimpleTextCellProvider(value: "\(southAfricaDLBarcodeResult.version)", title: "Version"),
            SimpleTextCellProvider(value: southAfricaDLBarcodeResult.licenseCountryOfIssue,
                                   title: "License Country of Issue"),
            SimpleTextCellProvider(value: southAfricaDLBarcodeResult.personalIdNumber,
                                   title: "Personal Id Number"),
            SimpleTextCellProvider(value: southAfricaDLBarcodeResult.personalIdNumberType,
                                   title: "Personal Id Number Type"),
            SimpleTextCellProvider(value: "\(southAfricaDLBarcodeResult.documentCopy)",
                                   title: "Document Copy"),
            SimpleTextCellProvider(value: southAfricaDLBarcodeResult
                                    .driverRestrictionCodes
                                    .map(String.init)
                                    .joined(separator: " "),
                                   title: "Driver Restriction Codes")
        ]
        if let professionalDrivingPermit = southAfricaDLBarcodeResult.professionalDrivingPermit {
            southAfricaDLRows.append(
                SimpleTextCellProvider(value: professionalDrivingPermit.codes.joined(separator: " "),
                                       title: "Professional Driving Permit - Codes"))
            southAfricaDLRows.append(
                SimpleTextCellProvider(value: professionalDrivingPermit.dateOfExpiry.description,
                                       title: "Professional Driving Permit - Date of Expiry"))
        }

        for vehicleRestriction in southAfricaDLBarcodeResult.vehicleRestrictions {
            southAfricaDLRows.append(
                SimpleTextCellProvider(value: vehicleRestriction.vehicleCode,
                                       title: "Vehicle Restriction - Vehicle Code"))
            southAfricaDLRows.append(
                SimpleTextCellProvider(value: vehicleRestriction.vehicleRestriction,
                                       title: "Vehicle Restriction - Vehicle Restriction"))
            southAfricaDLRows.append(
                SimpleTextCellProvider(value: vehicleRestriction.dateOfIssue.description,
                                       title: "Vehicle Restriction - Date of Issue"))

        }

        self.rows = commonRows + southAfricaDLRows
    }
}

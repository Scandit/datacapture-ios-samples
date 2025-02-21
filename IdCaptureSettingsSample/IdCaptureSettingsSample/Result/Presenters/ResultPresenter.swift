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

import UIKit
import ScanditIdCapture

protocol ResultPresenter {
    var rows: [CellProvider] { get }
    init(capturedId: CapturedId)
}

fileprivate extension ResultPresenter {
    static func getImageRows(for capturedId: CapturedId) -> [CellProvider] {
        return [
            ImageCellProvider(image: capturedId.images.face, title: "Face Image"),
            ImageCellProvider(image: capturedId.images.croppedDocument(for: .front), title: "Front Image"),
            ImageCellProvider(image: capturedId.images.croppedDocument(for: .back), title: "Back Image"),
            ImageCellProvider(image: capturedId.images.frame(for: .front), title: "Front Frame"),
            ImageCellProvider(image: capturedId.images.frame(for: .back), title: "Back Frame")
        ].filter { $0.image != nil }
    }

    static func getCommonRows(for capturedId: CapturedId) -> [CellProvider] {
        return
            [SimpleTextCellProvider(value: capturedId.document?.documentType.description ?? "<nil>",
                                    title: "Document Type"),
             SimpleTextCellProvider(value: capturedId.document?.subtypeDescription ?? "<nil>",
                                    title: "Subtype"),
             SimpleTextCellProvider(value: capturedId.firstName.valueOrNil, title: "First Name"),
             SimpleTextCellProvider(value: capturedId.lastName.valueOrNil, title: "Last Name"),
             SimpleTextCellProvider(value: capturedId.secondaryLastName.valueOrNil, title: "Secondary Last Name"),
             SimpleTextCellProvider(value: capturedId.fullName, title: "Full Name"),
             SimpleTextCellProvider(value: capturedId.sexType.description, title: "Sex"),
             SimpleTextCellProvider(value: capturedId.dateOfBirth.valueOrNil, title: "Date of Birth"),
             SimpleTextCellProvider(value: capturedId.age.valueOrNil, title: "Age"),
             SimpleTextCellProvider(value: capturedId.nationality.valueOrNil, title: "Nationality"),
             SimpleTextCellProvider(value: capturedId.address.valueOrNil, title: "Address"),
             SimpleTextCellProvider(value: capturedId.issuingCountryISO.valueOrNil, title: "Issuing Country ISO"),
             SimpleTextCellProvider(value: capturedId.issuingCountry.description, title: "Issuing Country"),
             SimpleTextCellProvider(value: capturedId.documentNumber.valueOrNil, title: "Document Number"),
             SimpleTextCellProvider(value: capturedId.documentAdditionalNumber.valueOrNil,
                                    title: "Document Additional Number"),
             SimpleTextCellProvider(value: capturedId.dateOfExpiry.valueOrNil, title: "Date of Expiry"),
             SimpleTextCellProvider(value: capturedId.isExpired.optionalBooleanRepresentation, title: "Is Expired"),
             SimpleTextCellProvider(value: capturedId.dateOfIssue.valueOrNil, title: "Date of Issue"),
             SimpleTextCellProvider(value: capturedId.usRealIdStatus.description,
                                    title: "US REAL ID Status")]
    }
}

struct CombinedResultPresenter: ResultPresenter {
    let rows: [CellProvider]

    init(capturedId: CapturedId) {
        rows = Self.getCommonRows(for: capturedId) + Self.getImageRows(for: capturedId)
    }

    init(capturedId: CapturedId, presenters: [ResultPresenter]) {
        rows = Self.getCommonRows(for: capturedId) + presenters.flatMap({$0.rows}) + Self.getImageRows(for: capturedId)
    }
}

struct ResultPresenterFactory {
    static func presenter(for capturedId: CapturedId) -> ResultPresenter {
        var presenters: [ResultPresenter] = []

        if capturedId.vizResult != nil {
            presenters.append(VizResultPresenter.self.init(capturedId: capturedId))
        }
        if capturedId.mrzResult != nil {
            presenters.append(MRZResultPresenter.self.init(capturedId: capturedId))
        }
        if capturedId.barcode != nil {
            presenters.append(BarcodeResultPresenter.self.init(capturedId: capturedId))
        }

        return CombinedResultPresenter(capturedId: capturedId, presenters: presenters)
    }
}

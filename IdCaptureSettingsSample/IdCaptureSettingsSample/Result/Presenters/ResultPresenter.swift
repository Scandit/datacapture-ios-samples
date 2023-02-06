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

import UIKit
import ScanditIdCapture

extension CapturedResultType: Hashable, CaseIterable {

    public static var allCases: [CapturedResultType] {
        return [
            .aamvaBarcodeResult,
            .argentinaIdBarcodeResult,
            .chinaMainlandTravelPermitMrzResult,
            .chinaExitEntryPermitMrzResult,
            .chinaOneWayPermitBackMrzResult,
            .chinaOneWayPermitFrontMrzResult,
            .colombiaIdBarcodeResult,
            .colombiaDlBarcodeResult,
            .mrzResult,
            .southAfricaDLBarcodeResult,
            .southAfricaIdBarcodeResult,
            .usUniformedServicesBarcodeResult,
            .vizResult
        ]
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }

    public var singleValues: [CapturedResultType] {
        return Self.allCases.filter({self.contains($0)})
    }
}

protocol ResultPresenter {
    var rows: [CellProvider] { get }
    init(capturedId: CapturedId)
}

fileprivate extension ResultPresenter {
    static func getCommonRows(for capturedId: CapturedId) -> [CellProvider] {
        return
            [SimpleTextCellProvider(value: capturedId.firstName.valueOrNil, title: "Name"),
             SimpleTextCellProvider(value: capturedId.lastName.valueOrNil, title: "Lastname"),
             SimpleTextCellProvider(value: capturedId.fullName, title: "Full Name"),
             SimpleTextCellProvider(value: capturedId.sex.valueOrNil, title: "Sex"),
             SimpleTextCellProvider(value: capturedId.age.valueOrNil, title: "Age"),
             SimpleTextCellProvider(value: capturedId.dateOfBirth.valueOrNil, title: "Date of Birth"),
             SimpleTextCellProvider(value: capturedId.nationality.valueOrNil, title: "Nationality"),
             SimpleTextCellProvider(value: capturedId.address.valueOrNil, title: "Address"),
             SimpleTextCellProvider(value: capturedId
                                        .capturedResultTypes
                                        .singleValues
                                        .map(\.description)
                                        .joined(separator: ","),
                                    title: "Captured Result Type"),
             SimpleTextCellProvider(value: capturedId.documentType.description, title: "Document Type"),
             SimpleTextCellProvider(value: capturedId.issuingCountryISO.valueOrNil, title: "Issuing Country ISO"),
             SimpleTextCellProvider(value: capturedId.issuingCountry.valueOrNil, title: "Issuing Country"),
             SimpleTextCellProvider(value: capturedId.documentNumber.valueOrNil, title: "Document Number"),
             SimpleTextCellProvider(value: capturedId.dateOfExpiry.valueOrNil, title: "Date of Expiry"),
             SimpleTextCellProvider(value: capturedId.isExpired.optionalBooleanRepresentation, title: "Is Expired"),
             SimpleTextCellProvider(value: capturedId.dateOfIssue.valueOrNil, title: "Date of Issue")]
    }
}

struct CombinedResultPresenter: ResultPresenter {
    let rows: [CellProvider]

    init(capturedId: CapturedId) {
        rows = Self.getCommonRows(for: capturedId)
    }

    init(capturedId: CapturedId, presenters: [ResultPresenter]) {
        rows = Self.getCommonRows(for: capturedId) + presenters.flatMap({$0.rows})
    }
}

struct ResultPresenterFactory {

    static var mappings: [CapturedResultType: ResultPresenter.Type] = {
        return [.aamvaBarcodeResult: AAMVABarcodeResultPresenter.self,
                .argentinaIdBarcodeResult: ArgentinaIdResultPresenter.self,
                .chinaMainlandTravelPermitMrzResult: ChinaMainlandTravelPermitMrzResultPresenter.self,
                .chinaExitEntryPermitMrzResult: ChinaExitEnterPermitMrzResultPresenter.self,
                .chinaOneWayPermitBackMrzResult: ChinaOneWayPermitBackMrzResultPresenter.self,
                .chinaOneWayPermitFrontMrzResult: ChinaOneWayPermitFrontMrzResultPresenter.self,
                .colombiaIdBarcodeResult: ColombiaIdBarcodeResultPresenter.self,
                .colombiaDlBarcodeResult: ColombiaDlBarcodeResultPresenter.self,
                .mrzResult: MRZResultPresenter.self,
                .southAfricaDLBarcodeResult: SouthAfricaDLResultPresenter.self,
                .southAfricaIdBarcodeResult: SouthAfricaIdResultPresenter.self,
                .usUniformedServicesBarcodeResult: USUniformedServicesResultPresenter.self,
                .vizResult: VizResultPresenter.self]
    }()

    static func presenter(for capturedId: CapturedId) -> ResultPresenter {
        let presenters = capturedId
            .capturedResultTypes
            .singleValues
            .compactMap({ mappings[$0] })
            .map { $0.init(capturedId: capturedId) }
        return CombinedResultPresenter(capturedId: capturedId, presenters: presenters)
    }
}

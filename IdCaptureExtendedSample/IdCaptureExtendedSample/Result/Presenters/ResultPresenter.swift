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
            .vizResult,
            .apecBusinessTravelCardMrzResult
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

extension ResultPresenter {
    static func getCommonRows(for capturedId: CapturedId) -> [CellProvider] {
        var cells = [CellProvider]()

        if !capturedId.fullName.isEmpty {
            cells.append(SimpleTextCellProvider(value: capturedId.fullName, title: "Full Name"))
        }
        if let dateOfBirth = capturedId.dateOfBirth {
            cells.append(SimpleTextCellProvider(value: dateOfBirth.description, title: "Date of Birth"))
        }
        if let dateOfExpiry = capturedId.dateOfExpiry {
            cells.append(SimpleTextCellProvider(value: dateOfExpiry.description, title: "Date of Expiry"))
        }
        if let documentNumber = capturedId.documentNumber {
            cells.append(SimpleTextCellProvider(value: documentNumber.description, title: "Document Number"))
        }
        if let nationality = capturedId.nationality {
            cells.append(SimpleTextCellProvider(value: nationality, title: "Nationality"))
        }
        return cells
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
        return [.vizResult: VizResultPresenter.self]
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

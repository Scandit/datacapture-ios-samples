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
import UIKit

protocol ResultPresenter {
    var rows: [CellProvider] { get }
    init(capturedId: CapturedId)
}

extension ResultPresenter {
    static func getCommonRows(for capturedId: CapturedId) -> [CellProvider] {
        var cells: [CellProvider] = []

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
        rows = Self.getCommonRows(for: capturedId) + presenters.flatMap({ $0.rows })
    }
}

struct ResultPresenterFactory {

    static func presenter(for capturedId: CapturedId) -> ResultPresenter {
        var presenters: [ResultPresenter] = []

        if capturedId.vizResult != nil {
            presenters.append(VizResultPresenter.self.init(capturedId: capturedId))
        }

        return CombinedResultPresenter(capturedId: capturedId, presenters: presenters)
    }
}

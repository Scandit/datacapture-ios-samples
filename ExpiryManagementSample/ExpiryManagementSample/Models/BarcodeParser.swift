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
import ScanditParser
import  ScanditBarcodeCapture
import ScanditCaptureCore

class BarcodeParser {
    private let parser: Parser

    init(context: DataCaptureContext) throws {
        parser = try Parser(context: context, format: .gs1AI)
    }

    func isItemExpired(barcodeData: String) -> Bool {
        do {
            let parsedData = try parser.parseString(barcodeData)
            guard let expiryDate = parsedData.fieldsByName["17"]?.parsed as? [String: AnyObject] else {
                return false
            }

            guard let year = expiryDate["year"] as? Int,
                  let month = expiryDate["month"] as? Int,
                  let day = expiryDate["day"] as? Int else {
                return false
            }

            let dateComponents = DateComponents(calendar: Calendar.current,
                                                timeZone: TimeZone.current,
                                                year: year,
                                                month: month,
                                                day: day)

            guard let date = dateComponents.date else {
                return false
            }
            return date.compare(Date()) == .orderedAscending
        } catch {
            return false
        }
    }
}

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

/// In-memory mapping from barcode string to expected price, loaded once at startup
/// from a CSV bundled with the app.
///
/// The CSV is a two-column file with no header:
///
///     7610061221066,4.95
///     7610300910133,11.52
///
/// To change the reference data, edit `barcode_price_database.csv` in the app bundle
/// and rebuild.
struct BarcodePriceDatabase {

    /// Lookup result for a scanned (barcode, price) pair.
    enum ValidationResult {
        /// Barcode found and the captured price equals the expected price.
        case correct
        /// Barcode found but the captured price differs from the expected price.
        case incorrect
        /// Barcode not present in the database.
        case unknown
    }

    private let expectedPriceByBarcode: [String: Decimal]

    init(expectedPriceByBarcode: [String: Decimal]) {
        self.expectedPriceByBarcode = expectedPriceByBarcode
    }

    /// Loads the database from a CSV file bundled with the app.
    /// Returns an empty database if the file is missing or unreadable.
    static func loadFromBundle(named name: String, fileExtension: String = "csv") -> BarcodePriceDatabase {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension),
            let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            print("[PriceCapture] Reference database \(name).\(fileExtension) not found in bundle.")
            return BarcodePriceDatabase(expectedPriceByBarcode: [:])
        }
        return BarcodePriceDatabase(expectedPriceByBarcode: parse(csv: contents))
    }

    /// Validates a scanned barcode against its captured price.
    func validate(barcode: String, capturedPrice: Decimal) -> ValidationResult {
        guard let expected = expectedPriceByBarcode[barcode] else { return .unknown }
        return expected == capturedPrice ? .correct : .incorrect
    }

    /// Parses CSV text into a barcode→price map. Lines that don't have a numeric
    /// price are skipped silently — this keeps the sample resilient to comments,
    /// blank lines or stray whitespace in the bundled file.
    static func parse(csv: String) -> [String: Decimal] {
        var result: [String: Decimal] = [:]
        for rawLine in csv.split(whereSeparator: { $0.isNewline }) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }
            let parts = line.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }
            let barcode = parts[0].trimmingCharacters(in: .whitespaces)
            let priceString = parts[1].trimmingCharacters(in: .whitespaces)
            guard !barcode.isEmpty,
                let price = Decimal(string: priceString, locale: Locale(identifier: "en_US_POSIX"))
            else {
                continue
            }
            result[barcode] = price
        }
        return result
    }
}

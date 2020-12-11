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

struct IbanValidator {
    static func validate(iban: String) -> Bool {
        let trimmedIban = iban.replacingOccurrences(of: " ", with: "")
        let index = trimmedIban.index(trimmedIban.startIndex, offsetBy: 4)
        let adjustedIban = trimmedIban[index...] + trimmedIban[..<index]
        var integerIban = ""
        for c in adjustedIban.utf8 {
            if c >= 48 && c <= 57 {
                integerIban.append(String(c - 48))
            } else if c >= 65 && c <= 90 {
                integerIban.append(String(c - 55))
            } else {
                // Reject the IBAN if the conversion to integers failed. This generally means that the
                // original character set was larger than just 0-9A-Z.
                return false
            }
        }
        let number = NSDecimalNumber(string: integerIban)
        return modulo(dividend: number, divisor: NSDecimalNumber(value: 97)) == 1
    }

    private static func modulo(dividend: NSDecimalNumber, divisor: NSDecimalNumber) -> Int {
        let behavior = NSDecimalNumberHandler(roundingMode: .down,
                                              scale: 0,
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        let quotient = dividend.dividing(by: divisor, withBehavior: behavior)
        let subtractAmount = quotient.multiplying(by: divisor)
        let remainder = dividend.subtracting(subtractAmount)
        return remainder.intValue
    }
}

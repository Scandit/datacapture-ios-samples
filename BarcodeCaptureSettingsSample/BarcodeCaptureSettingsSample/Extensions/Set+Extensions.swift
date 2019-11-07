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

/*
 * Helpers to easily set active symbol counts (SymbologySettings.activeSymbolCounts: Set<NSNumber>)
 *
 * This extension assumes that Set<NSNumber> contains all integers between the minimum and the maximum,
 * e.g. [2, 3, 4, 5], but not [2, 3, 5]
 */

extension Set where Element == NSNumber {
    var minimum: Int? {
        get {
            guard let min = self.min(by: { Float(truncating: $0) < Float(truncating: $1) }) else {
                return nil
            }
            return Int(truncating: min)
        }
        set {
            guard let newValue = newValue else {
                return
            }

            guard let minimum = minimum else {
                insert(newValue as NSNumber)
                return
            }

            guard newValue != minimum else {
                return
            }

            if newValue < minimum {
                formUnion(Array(newValue..<minimum) as [NSNumber])
            } else {
                subtract(Array(minimum..<newValue) as [NSNumber])
            }
        }
    }

    var maximum: Int? {
        get {
            guard let max = self.max(by: { Float(truncating: $0) < Float(truncating: $1) }) else {
                return nil
            }
            return Int(truncating: max)
        }
        set {
            guard let newValue = newValue else {
                return
            }

            guard let maximum = maximum else {
                insert(newValue as NSNumber)
                return
            }

            guard newValue != maximum else {
                return
            }

            if maximum < newValue {
                formUnion(Array(maximum...newValue) as [NSNumber])
            } else {
                subtract(Array((newValue + 1)...maximum) as [NSNumber])
            }
        }
    }
}

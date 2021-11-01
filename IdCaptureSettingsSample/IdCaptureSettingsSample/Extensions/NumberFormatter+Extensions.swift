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
import CoreGraphics

extension NumberFormatter {
    convenience init(maximumFractionDigits: Int) {
        self.init()
        self.numberStyle = .decimal
        self.maximumFractionDigits = maximumFractionDigits
    }

    func string(from value: Float) -> String? {
        return string(from: NSNumber(value: value))
    }

    func string(from value: CGFloat) -> String? {
        return string(from: NSNumber(value: value.native))
    }
}

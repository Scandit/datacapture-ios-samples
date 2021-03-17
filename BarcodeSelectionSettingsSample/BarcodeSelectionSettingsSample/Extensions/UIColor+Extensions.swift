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

extension UIColor {
    public static func ~= (lhs: UIColor, rhs: UIColor) -> Bool {
        let tolerance: CGFloat = 0.001
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        lhs.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        rhs.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return abs(red1 - red2) < tolerance
            && abs(green1 - green2) < tolerance
            && abs(blue1 - blue2) < tolerance
            && abs(alpha1 - alpha2) < tolerance
    }

    class var scanditBlue: UIColor {
        return UIColor(red: 46 / 255, green: 193 / 255, blue: 206 / 255, alpha: 1)
    }
}

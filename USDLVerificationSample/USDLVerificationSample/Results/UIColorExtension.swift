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

extension UIColor {
    func image() -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(self.cgColor)
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

    static var brand: UIColor {
        return UIColor(red: 57 / 255, green: 193 / 255, blue: 204 / 255, alpha: 1)
    }

    static var greenBackground: UIColor {
        return UIColor(red: 212 / 255, green: 246 / 255, blue: 230 / 255, alpha: 1)
    }

    static var redBackground: UIColor {
        return UIColor(red: 254 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1)
    }

    static var yellowBackground: UIColor {
        return UIColor(red: 254 / 255, green: 242 / 255, blue: 213 / 255, alpha: 1)
    }

    static var darkBrand: UIColor {
        return UIColor(red: 50 / 255, green: 135 / 255, blue: 140 / 255, alpha: 1)
    }

    static var scanditGreenBorder: UIColor {
        return UIColor(red: 56.0/255.0, green: 193.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    }

    static var scanditGreenFill: UIColor {
        return UIColor(red: 21.0/255.0, green: 216.0/255.0, blue: 43.0/255.0, alpha: 0.74)
    }

    static var scanditViewTipDark: UIColor {
        return #colorLiteral(red: 0.1450980392, green: 0.1607843137, blue: 0.1607843137, alpha: 0.9)
    }

    static var monochromeGrey300: UIColor {
        return UIColor(red: 218.0/255.0, green: 225.0/255.0, blue: 231.0/255.0, alpha: 1)
    }

    static var monochromeGrey500: UIColor {
        return UIColor(red: 135.0/255.0, green: 149.0/255.0, blue: 161.0/255.0, alpha: 1)
    }

    static var monochromeBlack700: UIColor {
        return UIColor(red: 61.0/255.0, green: 72.0/255.0, blue: 82.0/255.0, alpha: 1)
    }

    static var monochromeBlack900: UIColor {
        return UIColor(red: 18.0/255.0, green: 22.0/255.0, blue: 25.0/255.0, alpha: 1)
    }

    static var greenIcon: UIColor {
        return UIColor(red: 40.0/255.0, green: 211.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    }

    static var redIcon: UIColor {
        return UIColor(red: 250.0/255.0, green: 68.0/255.0, blue: 70.0/255.0, alpha: 1.0)
    }

    static var yellowIcon: UIColor {
        return UIColor(red: 251.0/255.0, green: 192.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    }

    static func color(hexString: String) -> UIColor {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        return UIColor(red: CGFloat(r) / 255,
                       green: CGFloat(g) / 255,
                       blue: CGFloat(b) / 255,
                       alpha: CGFloat(a) / 255)
    }

}

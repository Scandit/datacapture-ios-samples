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
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Could not get context")
        }

        context.setFillColor(self.cgColor)
        context.fill(rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Could not get image")
        }
        UIGraphicsEndImageContext()

        return image
    }

    static var brand: UIColor {
        UIColor(red: 57 / 255, green: 193 / 255, blue: 204 / 255, alpha: 1)
    }

    static var greenBackground: UIColor {
        UIColor(red: 212 / 255, green: 246 / 255, blue: 230 / 255, alpha: 1)
    }

    static var redBackground: UIColor {
        UIColor(red: 254 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1)
    }

    static var yellowBackground: UIColor {
        UIColor(red: 254 / 255, green: 242 / 255, blue: 213 / 255, alpha: 1)
    }

    static var darkBrand: UIColor {
        UIColor(red: 50 / 255, green: 135 / 255, blue: 140 / 255, alpha: 1)
    }

    static var scanditGreenBorder: UIColor {
        UIColor(red: 56.0 / 255.0, green: 193.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
    }

    static var scanditGreenFill: UIColor {
        UIColor(red: 21.0 / 255.0, green: 216.0 / 255.0, blue: 43.0 / 255.0, alpha: 0.74)
    }

    static var scanditViewTipDark: UIColor {
        #colorLiteral(red: 0.1450980392, green: 0.1607843137, blue: 0.1607843137, alpha: 0.9)
    }

    static var monochromeGrey300: UIColor {
        UIColor(red: 218.0 / 255.0, green: 225.0 / 255.0, blue: 231.0 / 255.0, alpha: 1)
    }

    static var monochromeGrey500: UIColor {
        UIColor(red: 135.0 / 255.0, green: 149.0 / 255.0, blue: 161.0 / 255.0, alpha: 1)
    }

    static var monochromeBlack700: UIColor {
        UIColor(red: 61.0 / 255.0, green: 72.0 / 255.0, blue: 82.0 / 255.0, alpha: 1)
    }

    static var monochromeBlack900: UIColor {
        UIColor(red: 18.0 / 255.0, green: 22.0 / 255.0, blue: 25.0 / 255.0, alpha: 1)
    }

    static var greenIcon: UIColor {
        UIColor(red: 40.0 / 255.0, green: 211.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    }

    static var redIcon: UIColor {
        UIColor(red: 250.0 / 255.0, green: 68.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)
    }

    static var yellowIcon: UIColor {
        UIColor(red: 251.0 / 255.0, green: 192.0 / 255.0, blue: 44.0 / 255.0, alpha: 1.0)
    }
}

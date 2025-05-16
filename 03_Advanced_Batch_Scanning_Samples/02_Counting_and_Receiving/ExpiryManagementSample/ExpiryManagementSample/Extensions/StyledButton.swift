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

fileprivate extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Could not get current graphics context")
        }

        context.setFillColor(self.cgColor)
        context.fill(rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Could not get image from current context")
        }
        UIGraphicsEndImageContext()

        return image
    }
}

private struct CompleteButtonStyle {
    let normalTitleColor: UIColor
    let normalBackgroundColor: UIColor
    let pressedTitleColor: UIColor
    let pressedBackgroundColor: UIColor
    let inactiveTitleColor: UIColor
    let inactiveBackgroundColor: UIColor

    static let primary = CompleteButtonStyle(
        normalTitleColor: .white,
        normalBackgroundColor: .black,
        pressedTitleColor: .white,
        pressedBackgroundColor: UIColor(red: 0.239, green: 0.282, blue: 0.322, alpha: 1.0),
        inactiveTitleColor: UIColor(red: 0.529, green: 0.584, blue: 0.631, alpha: 1.0),
        inactiveBackgroundColor: UIColor(red: 0.855, green: 0.882, blue: 0.906, alpha: 1.0)
    )

    static let secondary = CompleteButtonStyle(
        normalTitleColor: UIColor(red: 0.071, green: 0.086, blue: 0.098, alpha: 1.0),
        normalBackgroundColor: .white,
        pressedTitleColor: .white,
        pressedBackgroundColor: .black,
        inactiveTitleColor: UIColor(red: 0.529, green: 0.584, blue: 0.631, alpha: 1.0),
        inactiveBackgroundColor: UIColor(red: 0.855, green: 0.882, blue: 0.906, alpha: 1.0)
    )
}

extension UIButton {

    private func style(with style: CompleteButtonStyle) {
        setTitleColor(style.normalTitleColor, for: .normal)
        setBackgroundImage(style.normalBackgroundColor.image(), for: .normal)

        setTitleColor(style.pressedTitleColor, for: .highlighted)
        setBackgroundImage(style.pressedBackgroundColor.image(), for: .highlighted)

        setTitleColor(style.inactiveTitleColor, for: .disabled)
        setBackgroundImage(style.inactiveBackgroundColor.image(), for: .disabled)
    }

    func styleAsPrimaryButton() {
        style(with: .primary)
    }

    func styleAsSecondaryButton() {
        style(with: .secondary)
        layer.borderWidth = 2.0
        layer.borderColor = CompleteButtonStyle.secondary.normalTitleColor.cgColor
    }

    func styleAsSecondaryLinkButton() {
        style(with: .secondary)
    }
}

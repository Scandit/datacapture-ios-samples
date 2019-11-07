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

class BottomScanningIndicator: UIView {

    var contentView: UIView!

    @IBOutlet weak var animatingCircle: UIView!
    @IBOutlet weak var scanLabel: UILabel!

    var animator: AutoReversingAnimator!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = UINib(nibName: "BottomScanningIndicator",
                         bundle: nil).instantiate(withOwner: self, options: nil).first
        guard let contentView = view as? UIView else {
            fatalError()
        }
        addSubview(contentView)
        contentView.frame = bounds
        self.contentView = contentView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        animatingCircle.layer.cornerRadius = animatingCircle.bounds.width / 2
        let attributes = [
            NSAttributedString.Key.kern: 1.5,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 18) as Any]
        scanLabel.attributedText = NSAttributedString(string: "Searching Barcode...", attributes: attributes)

        animator = AutoReversingAnimator(duration: 1, curve: .linear, animations: { [weak self] in
            self?.animatingCircle.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            self?.animatingCircle.alpha = 0
        })
        animator.startAnimation()
    }

    deinit {
        animator.stopAnimation(true)
    }
}

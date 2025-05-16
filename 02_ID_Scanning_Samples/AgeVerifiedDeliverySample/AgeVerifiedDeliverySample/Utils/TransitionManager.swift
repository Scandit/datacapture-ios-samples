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

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    enum Mode {
        case presenting
        case dismissing
    }

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.333
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch mode {
        case .presenting:
            animatePresenting(using: transitionContext)
        case .dismissing:
            animateDismissing(using: transitionContext)
        }
    }

    func animatePresenting(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let toViewController = transitionContext.viewController(forKey: .to)
        else { fatalError() }
        transitionContext.containerView.addSubview(toView)

        toView.layer.cornerRadius = 16
        toView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        var size = toViewController.preferredContentSize
        size.width = transitionContext.containerView.frame.width

        let finalFrame = CGRect(
            x: 0,
            y: transitionContext.containerView.frame.height - size.height,
            width: size.width,
            height: size.height
        )
        let startingFrame = CGRect(
            x: 0,
            y: transitionContext.containerView.frame.height,
            width: size.width,
            height: size.height
        )
        toView.frame = startingFrame
        let animations = {
            toView.frame = finalFrame
        }

        let completion: ((Bool)) -> Void = {
            transitionContext.completeTransition($0)
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: animations,
            completion: completion
        )
    }

    func animateDismissing(using transitionContext: UIViewControllerContextTransitioning) {

        guard let fromView = transitionContext.view(forKey: .from) else {
            fatalError()
        }
        let size = transitionContext.containerView.frame.size
        let finalFrame = CGRect(
            x: 0,
            y: transitionContext.containerView.frame.height,
            width: size.width,
            height: size.height
        )
        let animations = {
            fromView.frame = finalFrame
        }

        let completion: ((Bool)) -> Void = {
            transitionContext.completeTransition($0)
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: animations,
            completion: completion
        )
    }
}

class TransitionManager: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TransitionAnimator(mode: .dismissing)
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        TransitionAnimator(mode: .presenting)
    }
}

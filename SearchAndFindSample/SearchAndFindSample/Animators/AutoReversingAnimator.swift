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

class AutoReversingAnimator: UIViewPropertyAnimator {

    typealias BeforeAnimation = () -> Void

    private var isFirstStart = true
    private var isRunningObservation: NSKeyValueObservation!
    private var beforeAnimation: BeforeAnimation?
    private var beforeAnimationDuration: TimeInterval?
    private var beforeAnimationCurve: UIView.AnimationCurve = .easeInOut

    private var beforeAnimator: UIViewPropertyAnimator? {
        guard let beforeAnimation = beforeAnimation else {
            super.startAnimation()
            return nil
        }

        let animator = UIViewPropertyAnimator(duration: beforeAnimationDuration ?? duration,
                                              curve: beforeAnimationCurve,
                                              animations: beforeAnimation)

        animator.addCompletion { [weak self] _ in
            guard let self = self else {
                return
            }
            self.isFirstStart = false
            self.startAnimation()
        }

        return animator
    }

    required init(duration: TimeInterval,
                  curve: UIView.AnimationCurve,
                  animations: @escaping () -> Void,
                  beforeAnimation: BeforeAnimation? = nil,
                  beforeAnimationDuration: TimeInterval? = nil,
                  beforeAnimationCurve: UIView.AnimationCurve? = nil ) {
        let timingParameters = UICubicTimingParameters(animationCurve: curve)
        super.init(duration: duration, timingParameters: timingParameters)

        addAnimations(animations)

        pausesOnCompletion = true

        isRunningObservation = observe(\.isRunning, changeHandler: { [weak self] _, _ in
            guard let self = self else {
                return
            }

            if self.isRunning == false, self.state == .active {
                self.isReversed = !self.isReversed
                self.startAnimation()
            }
        })

        if let beforeAnimation = beforeAnimation {
            self.beforeAnimation = beforeAnimation
        }

        if let beforeAnimationDuration = beforeAnimationDuration {
            self.beforeAnimationDuration = beforeAnimationDuration
        }

        if let beforeAnimationCurve = beforeAnimationCurve {
            self.beforeAnimationCurve = beforeAnimationCurve
        }
    }

    override func startAnimation() {
        guard let beforeAnimator = beforeAnimator, isFirstStart == true else {
            super.startAnimation()
            return
        }

        beforeAnimator.startAnimation()
    }
}

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

class CompactNavigationController: UINavigationController {

    var keyboardWillShowToken: NSObjectProtocol?
    var keyboardWillHideToken: NSObjectProtocol?

    var currentOffest: CGFloat = 0

    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .black
        setupKeyboardNotifications()
    }

    private func setupKeyboardNotifications() {
        keyboardWillShowToken = NotificationCenter
            .default
            .addObserver(forName: UIResponder.keyboardWillShowNotification,
                         object: nil,
                         queue: .main) { notification in

                guard let keyboardFrame = notification
                        .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

                guard self.currentOffest == 0 else { return }
                self.currentOffest = keyboardFrame.height

                guard let duration =
                        notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                      let rawAnimationCurve =
                        notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                      let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)  else { return }

                let animator = UIViewPropertyAnimator(duration: duration,
                                                      curve: animationCurve) {
                    self.view.center = CGPoint(x: self.view.center.x,
                                               y: self.view.center.y - keyboardFrame.height)
                }

                animator.startAnimation()

            }

        keyboardWillHideToken = NotificationCenter
            .default
            .addObserver(forName: UIResponder.keyboardWillHideNotification,
                         object: nil,
                         queue: .main) { notification in

                guard self.currentOffest > 0 else { return }
                self.currentOffest = 0

                guard
                    let duration =
                        notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                    let keyboardFrame =
                        notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                    let rawAnimationCurve =
                        notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                    let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)  else { return }

                let animator = UIViewPropertyAnimator(duration: duration,
                                                      curve: animationCurve) {
                    self.view.center = CGPoint(x: self.view.center.x,
                                               y: self.view.center.y + keyboardFrame.height)
                }

                animator.startAnimation()
            }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

extension CompactNavigationController: UINavigationControllerDelegate {
    // We listen to the navigation controller delegate methods so we can adjust
    // the size of the sheet on the fly when a new controller is pushed.
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let newSize = viewController.preferredContentSize
        let diff = view.frame.size.height - newSize.height
        view.center.y += diff
        view.frame.size.height = newSize.height
    }
}

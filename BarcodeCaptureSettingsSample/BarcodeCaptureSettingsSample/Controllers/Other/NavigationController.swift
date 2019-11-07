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

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }

    private func setupGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showScanner))
        gestureRecognizer.numberOfTapsRequired = 2
        navigationBar.addGestureRecognizer(gestureRecognizer)
    }

    @objc private func showScanner() {
        popToRootViewController(animated: true)
    }

}

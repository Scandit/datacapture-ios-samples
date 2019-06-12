/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import UIKit
import ScanditBarcodeCapture

private struct Result {
    let barcodes: [Barcode]

    var text: String {
        return barcodes.reduce(into: "") { result, barcode in
            result += """
            \(barcode.symbology.readableName): \(barcode.data)
            Symbol Count: \(barcode.symbolCount)\n\n
            """
        }
    }
}

protocol ResultViewControllerDelegate: AnyObject {
    func willShow(resultViewController: ResultViewController)
    func didHide(resultViewController: ResultViewController)
}

class ResultViewController: UIViewController {
    private struct Constants {
        static let defaultAnimationDuration: TimeInterval = 0.2
        static let shownDurationInContinuourMode: TimeInterval = 0.5
    }

    typealias CompletionHandler = () -> Void

    @IBOutlet weak var resultTextView: UITextView!

    weak var delegate: ResultViewControllerDelegate?

    var isContinuousModeEnabled = false

    private var completion: CompletionHandler?
    private var continuousModeDismissWorkItem: DispatchWorkItem?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hide(0)
    }

    func show(barcodes: [Barcode], completion: CompletionHandler?) {
        self.completion = completion

        resultTextView.text = Result(barcodes: barcodes).text

        show {
            if self.isContinuousModeEnabled {
                self.hideLater(completion: completion)
            }
        }
    }

    @IBAction func hideInitiatedByUserInteraction(_ sender: UITapGestureRecognizer) {
        continuousModeDismissWorkItem?.cancel()
        hide(completion: completion)
    }

    private func hide(_ duration: TimeInterval = Constants.defaultAnimationDuration,
                      completion: CompletionHandler? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            self.view.isHidden = true
            self.delegate?.didHide(resultViewController: self)
            completion?()
        })
    }

    private func show(_ duration: TimeInterval = Constants.defaultAnimationDuration,
                      completion: CompletionHandler? = nil) {
        view.isHidden = false
        self.delegate?.willShow(resultViewController: self)
        UIView.animate(withDuration: duration, animations: {
            self.view.alpha = 1.0
        }, completion: { _ in
            completion?()
        })
    }

    private func hideLater(completion: CompletionHandler?) {
        continuousModeDismissWorkItem?.cancel()

        continuousModeDismissWorkItem = DispatchWorkItem(block: { [weak self] in
            self?.hide(completion: completion)
            self?.continuousModeDismissWorkItem = nil
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.shownDurationInContinuourMode,
                                      execute: continuousModeDismissWorkItem!)
    }

}

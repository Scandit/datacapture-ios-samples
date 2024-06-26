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

import UIKit

class DatePickerViewController: UIViewController {

    var didPickDateCompletion: ((Date) -> Void)?

    public var maxDateIsToday: Bool = false {
        didSet {
            constrainDate()
        }
    }

    @IBOutlet
    private weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        constrainDate()

        // Do any additional setup after loading the view.

        let saveButton = UIBarButtonItem(title: "Save",
                                         style: .plain,
                                         target: self,
                                         action: #selector(saveAction))
        navigationItem.rightBarButtonItem = saveButton
    }

    @objc
    func saveAction() {
        didPickDateCompletion?(datePicker.date)
    }

    override var preferredContentSize: CGSize {
        get {
            let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize,
                                                    withHorizontalFittingPriority: .fittingSizeLevel,
                                                    verticalFittingPriority: .fittingSizeLevel)
            return size
        }

        set {
            super.preferredContentSize = newValue
        }
    }

    private func constrainDate() {
        datePicker?.maximumDate = maxDateIsToday ? Date() : nil
    }
}

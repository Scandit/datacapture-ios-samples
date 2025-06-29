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

import ScanditBarcodeCapture
import UIKit

protocol ItemsTableViewControllerDelegate: AnyObject {
    func itemsTableViewController(
        _ itemsTableViewController: ItemsTableViewController,
        didFinishWithIntent intent: ItemsTableViewController.Intent
    )
}

class ItemsTableViewController: UIViewController {
    enum Intent {
        case restartScanning
        case resumeScanning
    }

    @IBOutlet private var tableView: ItemsTableView!
    @IBOutlet private var clearListButton: UIButton!
    @IBOutlet private var scanButton: UIButton!

    var delegate: ItemsTableViewControllerDelegate?
    var viewModel: ItemsTableViewModel?
    var scanningCompleted: Bool = false
    private var userWantsToClearList = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scanned Items"
        clearListButton.styleAsSecondaryButton()
        scanButton.styleAsPrimaryButton()
        tableView.viewModel = viewModel

        if scanningCompleted {
            scanButton.setTitle("START NEW LIST", for: .normal)
        } else {
            scanButton.setTitle("RESUME SCANNING", for: .normal)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            if scanningCompleted || userWantsToClearList {
                delegate?.itemsTableViewController(self, didFinishWithIntent: .restartScanning)
            } else {
                delegate?.itemsTableViewController(self, didFinishWithIntent: .resumeScanning)
            }
        }
    }

    @IBAction func didTapClearList() {
        userWantsToClearList = true
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapScan() {
        navigationController?.popViewController(animated: true)
    }
}

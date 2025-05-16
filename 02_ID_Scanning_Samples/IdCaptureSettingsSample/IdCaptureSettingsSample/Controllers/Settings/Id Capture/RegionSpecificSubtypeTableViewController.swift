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

import ScanditIdCapture
import UIKit

class RegionSpecificSubtypeTableViewController: SearchingSettingsTableViewController {
    let keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>
    let updateParentCell: () -> Void
    var allNoneButtonItem: UIBarButtonItem!

    init(
        keyPath: WritableKeyPath<SettingsManager, [IdCaptureDocument]>,
        updateParentCell: @escaping () -> Void
    ) {
        self.keyPath = keyPath
        self.updateParentCell = updateParentCell
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        allNoneButtonItem = UIBarButtonItem(
            title: buttonTitle(),
            style: .plain,
            target: self,
            action: #selector(allNoneTapped)
        )
        navigationItem.rightBarButtonItem = allNoneButtonItem
    }

    override func hasSelection() -> Bool {
        guard let dataSource = dataSource as? RegionSpecificSubtypeDataSource else { return false }
        return dataSource.modelPath.contains(documentType: .regionSpecific)
    }

    override func search(text: String?) -> Bool {
        guard let dataSource = dataSource as? RegionSpecificSubtypeDataSource,
            text != dataSource.searchText
        else { return false }
        dataSource.searchText = text
        return true
    }

    override func setupDataSource() {
        dataSource = RegionSpecificSubtypeDataSource(
            delegate: self,
            keyPath: keyPath,
            updateParentCell: updateParentCell
        )
    }

    func allSelected() -> Bool {
        guard let dataSource = dataSource as? RegionSpecificSubtypeDataSource else { return false }
        return dataSource.allSelected
    }

    func buttonTitle() -> String {
        allSelected() ? "Disable All" : "Enable All"
    }

    @objc func allNoneTapped() {
        guard let dataSource = dataSource as? RegionSpecificSubtypeDataSource else { return }
        dataSource.updateSelectionAll(insert: !allSelected())
        allNoneButtonItem.title = buttonTitle()
        tableView.reloadData()
    }

    // MARK: - Data source delegate

    override func didChangeData() {
        super.didChangeData()
        allNoneButtonItem.title = buttonTitle()
    }
}

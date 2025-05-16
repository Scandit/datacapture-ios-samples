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

class ItemsTableView: UITableView {
    @IBOutlet private weak var itemsTableViewHeader: ItemsTableViewHeader!

    var viewModel: ItemsTableViewModel? {
        didSet {
            if let viewModel {
                viewModel.onDataUpdated = { [weak self] in
                    self?.reloadData()
                    self?.itemsTableViewHeader.itemsCount = self?.viewModel?.numberOfItems()
                }
            }
        }
    }

    var allowEditing: Bool = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.register(
            UINib(nibName: "ItemTableViewCell", bundle: nil),
            forCellReuseIdentifier: ItemTableViewCell.identifier
        )
    }
}

// MARK: - UITableViewDataSource Protocol Implementation

extension ItemsTableView: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel?.count() ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ItemTableViewCell.identifier,
            for: indexPath
        )
        guard let itemTableViewCell = tableViewCell as? ItemTableViewCell else {
            fatalError("Unable to deque reusable cell")
        }

        // Retrieve the item to be used for configuring the cell.
        if let item = viewModel?.itemAtIndex(indexPath.row) {
            // Configure the dequeued cell to show the item.
            itemTableViewCell.configure(with: item)
        }

        return itemTableViewCell
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            viewModel?.deleteItemAtIndex(indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        allowEditing
    }
}

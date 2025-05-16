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

class SearchingSettingsTableViewController: SettingsTableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.systemOrange
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }

    func hasSelection() -> Bool {
        fatalError("Should be implemented by subclass")
    }

    func search(text: String?) -> Bool {
        fatalError("Should be implemented by subclass")
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        if search(text: searchController.searchBar.text) {
            super.didChangeData()
        }
    }

    // MARK: - Data source delegate

    override func didChangeData() {
        enableBackNavigation(enabled: hasSelection())
    }

    private func enableBackNavigation(enabled: Bool) {
        navigationItem.hidesBackButton = !enabled
    }
}

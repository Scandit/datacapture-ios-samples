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

protocol ScanResultsViewControllerDelegate: AnyObject {
    func scanResultsViewControllerDidPressClearList(_ viewController: ScanResultsViewController)
    func scanResultsViewControllerDidPressContinueScanning(_ viewController: ScanResultsViewController)
}

class ScanResultsViewController: UIViewController {
    var scannedItems: [Item] = [] {
        didSet {
            if isViewLoaded {
                update()
            }
        }
    }
    weak var delegate: ScanResultsViewControllerDelegate?
    private var firstCellLayoutGuide = UILayoutGuide()
    private var firstCellLayoutGuideBottomConstrant: NSLayoutConstraint!

    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var clearListButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanLabelsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addLayoutGuide(firstCellLayoutGuide)
        firstCellLayoutGuideBottomConstrant = firstCellLayoutGuide.bottomAnchor.constraint(equalTo: tableView.topAnchor)
        NSLayoutConstraint.activate([
            firstCellLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            firstCellLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
            firstCellLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor),
            firstCellLayoutGuideBottomConstrant,
        ])
        firstCellLayoutGuide.identifier = "firstCellLayoutGuide"

        update()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFirstCellLayoutGuide()
    }

    private func update() {
        itemCountLabel.text = scannedItems.count != 1 ? "\(scannedItems.count) items scanned" : "1 item scanned"
        tableView.isHidden = scannedItems.count == 0
        scanLabelsView.isHidden = !tableView.isHidden
        clearListButton.isHidden = tableView.isHidden
        tableView.reloadData()
    }

    private func updateFirstCellLayoutGuide() {
        let firstCellRect = tableView.rectForRow(at: IndexPath(item: 0, section: 0))
        firstCellLayoutGuideBottomConstrant.constant = firstCellRect.maxY - 1
    }

    @IBAction func onClearListPressed(_ sender: Any) {
        delegate?.scanResultsViewControllerDidPressClearList(self)
    }

    @IBAction func onContinueScanningPressed(_ sender: Any) {
        delegate?.scanResultsViewControllerDidPressContinueScanning(self)
    }
}

// MARK: UITableViewDataSource

extension ScanResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scannedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = scannedItems[indexPath.item]
        let isLastItem = indexPath.item == scannedItems.count - 1
        let title = "ITEM \(indexPath.item + 1)"
        switch item.type {
        case .regular:
            guard
                let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: "RegularItemCell",
                        for: indexPath
                    ) as? RegularItemCell
            else {
                fatalError("Could not dequeue RegularItemCell")
            }
            cell.configure(with: item, title: title)
            cell.hideSeparator = isLastItem
            return cell
        case .weighted:
            guard
                let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: "WeightedItemCell",
                        for: indexPath
                    ) as? WeightedItemCell
            else {
                fatalError("Could not dequeue WeightedItemCell")
            }
            cell.configure(with: item, title: title)
            cell.hideSeparator = isLastItem
            return cell
        }
    }
}

// MARK: SheetContentViewController

extension ScanResultsViewController: SheetContentViewController {
    var sheetPartialContentGuide: UILayoutGuide { firstCellLayoutGuide }

    func sheetContainerDidBeginDrag(_ viewController: SheetContainerViewController) {
        guard scannedItems.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }

    func sheetContainer(
        _ viewController: SheetContainerViewController,
        willTransitionTo state: SheetContainerViewController.State,
        animated: Bool
    ) {
        guard scannedItems.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: animated)
    }

    func sheetContainer(
        _ viewController: SheetContainerViewController,
        didTransitionTo state: SheetContainerViewController.State,
        animated: Bool
    ) {
        tableView.isScrollEnabled = state == .expanded
    }
}

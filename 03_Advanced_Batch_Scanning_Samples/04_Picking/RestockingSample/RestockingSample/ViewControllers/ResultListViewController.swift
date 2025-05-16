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

protocol ResultListViewControllerDelegate: AnyObject {
    func resultListViewControllerDidReset(_ viewController: ResultListViewController)
}

class ResultListViewController: UIViewController {

    var pickedItems: [PickItem]!
    var inventoryItems: [PickItem]!
    weak var delegate: ResultListViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var finishButton: UIButton!

    private enum Constants {
        static let resultCellReuseIdentifier = "ResultListCell"
        static let sectionHeaderReuseIdentifier = "ResultListSectionHeader"
        static let unWindToPickSegueIdentifier = "unWindToPickSegueIdentifier"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ResultListSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: Constants.sectionHeaderReuseIdentifier)
        tableView.sectionFooterHeight = 0

        footerView.layer.shadowColor = UIColor(red: 0.11, green: 0.13, blue: 0.15, alpha: 0.2).cgColor
        footerView.layer.shadowOpacity = 1
        footerView.layer.shadowRadius = 16
        footerView.layer.shadowOffset = .zero

        finishButton.layer.borderWidth = 2.0
        finishButton.layer.borderColor = UIColor.black.cgColor
    }

    func itemsForSection(_ section: Int) -> [PickItem]? {
        switch section {
        case 0:
            return pickedItems
        case 1:
            return inventoryItems
        default:
            return nil
        }
    }

    func itemAtIndexPath(_ indexPath: IndexPath) -> PickItem? {
        guard let itemArray = itemsForSection(indexPath.section) else {
            return nil
        }
        return itemArray[indexPath.row]
    }

    @IBAction func continueScanningPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.unWindToPickSegueIdentifier, sender: self)
    }

    @IBAction func finishPressed(_ sender: Any) {
        delegate?.resultListViewControllerDidReset(self)
        performSegue(withIdentifier: Constants.unWindToPickSegueIdentifier, sender: self)
    }
}

extension ResultListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return pickedItems.count
        case 1:
            return inventoryItems.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: Constants.resultCellReuseIdentifier,
                    for: indexPath
                ) as? ResultListCell
        else {
            fatalError("Could not dequeue cell")
        }
        guard let item = itemAtIndexPath(indexPath) else { return cell }

        if let productIdentifier = item.productIdentifier {
            cell.identifierLabel.text = "Item \(productIdentifier)"
        } else {
            cell.identifierLabel.text = "Unknown"
        }

        cell.dataLabel.text = item.data
        switch indexPath.section {
        case 0:
            var image: UIImage?
            if !item.inList {
                image = UIImage(named: "NotInList")
            } else if !item.extraPick {
                image = UIImage(named: "Picked")
            }
            cell.notInListLabel.isHidden = item.inList
            cell.iconImageView.image = image
        case 1:
            cell.notInListLabel.isHidden = true
            cell.iconImageView.image = nil
        default:
            break
        }
        return cell
    }
}

extension ResultListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let items = itemsForSection(section), items.count > 0 else { return nil }

        guard
            let view =
                tableView.dequeueReusableHeaderFooterView(
                    withIdentifier: Constants.sectionHeaderReuseIdentifier
                ) as? ResultListSectionHeaderView
        else {
            fatalError("Could not dequeue section header view")
        }

        switch section {
        case 0:
            view.headerLabel.text = "Picklist"
        case 1:
            view.headerLabel.text = "Inventory (\(items.count))"
        default:
            break
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let items = itemsForSection(section), items.count > 0 else { return 0 }
        return UITableView.automaticDimension
    }
}

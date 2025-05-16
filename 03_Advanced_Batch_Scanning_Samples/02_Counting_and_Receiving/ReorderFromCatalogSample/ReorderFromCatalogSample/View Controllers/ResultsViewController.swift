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

protocol ResultViewControllerDelegate: AnyObject {
    func clearButtonTapped()
}

class ResultsViewController: UIViewController {

    var results: [Result] = []
    weak var delegate: ResultViewControllerDelegate?
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var bottomContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction private func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func resumeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func clearButtonTapped(_ sender: Any) {
        delegate?.clearButtonTapped()
        dismiss(animated: true)
    }

    private func setupUI() {
        setupTableView()
        setupButtons()
        setupButtomContainerView()
    }

    private func setupTableView() {
        tableView.registerNib(ResultCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .tableViewBackgroundColor
        tableView.sectionHeaderHeight = 32
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }

    private func setupButtomContainerView() {
        bottomContainerView.layer.shadowColor = UIColor.shadowColor.cgColor
        bottomContainerView.layer.shadowPath = UIBezierPath(rect: bottomContainerView.bounds).cgPath
        bottomContainerView.layer.shadowOpacity = 1.0
        bottomContainerView.layer.shadowRadius = 16
        bottomContainerView.layer.masksToBounds = false
    }

    private func setupButtons() {
        clearButton.layer.borderWidth = 2.0
        clearButton.layer.borderColor = UIColor.black.cgColor
    }
}

extension ResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.backgroundView?.backgroundColor = .white
        headerView.textLabel?.textColor = .sectionTextColor
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 12)
    }
}

extension ResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        84
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: ResultCell.self.reuseIdentifier,
                    for: indexPath
                ) as? ResultCell
        else {
            fatalError("Could not dequeue ResultCell")
        }
        let result = results[indexPath.row]
        cell.textLabel?.text = result.symbology.readableName
        cell.detailTextLabel?.text = result.data
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Items (\(results.count))"
    }
}

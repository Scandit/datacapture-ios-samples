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

import Foundation
import UIKit

protocol ListViewControllerDelegate: AnyObject {
    func listViewController(_ listViewController: ListViewController,
                            didFinishWithIntent intent: ListViewController.Intent)
}

class ListViewController: UIViewController {
    enum Intent {
        case restartScanning
        case resumeScanning
    }

    private let countLabel = UILabel()
    private let tableView = UITableView()

    // Bottom container with buttons
    private let bottomContainer = UIView()
    private let resumeScanningButton = UIButton(type: .custom)
    private let clearListButton = UIButton(type: .custom)

    private let isOrderCompleted: Bool
    private let multipleScanItems: [ScannedItem]
    private let singleScanItems: [ScannedItem]
    private let numberOfItems: Int

    weak var delegate: ListViewControllerDelegate?

    init(scannedItems: [ScannedItem], isOrderCompleted: Bool) {
        self.isOrderCompleted = isOrderCompleted
        // Use two arrays to organize the list: Items scanned multiple times and items scanned just one time.
        self.singleScanItems = scannedItems.filter({ $0.quantity == 1 })
        self.multipleScanItems = scannedItems.filter({ $0.quantity > 1 })
        // Total number of scans
        self.numberOfItems = scannedItems.reduce(0, { partialResult, item in
            return partialResult + item.quantity
        })
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Scanned Items"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .white

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .systemFont(ofSize: 12, weight: .regular)
        countLabel.textColor = UIColor(red: 0.239, green: 0.282, blue: 0.322, alpha: 1.0)
        view.addSubview(countLabel)
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            countLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])

        countLabel.text = "Items (\(numberOfItems))"

        bottomContainer.backgroundColor = .white
        resumeScanningButton.addTarget(self, action: #selector(didTapResumeScanning), for: .touchUpInside)
        resumeScanningButton.setTitle(isOrderCompleted ? "SCAN NEXT ORDER" : "RESUME SCANNING", for: .normal)
        resumeScanningButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        clearListButton.addTarget(self, action: #selector(didTapClearList), for: .touchUpInside)
        clearListButton.setTitle("CLEAR LIST", for: .normal)
        clearListButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        resumeScanningButton.translatesAutoresizingMaskIntoConstraints = false
        clearListButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(resumeScanningButton)
        bottomContainer.addSubview(clearListButton)
        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            resumeScanningButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 16),
            resumeScanningButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 32),
            resumeScanningButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -32),
            resumeScanningButton.heightAnchor.constraint(equalToConstant: 51),

            clearListButton.topAnchor.constraint(equalTo: resumeScanningButton.bottomAnchor, constant: 16),
            clearListButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 32),
            clearListButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -32),
            clearListButton.bottomAnchor.constraint(equalTo: bottomContainer.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -16),
            clearListButton.heightAnchor.constraint(equalToConstant: 51)
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1.0)
        tableView.dataSource = self
        tableView.register(ListCell.self,
                           forCellReuseIdentifier: ListCell.reuseIdentifier)
        tableView.rowHeight = 85
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor)
        ])

        resumeScanningButton.styleAsPrimaryButton()
        clearListButton.styleAsSecondaryButton()

        bottomContainer.layer.shadowColor = UIColor.black.cgColor
        bottomContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        bottomContainer.layer.shadowRadius = 2.0
        bottomContainer.layer.shadowOpacity = 0.15
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            dismissList()
        }
    }

    @objc private func didTapResumeScanning() {
        dismissList()
    }

    private func dismissList() {
        if isOrderCompleted {
            delegate?.listViewController(self, didFinishWithIntent: .restartScanning)
        } else {
            delegate?.listViewController(self, didFinishWithIntent: .resumeScanning)
        }
    }

    @objc private func didTapClearList() {
        delegate?.listViewController(self, didFinishWithIntent: .restartScanning)
    }

    private func itemListForSection(_ section: Int) -> [ScannedItem] {
        switch section {
        case 0:
            return multipleScanItems
        case 1:
            return singleScanItems
        default:
            return []
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier) as? ListCell else {
            return UITableViewCell()
        }
        let item = itemListForSection(indexPath.section)[indexPath.row]
        cell.configureWithScannedItem(item, index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemListForSection(section).count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

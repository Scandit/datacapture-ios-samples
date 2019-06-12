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

import ScanditBarcodeCapture
import UIKit

class SplitViewModeViewController: UIViewController {

    private enum Constants {
        static let splitViewResultCellIdentifier = "splitViewCellReuseIdentifier"
    }

    @IBOutlet weak var tableView: UITableView!

    private var scannerViewController: SplitViewScannerViewController {
        return children.first(where: { $0 is SplitViewScannerViewController }) as! SplitViewScannerViewController
    }

    var scanResults: [ScanResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Clear",
                                                                      style: .plain,
                                                                      target: self, action: #selector(clear))
        scannerViewController.delegate = self
    }

    @objc private func clear() {
        scanResults.removeAll()
        tableView.reloadData()
    }
}

extension SplitViewModeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.splitViewResultCellIdentifier) else {
            fatalError()
        }
        let scanResult = scanResults[indexPath.row]
        cell.textLabel?.text = scanResult.data
        cell.detailTextLabel?.text = scanResult.symbology.description
        return cell
    }
}

extension SplitViewModeViewController: SplitViewScannerViewControllerDelegate {
    func splitViewScannerViewController(_ splitViewScannerViewController: SplitViewScannerViewController,
                                        didScan scanResult: ScanResult) {
        scanResults.append(scanResult)
        tableView.reloadData()
    }
}

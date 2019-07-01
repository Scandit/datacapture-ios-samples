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

import UIKit
import ScanditBarcodeCapture

final class ResultCell: UITableViewCell {
    @IBOutlet weak var barcodeData: UILabel!
    @IBOutlet weak var symbology: UILabel!
}

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var results: [Barcode] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        cell.barcodeData.text = results[indexPath.row].data
        cell.symbology.text = SymbologyDescription(symbology: results[indexPath.row].symbology).readableName
        return cell
    }

    @IBAction func dismiss() {
        navigationController?.popViewController(animated: true)
    }
}

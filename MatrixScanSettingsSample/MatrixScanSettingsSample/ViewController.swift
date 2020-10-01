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

import UIKit

protocol Showable {
    var pretty: String { get }
}
enum Mode: Int, CaseIterable, Showable {
    case mono
    case bi
    case both

    var pretty: String {
        switch self {
        case .mono:
            return "1D Symbologies"
        case .bi:
            return "2D Symbologies"
        case .both:
            return "1D & 2D Symbologies"
        }
    }
}

enum CameraResolution: Int, CaseIterable, Showable {
    case uhd4k
    case fullHD

    var pretty: String {
        switch self {
        case .uhd4k:
            return "4K"
        case .fullHD:
            return "Full HD"
        }
    }
}

class ViewController: UIViewController {

    lazy var tableView: UITableView = UITableView(frame: view.bounds,
                                                  style: .grouped)

    var selectedMode: Mode = .mono
    var selectedCameraResolution: CameraResolution = .uhd4k
    var options: [[Showable]] = [Mode.allCases, CameraResolution.allCases]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SimpleCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ScanViewController else {
            return
        }

        destination.cameraResolution = selectedCameraResolution
        destination.mode = selectedMode
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? Mode.allCases.count : CameraResolution.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell") {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SimpleCell")
        }
        let selectedIndex = indexPath.section == 0 ? selectedMode.rawValue : selectedCameraResolution.rawValue
        cell.textLabel?.text = options[indexPath.section][indexPath.row].pretty
        cell.accessoryType = selectedIndex == indexPath.row ? .checkmark : .none
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Mode" : "Camera resolution"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedMode = Mode(rawValue: indexPath.row)!
        case 1:
            selectedCameraResolution = CameraResolution(rawValue: indexPath.row)!
        default:
            fatalError()
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section),
                                 with: .automatic)
    }
}

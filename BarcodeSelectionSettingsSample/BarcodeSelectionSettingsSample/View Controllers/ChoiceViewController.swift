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

class ChoiceViewController<Choice: CustomStringConvertible>: UITableViewController {

    typealias DidChooseValueHandler = (Choice) -> Void

    private let options: [Choice]
    private let chosen: Choice
    private let didChooseValue: DidChooseValueHandler

    private var chosenIndexPath: IndexPath? {
        guard let chosenIndexRow = options.firstIndex(where: { $0.description == chosen.description }) else {
            assertionFailure("The chosen value should be one of the options")
            return nil
        }
        return IndexPath(row: chosenIndexRow, section: 0)
    }

    init(title: String?, options: [Choice], chosen: Choice, didChooseValue: @escaping DidChooseValueHandler) {
        self.options = options
        self.chosen = chosen
        self.didChooseValue = didChooseValue
        super.init(style: .grouped)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(BasicCell.self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BasicCell = tableView.dequeueReusableCell(for: indexPath)

        cell.textLabel?.text = options[indexPath.row].description
        cell.accessoryType = indexPath == chosenIndexPath ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didChooseValue(options[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}

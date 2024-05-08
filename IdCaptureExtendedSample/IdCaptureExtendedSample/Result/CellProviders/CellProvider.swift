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

protocol CellProvider {
    var height: CGFloat { get }
    func dequeueAndConfigureCell(from tableView: UITableView) -> UITableViewCell
}

struct SimpleTextCellProvider: CellProvider {
    let value: String
    let title: String

    var height: CGFloat { return UITableView.automaticDimension }

    func dequeueAndConfigureCell(from tableView: UITableView) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeued = tableView.dequeueReusableCell(withIdentifier: "SimpleTextCell") {
            cell = dequeued
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SimpleTextCell")
        }

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = value
        cell.detailTextLabel?.text = title

        return cell
    }
}

struct ImageCellProvider: CellProvider {
    let image: UIImage?
    let title: String

    var height: CGFloat {

        guard let imageSize = image?.size else {
            return UITableView.automaticDimension
        }

        let screenSize = UIScreen.main.bounds.size
        let ratio = imageSize.height / imageSize.width

        // We keep 160 px for the label and some margins.
        return max((screenSize.width - 160) * ratio, 140)
    }

    func dequeueAndConfigureCell(from tableView: UITableView) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeued = tableView.dequeueReusableCell(withIdentifier: "ImageCell") {
            cell = dequeued
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ImageCell")
        }

        cell.detailTextLabel?.text = title
        cell.imageView?.image = image
        cell.imageView?.contentMode = .scaleToFill

        return cell
    }
}

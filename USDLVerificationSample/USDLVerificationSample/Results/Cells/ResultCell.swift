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

final class ResultCell: UITableViewCell, IdentifiableCell {
    typealias Result = DLScanningResultViewController.Result
    static var cellIdentifier: String { "Result" }

    var result: Result? {
        didSet { render(result) }
    }

    @IBOutlet private var resultView: UIView!
    @IBOutlet private var resultIconView: UIImageView!
    @IBOutlet private var resultLabel: UILabel!
    @IBOutlet private var idImageView: UIImageView!
    @IBOutlet private var altTextLabel: UILabel!

    private func render(_ result: Result?) {
        guard let result = result else { return }

        resultLabel.text = result.message
        idImageView.image = result.image
        idImageView.isHidden = result.image == nil
        altTextLabel.text = result.altText
        altTextLabel.isHidden = result.altText == nil

        switch result.status {
        case .success:
            resultView.backgroundColor = UIColor.greenBackground
            resultIconView.image = UIImage(named: "ok")
        case .error:
            resultView.backgroundColor = UIColor.redBackground
            resultIconView.image = UIImage(named: "error")
        case .info:
            resultView.backgroundColor = UIColor.yellowBackground
            resultIconView.image = UIImage(named: "info")
        }
    }
}

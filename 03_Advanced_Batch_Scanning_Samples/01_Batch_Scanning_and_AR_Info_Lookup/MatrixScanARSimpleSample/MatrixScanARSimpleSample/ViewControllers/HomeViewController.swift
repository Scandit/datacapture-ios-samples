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

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let itemsPerRow: CGFloat
        let spacing: CGFloat
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            itemsPerRow = 4
            spacing = 24
        default:
            itemsPerRow = 2
            spacing = 16
        }

        let itemSize = (collectionView.bounds.width - spacing * (itemsPerRow - 1)) / itemsPerRow
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let scanViewController = segue.destination as? ScanViewController,
            let cell = sender as? ConfigurationCell
        else { return }
        scanViewController.configuration = cell.configuration
    }

    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Configuration.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                as? ConfigurationCell
        else {
            fatalError("Could not dequeue cell")
        }
        cell.configure(with: Configuration.allCases[indexPath.item])
        return cell
    }
}

// MARK: Cell

class ConfigurationCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    private(set) var configuration: Configuration!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 8
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration

        iconView.image = configuration.icon
        titleLabel.text = configuration.title

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        subtitleLabel.attributedText = NSAttributedString(
            string: configuration.subtitle,
            attributes: [.paragraphStyle: paragraphStyle]
        )

    }
}

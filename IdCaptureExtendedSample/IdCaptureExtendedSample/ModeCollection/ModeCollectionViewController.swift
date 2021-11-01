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

protocol ModeCollectionViewControllerDelegate: AnyObject {

    func selectedItem(atIndex: Int)

}

final class ModeCollectionViewController: UICollectionViewController {

    var items: [String] = []

    weak var delegate: ModeCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ModeCell.self, forCellWithReuseIdentifier: "modeCell")
        collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.backgroundColor = nil
        view.backgroundColor = UIColor(red: 27/255, green: 32/255, blue: 38/255, alpha: 1)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "modeCell", for: indexPath) as! ModeCell
        cell.label.text = items[indexPath.row]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        delegate?.selectedItem(atIndex: indexPath.row)
    }

    func selectItem(atIndex index: Int) {
        collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .left)
    }

}

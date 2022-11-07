//
//  ItemsTableViewHeader.swift
//  ListBuildingSample
//
//  Created by Giuseppe Boi on 13/09/22.
//  Copyright © 2022 Scandit. All rights reserved.
//

import UIKit

class ItemsTableViewHeader: UIView {
    @IBOutlet private weak var label: UILabel!

    var itemsCount: Int? {
        didSet {
            label.text = "\(itemsCount ?? 0) items"
        }
    }
}

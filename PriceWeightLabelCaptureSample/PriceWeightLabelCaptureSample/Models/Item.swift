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

class Item {
    enum ItemType {
        case regular
        case weighted
    }
    let type: ItemType
    let data: String
    var weight: String?
    var unitPrice: String?
    var quantity: Int = 1

    static func createRegular(data: String) -> Item {
        Item(type: .regular, data: data)
    }

    static func createWeighted(data: String, weight: String?, unitPrice: String?) -> Item {
        Item(type: .weighted, data: data, weight: weight, unitPrice: unitPrice)
    }

    private init(type: ItemType, data: String, weight: String? = nil, unitPrice: String? = nil) {
        self.type = type
        self.data = data
        self.weight = weight
        self.unitPrice = unitPrice
    }
}

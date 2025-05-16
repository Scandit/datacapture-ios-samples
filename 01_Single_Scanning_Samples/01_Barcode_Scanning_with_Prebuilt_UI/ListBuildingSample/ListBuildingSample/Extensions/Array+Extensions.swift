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

extension Array where Element == Item {
    /// Returns all the indexPaths for the given array.
    var indexPaths: [IndexPath] {
        enumerated().map { current in
            .init(row: current.offset, section: 0)
        }
    }

    /// Returns the indexPath to be used for appending an element.
    var addItemIndexPath: IndexPath {
        // Add new items at the beginning of the array
        .init(row: 0, section: 0)
    }

    var totalCount: Int {
        reduce(0) { $0 + $1.quantity }
    }
}

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

extension Date {

    static var today: Date {
        return Calendar.current.startOfDay(for: Date())
    }

    var endOfDay: Date {
        let oneDay = DateComponents(day: 1)
        let tomorrow = Calendar.current.date(byAdding: oneDay, to: self)!
        return Calendar.current.startOfDay(for: tomorrow)
    }

    func yearsSince(_ other: Date) -> Int {
        let components = Calendar
            .current
            .dateComponents([.year],
                            from: self,
                            to: other)
        return components.year!

    }
}

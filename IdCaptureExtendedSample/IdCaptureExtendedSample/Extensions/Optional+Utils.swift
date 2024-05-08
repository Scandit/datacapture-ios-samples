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
import ScanditIdCapture

extension Optional where Wrapped == String {
    var valueOrNil: String {
        if let value = self, !value.isEmpty {
            return value
        }
        return "<nil>"
    }
}

extension Optional where Wrapped == NSNumber {
    var valueOrNil: String {
        if let value = self?.intValue {
            return String(value)
        }
        return "<nil>"
    }

    var optionalBooleanRepresentation: String {
        if let value = self?.boolValue {
            return value ? "YES" : "NO"
        } else {
            return "<nil>"
        }
    }
}

var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

extension DateResult {
    open override var description: String {
        return formatter.string(from: localDate)
    }
}

extension Optional where Wrapped == DateResult {
    var valueOrNil: String {
        if let value = self {
            return value.description
        }
        return "<nil>"
    }
}

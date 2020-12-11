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
import ScanditBarcodeCapture

protocol DataSourceDelegate: AnyObject {
    func didChangeData()

    func getFloatWithUnit(title: String?, currentValue: FloatWithUnit, completion: @escaping (FloatWithUnit) -> Void)

    func presentChoice<Choice: CustomStringConvertible>(title: String?,
                                                        options: [Choice],
                                                        chosen: Choice,
                                                        didChooseValue: @escaping (Choice) -> Void)

    func presentSymbologySettings(currentSettings: SymbologySettings,
                                  didChangeValue: @escaping (SymbologySettings) -> Void)
}

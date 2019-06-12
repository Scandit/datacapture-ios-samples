/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import ScanditBarcodeCapture

extension Brush {
    static let red = Brush(fill: UIColor.red.withAlphaComponent(0.2), stroke: .red, strokeWidth: 1)
    static let green = Brush(fill: UIColor.green.withAlphaComponent(0.2), stroke: .green, strokeWidth: 1)

    open override var description: String {
        switch strokeColor {
        case .red: return "Red"
        case .green: return "Green"
        default: return "Default"
        }
    }
}

class OverlayDataSource: DataSource {

    static let brushes: [Brush] = [SettingsManager.current.defaultBrush, Brush.red, Brush.green]

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections

    lazy var sections: [Section] = {
        return [Section(rows: [
            Row.choice(title: "Brush",
                       options: OverlayDataSource.brushes,
                       getValue: { SettingsManager.current.brush },
                       didChangeValue: { SettingsManager.current.brush = $0 },
                       dataSourceDelegate: self.delegate)
        ])]
    }()
}

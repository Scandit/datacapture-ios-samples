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

import ScanditIdCapture

private struct ScannerSettings: Codable {
    enum ScanningMode: Int, Codable, CaseIterable, CustomStringConvertible {
        case single
        case full

        var description: String {
            switch self {
            case .single: return "Single"
            case .full: return "Full"
            }
        }
    }

    struct SingleSideFeatures: Codable {
        var barcode = false
        var machineReadableZone = false
        var visualInspectionZone = false
    }

    var enabledFeatures = SingleSideFeatures()
    var mode: ScanningMode = .full

    var scanner: IdCaptureScanner {
        switch mode {
        case .single:
            return SingleSideScanner(
                enablingBarcode: enabledFeatures.barcode,
                machineReadableZone: enabledFeatures.machineReadableZone,
                visualInspectionZone: enabledFeatures.visualInspectionZone
            )
        case .full:
            return FullDocumentScanner()
        }
    }
}

class ScannerTypeDataSource: DataSource {
    weak var delegate: DataSourceDelegate?
    private var scannerSettings = ScannerSettings()

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
        if let single = SettingsManager.current.scannerType as? SingleSideScanner {
            self.scannerSettings.mode = .single
            self.scannerSettings.enabledFeatures.barcode = single.barcode
            self.scannerSettings.enabledFeatures.machineReadableZone = single.machineReadableZone
            self.scannerSettings.enabledFeatures.visualInspectionZone = single.visualInspectionZone
        }
    }

    // MARK: - Sections

    var sections: [Section] {
        if self.scannerSettings.mode == .full {
            return [scannerType]
        }
        return [scannerType, singleSideOptions]
    }

    lazy var scannerType: Section = {
        let rows: [Row] = ScannerSettings.ScanningMode.allCases.map { scanningMode in
            Row.option(
                title: scanningMode.description,
                getValue: { self.scannerSettings.mode == scanningMode },
                didSelect: { [self] _, _ in
                    scannerSettings.mode = scanningMode
                    updateSettings()
                },
                dataSourceDelegate: self.delegate
            )
        }
        return Section(rows: rows)
    }()

    lazy var singleSideOptions: Section = {
        Section(rows: [
            Row(
                title: "Barcode",
                kind: .switch,
                getValue: { self.scannerSettings.enabledFeatures.barcode },
                didChangeValue: { value, _, _ in
                    self.scannerSettings.enabledFeatures.barcode = value
                    self.updateSettings()
                }
            ),
            Row(
                title: "Machine Readable Zone",
                kind: .switch,
                getValue: { self.scannerSettings.enabledFeatures.machineReadableZone },
                didChangeValue: { value, _, _ in
                    self.scannerSettings.enabledFeatures.machineReadableZone = value
                    self.updateSettings()
                }
            ),
            Row(
                title: "Visual Inspection Zone",
                kind: .switch,
                getValue: { self.scannerSettings.enabledFeatures.visualInspectionZone },
                didChangeValue: { value, _, _ in
                    self.scannerSettings.enabledFeatures.visualInspectionZone = value
                    self.updateSettings()
                }
            ),
        ])
    }()

    private func updateSettings() {
        SettingsManager.current.scannerType = scannerSettings.scanner
        delegate?.didChangeData()
    }
}

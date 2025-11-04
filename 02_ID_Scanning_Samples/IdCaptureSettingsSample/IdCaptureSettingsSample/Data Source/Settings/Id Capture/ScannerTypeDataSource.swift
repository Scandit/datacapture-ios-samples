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

    struct MobileFeatures: Codable {
        var iso18013 = false
        var ocr = false
    }

    var enabledFeatures = SingleSideFeatures()
    var mobileFeatures = MobileFeatures()
    var mode: ScanningMode = .full

    var scanner: IdCaptureScanner {
        let physicalScanner: PhysicalDocumentScanner
        switch mode {
        case .single:
            physicalScanner = SingleSideScanner(
                enablingBarcode: enabledFeatures.barcode,
                machineReadableZone: enabledFeatures.machineReadableZone,
                visualInspectionZone: enabledFeatures.visualInspectionZone
            )
        case .full:
            physicalScanner = FullDocumentScanner()
        }

        let mobileScanner = MobileDocumentScanner(
            enablingIso180135: mobileFeatures.iso18013,
            ocr: mobileFeatures.ocr,
            elementsToRetain: SettingsManager.current.elementsToRetain
        )

        return IdCaptureScanner(physicalDocument: physicalScanner, mobileDocument: mobileScanner)
    }
}

class ScannerTypeDataSource: DataSource {
    weak var delegate: DataSourceDelegate?
    private var scannerSettings = ScannerSettings()

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
        let idCaptureScanner = SettingsManager.current.scanner
        if let single = idCaptureScanner.physicalDocument as? SingleSideScanner {
            self.scannerSettings.mode = .single
            self.scannerSettings.enabledFeatures.barcode = single.barcode
            self.scannerSettings.enabledFeatures.machineReadableZone = single.machineReadableZone
            self.scannerSettings.enabledFeatures.visualInspectionZone = single.visualInspectionZone
        }
        let mobile = idCaptureScanner.mobileDocument
        self.scannerSettings.mobileFeatures.iso18013 = mobile.iso180135
        self.scannerSettings.mobileFeatures.ocr = mobile.ocr
    }

    // MARK: - Sections

    var sections: [Section] {
        if self.scannerSettings.mode == .full {
            return [scannerType, mobileOptions]
        }
        return [scannerType, singleSideOptions, mobileOptions]
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
        return Section(title: "Physical Document Scanner", rows: rows)
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

    lazy var mobileOptions: Section = {
        Section(
            title: "Mobile Document Scanner",
            rows: [
                Row(
                    title: "ISO 18013-5",
                    kind: .switch,
                    getValue: { self.scannerSettings.mobileFeatures.iso18013 },
                    didChangeValue: { value, _, _ in
                        self.scannerSettings.mobileFeatures.iso18013 = value
                        self.updateSettings()
                    }
                ),
                Row(
                    title: "OCR",
                    kind: .switch,
                    getValue: { self.scannerSettings.mobileFeatures.ocr },
                    didChangeValue: { value, _, _ in
                        self.scannerSettings.mobileFeatures.ocr = value
                        self.updateSettings()
                    }
                ),
                Row(
                    title: "Elements to Retain",
                    kind: .action,
                    didSelect: { [weak delegate] _, _ in
                        delegate?.present {
                            ElementsToRetainTableViewController()
                        }
                    }
                ),
            ]
        )
    }()

    private func updateSettings() {
        SettingsManager.current.scanner = scannerSettings.scanner
        delegate?.didChangeData()
    }
}

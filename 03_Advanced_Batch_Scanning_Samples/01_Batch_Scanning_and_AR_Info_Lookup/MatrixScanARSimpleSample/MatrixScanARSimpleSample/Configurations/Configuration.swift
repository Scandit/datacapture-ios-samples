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
import ScanditBarcodeCapture

enum Configuration: CaseIterable {
    case highlights
    case infoAnnotations
    case popovers
    case statusIcons

    var title: String {
        switch self {
        case .highlights:
            "Highlights"
        case .infoAnnotations:
            "Info Annotations"
        case .popovers:
            "Popovers"
        case .statusIcons:
            "Status Icons"
        }
    }

    var subtitle: String {
        switch self {
        case .highlights:
            "Visualize scanned codes"
        case .infoAnnotations:
            "Show additional information"
        case .popovers:
            "Take action on scanned codes"
        case .statusIcons:
            "Provide short information"
        }
    }

    var icon: UIImage {
        switch self {
        case .highlights:
            UIImage.highlights
        case .infoAnnotations:
            UIImage.infoAnnotations
        case .popovers:
            UIImage.popovers
        case .statusIcons:
            UIImage.statusIcons
        }
    }

    var handler: ConfigurationHandler {
        switch self {
        case .highlights:
            HighlightsConfigurationHandler()
        case .infoAnnotations:
            InfoAnnotationsConfigurationHandler()
        case .popovers:
            PopoversConfigurationHandler()
        case .statusIcons:
            StatusIconsConfigurationHandler()
        }
    }
}

protocol ConfigurationHandler {
    func apply(to barcodeArView: BarcodeArView)
}

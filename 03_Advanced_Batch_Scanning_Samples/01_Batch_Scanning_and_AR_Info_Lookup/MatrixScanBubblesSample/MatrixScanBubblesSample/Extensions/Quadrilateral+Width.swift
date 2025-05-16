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

import ScanditCaptureCore

extension Quadrilateral {
    func width(in view: DataCaptureView) -> CGFloat {
        // In order to obtain the coordinates of a barcode we need to convert the quadrilateral
        // that contains it from the FrameSource coordinate system into the DataCaptureView's coordinate system
        // using viewQuadrilateral(forFrameQuadrilateral:)
        // You can check https://docs.scandit.com/data-capture-sdk/android/add-augmented-reality-overlay.html
        // for more information about overlays, views and coordinates.
        let viewFrame = view.viewQuadrilateral(forFrameQuadrilateral: self)

        // We then return the maximum width between two opposite corners of the quadrilateral as the width
        return max(
            viewFrame.bottomRight.x - viewFrame.bottomLeft.x,
            viewFrame.topRight.x - viewFrame.topLeft.x
        )
    }
}

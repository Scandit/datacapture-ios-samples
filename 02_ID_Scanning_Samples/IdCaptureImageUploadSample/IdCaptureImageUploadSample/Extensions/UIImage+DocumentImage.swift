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

import UIKit

/// Turns picked files into bitmap-backed images suitable for an `ImageFrameSource`.
///
/// The messy CoreGraphics / orientation details live here so call sites can just ask for a
/// `UIImage`.
extension UIImage {

    /// Longest-side cap applied to decoded images to bound memory; very large photos and PDF pages are
    /// downscaled to fit. 4096 px keeps ample resolution for the documents this sample scans.
    static let documentMaxDimension: CGFloat = 4096

    /// Loads an orientation-normalised, bitmap-backed image from a picked image file URL.
    /// Returns `nil` if the file cannot be read or decoded.
    static func fromImageFile(at url: URL) -> UIImage? {
        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }

        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return nil
        }
        return image.normalizedForScanning()
    }

    /// Redraws the image upright (baking in any EXIF orientation) into a `CGImage`-backed bitmap,
    /// downscaled so the longest side does not exceed `documentMaxDimension`.
    func normalizedForScanning() -> UIImage {
        let longestSide = max(size.width, size.height)
        let scale = longestSide > UIImage.documentMaxDimension ? UIImage.documentMaxDimension / longestSide : 1
        let target = CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }

    // MARK: - PDF

    /// Number of pages in the PDF at `url`, or 0 if it cannot be opened.
    static func pdfPageCount(at url: URL) -> Int {
        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }
        guard let document = CGPDFDocument(url as CFURL) else { return 0 }
        return document.numberOfPages
    }

    /// Rasterises one page of a PDF into a white-backed, bitmap-backed image suitable for scanning.
    /// `pageIndex` is zero-based. Returns `nil` if the file or page cannot be read.
    static func fromPDF(at url: URL, pageIndex: Int = 0) -> UIImage? {
        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }

        guard let document = CGPDFDocument(url as CFURL),
            pageIndex >= 0, pageIndex < document.numberOfPages,
            // CGPDFDocument pages are 1-based.
            let page = document.page(at: pageIndex + 1)
        else {
            return nil
        }
        return render(pdfPage: page)
    }

    private static func render(pdfPage page: CGPDFPage) -> UIImage {
        let pageRect = page.getBoxRect(.mediaBox)
        let longestSide = max(pageRect.width, pageRect.height)
        // PDF user space is 72 DPI; target ~200 DPI but never exceed documentMaxDimension.
        let scale = min(200.0 / 72.0, documentMaxDimension / longestSide)
        let target = CGSize(width: (pageRect.width * scale).rounded(), height: (pageRect.height * scale).rounded())

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: target, format: format).image { context in
            let cgContext = context.cgContext
            // PDF pages can be transparent; render onto white for reliable document detection.
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: target))
            // Flip to PDF's bottom-left origin and scale into the target bitmap.
            cgContext.translateBy(x: 0, y: target.height)
            cgContext.scaleBy(x: scale, y: -scale)
            cgContext.translateBy(x: -pageRect.origin.x, y: -pageRect.origin.y)
            cgContext.drawPDFPage(page)
        }
    }
}

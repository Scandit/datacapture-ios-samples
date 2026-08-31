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

import PhotosUI
import UIKit
import UniformTypeIdentifiers

/// Lets the user pick a document from Photos (images) or Files (images or PDFs) and reports the
/// chosen document rendered to image(s) via a completion closure — one image for a photo or image
/// file, one per page (front, then back) for a PDF. Communicating only through the closure keeps the
/// picker free of any view-controller state.
final class DocumentPicker: NSObject {

    /// The outcome of a pick. `.images` carries one image for a photo/image/single-page PDF and two
    /// for a two-page PDF (front, back). A cancelled pick produces no callback.
    enum Picked {
        case images([UIImage])
        case unreadable
        case emptyPDF
    }

    private var completion: ((Picked) -> Void)?
    private weak var presenter: UIViewController?

    /// Presents the source chooser and calls `completion` once the user picks (not on cancel).
    /// `source` anchors the action-sheet popover on iPad.
    func present(from viewController: UIViewController, source: UIView, completion: @escaping (Picked) -> Void) {
        self.completion = completion
        self.presenter = viewController

        let sheet = UIAlertController(title: "Add document", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Photos", style: .default) { [weak self] _ in self?.presentPhotoPicker() })
        sheet.addAction(
            UIAlertAction(title: "Files", style: .default) { [weak self] _ in self?.presentDocumentPicker() }
        )
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in self?.completion = nil })
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = source
            popover.sourceRect = source.bounds
        }
        viewController.present(sheet, animated: true)
    }

    /// Renders a picked file to image(s): one per PDF page, or a single decoded image otherwise.
    static func images(from url: URL) -> Picked {
        guard url.pathExtension.lowercased() == "pdf" else {
            return UIImage.fromImageFile(at: url).map { .images([$0]) } ?? .unreadable
        }
        let pageCount = UIImage.pdfPageCount(at: url)
        guard pageCount > 0 else { return .emptyPDF }
        guard let front = UIImage.fromPDF(at: url, pageIndex: 0) else { return .unreadable }
        var images = [front]
        // A multi-page PDF carries the back side as its second page.
        if pageCount >= 2, let back = UIImage.fromPDF(at: url, pageIndex: 1) { images.append(back) }
        return .images(images)
    }

    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        presenter?.present(picker, animated: true)
    }

    private func presentDocumentPicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        presenter?.present(picker, animated: true)
    }

    private func finish(_ picked: Picked) {
        let completion = self.completion
        self.completion = nil
        completion?(picked)
    }
}

extension DocumentPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        finish(Self.images(from: url))
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion = nil
    }
}

extension DocumentPicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else {
            completion = nil  // cancelled
            return
        }
        let imageType = UTType.image.identifier
        guard provider.hasItemConformingToTypeIdentifier(imageType) else {
            finish(.unreadable)
            return
        }
        // Load the file representation rather than a decoded `UIImage`, so this sample controls the
        // orientation and downscaling itself. The URL is valid only inside this closure, so decode
        // here before hopping to the main queue.
        provider.loadFileRepresentation(forTypeIdentifier: imageType) { [weak self] url, _ in
            let picked = url.map { Self.images(from: $0) } ?? .unreadable
            DispatchQueue.main.async { self?.finish(picked) }
        }
    }
}

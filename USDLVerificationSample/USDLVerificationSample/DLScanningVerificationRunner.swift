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
import ScanditIdCapture

private extension CapturedId {
    var isExpired: Bool? {
        guard let expiryDate = dateOfExpiry?.localDate else { return nil }
        return expiryDate < Date()
    }
}

struct DLScanningVerificationResult {
    enum Status {
        case frontBackDoesNotMatch
        case expired
        case forged
        case likelyForged
        case success
    }

    let status: Status
    let image: UIImage?
    let altText: String?
}

extension DLScanningVerificationResult {
    init(status: Status) {
        self.status = status
        self.image = nil
        self.altText = nil
    }
}

final class DLScanningVerificationRunner {
    typealias Result = Swift.Result<DLScanningVerificationResult, Error>

    let barcodeVerifier: AamvaBarcodeVerifier
    let vizBarcodeComparisonVerifier: AAMVAVizBarcodeComparisonVerifier

    init(_ context: DataCaptureContext) {
        self.barcodeVerifier = AamvaBarcodeVerifier(context: context)
        self.vizBarcodeComparisonVerifier = AAMVAVizBarcodeComparisonVerifier(context: context)
    }

    func verify(capturedId: CapturedId, _ completion: @escaping (Result) -> Void) {
        // This function is main entry point for this class.

        // We first check if the front and back scanning results match
        let vizBarcodeComparisonResult = vizBarcodeComparisonVerifier.verify(capturedId)
        guard vizBarcodeComparisonResult.checksPassed else {
            let mismatchImage = vizBarcodeComparisonResult.frontMismatchImage
            let showWarning = !vizBarcodeComparisonResult.mismatchHighlightingEnabled
            let warningText = showWarning ? "Your license does not support highlighting discrepancies" : nil
            completion(.success(DLScanningVerificationResult(status: .frontBackDoesNotMatch,
                                                             image: mismatchImage,
                                                             altText: warningText)))
            return
        }

        // If the document is expired verification will fail. We return eagerly for this case as well.
        guard capturedId.isExpired == nil || !capturedId.isExpired! else {
            completion(.success(DLScanningVerificationResult(status: .expired)))
            return
        }

        // Document looks valid on local validations. Now we can start a verification process.
        runAAMVABarcodeVerification(capturedId, completion)
    }

    private func runAAMVABarcodeVerification(
        _ capturedId: CapturedId,
        _ completion: @escaping (Result) -> Void
    ) {
            barcodeVerifier.verify(capturedId) { result, error in
            if let result = result {
                switch result.status {
                case AamvaBarcodeVerificationStatus.authentic:
                    completion(.success(DLScanningVerificationResult(status: .success)))
                case AamvaBarcodeVerificationStatus.likelyForged:
                    completion(.success(DLScanningVerificationResult(status: .likelyForged)))
                case AamvaBarcodeVerificationStatus.forged:
                    completion(.success(DLScanningVerificationResult(status: .forged)))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}


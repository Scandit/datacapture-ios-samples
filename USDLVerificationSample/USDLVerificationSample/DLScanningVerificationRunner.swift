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

import ScanditCaptureCore
import ScanditIdCapture

private extension CapturedId {
    var isExpired: Bool {
        guard let expiryDate = dateOfExpiry?.date else { return false }
        return expiryDate < Date()
    }
}

enum DLScanningVerificationResult {
    case frontBackDoesNotMatch
    case expired
    case cloudVerificationFailed
    case success
}

final class DLScanningVerificationRunner {
    typealias Result = Swift.Result<DLScanningVerificationResult, Error>

    let context: DataCaptureContext

    init(_ context: DataCaptureContext) {
        self.context = context
    }

    func verify(capturedId: CapturedId, _ completion: @escaping (Result) -> Void) {
        // This function is main entry point for this class.
        // We first check if the front and back scanning results match
        guard doesFrontAndBackMatch(capturedId) else {
            // If the front and back does not match cloud verification will fail. We return eagerly for this case.
            completion(.success(.frontBackDoesNotMatch))
            return
        }

        // If the document is expired cloud verification will fail. We return easerly for this case as well.
        guard !capturedId.isExpired else {
            completion(.success(.expired))
            return
        }

        // Document looks valid on local validations. Now we can start a cloud verification process.
        runAAMVACloudVerification(capturedId, completion)
    }

    private func doesFrontAndBackMatch(_ capturedId: CapturedId) -> Bool {
        return AAMVAVizBarcodeComparisonVerifier().verify(capturedId).checksPassed
    }

    private func runAAMVACloudVerification(
        _ capturedId: CapturedId,
        _ completion: @escaping (Result) -> Void
    ) {
        AamvaCloudVerifier(context: context)
            .verify(capturedId) { result, error in
            if let result = result {
                if result.allChecksPassed {
                    completion(.success(.success))
                } else {
                    completion(.success(.cloudVerificationFailed))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}

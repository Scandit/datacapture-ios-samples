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

extension SettingsManager {

    var supportedDocuments: IdDocumentType {
        get {
            idCaptureSettings.supportedDocuments
        }
        set {
            idCaptureSettings.supportedDocuments = newValue
            configure()
        }
    }

    var supportedSides: SupportedSides {
        get {
            idCaptureSettings.supportedSides
        }
        set {
            idCaptureSettings.supportedSides = newValue
            configure()
        }
    }

    var anonymizationMode: IdAnonymizationMode {
        get {
            idCaptureSettings.anonymizationMode
        }
        set {
            idCaptureSettings.anonymizationMode = newValue
            configure()
        }
    }

    var resultWithImageTypes: Set<IdImageType> {
        get {
            let imageTypes = IdImageType.allCases.filter { idCaptureSettings.resultShouldContainImage(for: $0)}
            return Set<IdImageType>(imageTypes)
        }
        set {
            for type in IdImageType.allCases {
                idCaptureSettings.resultShouldContainImage(newValue.contains(type), for: type)
                configure()
            }
        }
    }

    var rejectVoidedIds: Bool {
        get {
            return idCaptureSettings.rejectVoidedIds
        }
        set {
            idCaptureSettings.rejectVoidedIds = newValue
            configure()
        }
    }

    var decodeBackOfEuropeanDrivingLicense: Bool {
        get {
            return idCaptureSettings.decodeBackOfEuropeanDrivingLicense
        }
        set {
            idCaptureSettings.decodeBackOfEuropeanDrivingLicense = newValue
            configure()
        }
    }

    var idCapturedFeedback: Feedback {
        get {
            idCaptureFeedback.idCaptured
        }

        set {
            idCaptureFeedback.idCaptured = newValue
            updateFeedback()
        }
    }

    var idRejectedFeedback: Feedback {
        get {
            idCaptureFeedback.idRejected
        }

        set {
            idCaptureFeedback.idRejected = newValue
            updateFeedback()
        }
    }

    var idCaptureTimeoutFeedback: Feedback {
        get {
            idCaptureFeedback.idCaptureTimeout
        }

        set {
            idCaptureFeedback.idCaptureTimeout = newValue
            updateFeedback()
        }
    }

    func updateFeedback() {
        idCapture.feedback = idCaptureFeedback
    }
}

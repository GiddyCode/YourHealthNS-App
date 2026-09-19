struct LabReport: Equatable, Sendable {
    let name: String?
    let status: ClinicalStatus
    let performers: [Performer]
    let effective: ClinicalDate?
    let issued: String?
    let results: [LabResult]

    struct Performer: Equatable, Sendable {
        let name: String?
    }

    var unavailableResultCount: Int {
        results.filter { $0.value.isUnavailable }.count
    }
}

enum ReportOutcome: Equatable, Sendable {
    case noReport
    case report(LabReport)
}

enum ClinicalStatus: String, Equatable, Sendable {
    case registered, partial, preliminary, final, amended, corrected, appended
    case cancelled, unknown
    case enteredInError = "entered-in-error"

    var permitsMeasurements: Bool {
        switch self {
        case .partial, .preliminary, .final, .amended, .corrected, .appended: true
        case .registered, .cancelled, .enteredInError, .unknown: false
        }
    }
}

/// Retains the source date precision and UTC offset.
enum ClinicalDate: Equatable, Sendable {
    case dateTime(String)
    case period(start: String?, end: String?)
}

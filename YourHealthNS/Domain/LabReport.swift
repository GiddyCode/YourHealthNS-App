import Foundation

struct LabReport: Equatable, Sendable {
    let name: String
    let status: ClinicalStatus
    let performers: [String]
    let effective: ClinicalDate?
    let issued: String?
    let results: [LabResult]

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

struct LabResult: Identifiable, Equatable, Sendable {
    /// Position in DiagnosticReport.result, including unresolved references.
    let id: Int
    let name: String
    let status: ClinicalStatus?
    let value: ClinicalValue
    let referenceRanges: [ClinicalReferenceRange]
    let interpretations: [String]
}

enum ClinicalValue: Equatable, Sendable {
    case quantity(ClinicalQuantity)
    case text(String)
    case boolean(Bool)
    case integer(Int32)
    case dateTime(String)
    case time(String)
    case period(start: String?, end: String?)
    case absent(reason: String?)
    case unavailable(ResultUnavailableReason)

    var isUnavailable: Bool {
        switch self {
        case .absent, .unavailable: true
        default: false
        }
    }
}

struct ClinicalQuantity: Equatable, Sendable {
    let value: Decimal
    let comparator: String?
    let unit: String?
    let unitCode: String?
    let unitSystem: String?
}

struct ClinicalReferenceRange: Equatable, Sendable {
    let low: ClinicalQuantity?
    let high: ClinicalQuantity?
    let text: String?
    let kind: String?
    let appliesTo: [String]
    let ageLow: ClinicalQuantity?
    let ageHigh: ClinicalQuantity?
}

enum ResultUnavailableReason: Equatable, Sendable {
    case unresolvedReference
    case ambiguousReference
    case wrongResourceType
    case conflictingSubject
    case restrictedStatus
    case unsupportedModifier
    case unsupportedValue
    case groupedResult
    case inconsistentValue
}

protocol ReportRepository: Sendable {
    func fetchReport() async throws -> ReportOutcome
}

enum ReportDataError: Error, Equatable, Sendable {
    case invalidPayload
    case unsupportedBundle
    case multipleReports
    case unsupportedReportModifier
}

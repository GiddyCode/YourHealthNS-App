protocol ReportRepository: Sendable {
    func fetchReport() async throws -> ReportOutcome
}

enum ReportFailure: Error, Equatable, Sendable {
    case offline
    case timedOut
    case invalidReport
    case serviceUnavailable
}

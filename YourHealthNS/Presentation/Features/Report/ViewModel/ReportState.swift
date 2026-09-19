enum ReportState: Equatable {
    enum Refresh: Equatable {
        case idle
        case loading
        case updated
        case failed(ReportFailure)
    }

    case idle
    case loading
    case loaded(ReportOutcome, refresh: Refresh = .idle)
    case failed(ReportFailure)

    var outcome: ReportOutcome? {
        guard case .loaded(let outcome, _) = self else { return nil }
        return outcome
    }

    var report: LabReport? {
        guard case .report(let report) = outcome else { return nil }
        return report
    }

    var refresh: Refresh {
        guard case .loaded(_, let refresh) = self else { return .idle }
        return refresh
    }

    var isRequestInFlight: Bool {
        self == .loading || refresh == .loading
    }
}

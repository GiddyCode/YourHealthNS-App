import Combine
import Foundation

@MainActor
final class ReportViewModel: ObservableObject {
    @Published private(set) var state: ReportState = .idle
    private let repository: any ReportRepository

    init(repository: any ReportRepository) {
        self.repository = repository
    }

    func load(refresh: Bool = false) async {
        // Keep one request in flight across both tabs.
        guard !state.isRequestInFlight, refresh || state == .idle else { return }

        let previous = state
        if let outcome = state.outcome {
            state = .loaded(outcome, refresh: .loading)
        } else {
            state = .loading
        }

        do {
            let outcome = try await repository.fetchReport()
            try Task.checkCancellation()
            state = .loaded(outcome, refresh: refresh ? .updated : .idle)
        } catch {
            if Task.isCancelled || error is CancellationError {
                state = previous
            } else {
                let failure = error as? ReportFailure ?? .serviceUnavailable
                if let outcome = previous.outcome {
                    state = .loaded(outcome, refresh: .failed(failure))
                } else {
                    state = .failed(failure)
                }
            }
        }
    }
}

import Combine
import Foundation

@MainActor
final class ReportViewModel: ObservableObject {
    enum Content {
        case idle
        case loading
        case loaded(ReportOutcome)
        case failed(String)
    }

    struct State {
        var content: Content = .idle
        var isRefreshing = false
        var refreshMessage: String?
    }

    @Published private(set) var state = State()
    private let repository: any ReportRepository

    init(repository: any ReportRepository) {
        self.repository = repository
    }

    func load(refresh: Bool = false) async {
        // Keep one request in flight across both tabs.
        guard !state.isRefreshing else { return }
        switch state.content {
        case .loading: return
        case .loaded, .failed:
            if !refresh { return }
        default: break
        }

        let previous = state
        if case .loaded = state.content {
            state = State(content: state.content, isRefreshing: true)
        } else {
            state = State(content: .loading)
        }

        do {
            let outcome = try await repository.fetchReport()
            try Task.checkCancellation()
            state = State(content: .loaded(outcome), refreshMessage: refresh ? "Report updated." : nil)
        } catch {
            if Task.isCancelled || error is CancellationError || (error as? URLError)?.code == .cancelled {
                state = previous
            } else if case .loaded = previous.content {
                state = State(content: previous.content, refreshMessage: "Couldn't refresh. Showing the previous report. " + message(for: error))
            } else {
                state = State(content: .failed(message(for: error)))
            }
        }
    }

    private func message(for error: Error) -> String {
        if let error = error as? URLError {
            switch error.code {
            case .notConnectedToInternet: return "You're offline. Check your connection and try again."
            case .timedOut: return "The request timed out. Please try again."
            default: return "Couldn't connect to the laboratory service. Please try again."
            }
        }
        if error is ReportDataError {
            return "The report couldn't be read. Please try again later."
        }
        return "The laboratory service couldn't provide a report. Please try again."
    }
}

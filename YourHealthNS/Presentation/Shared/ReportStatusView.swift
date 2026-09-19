import SwiftUI

struct ReportStatusView: View {
    let state: ReportState
    let formatter: ReportFormatting
    let retry: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.regular) {
            switch state {
            case .idle:
                Label("Load your report", systemImage: "doc.text")
                    .font(.headline)
                retryButton
            case .loading:
                ReportLoadingView()
            case .failed(let failure):
                Label("We couldn't load the report", systemImage: "wifi.exclamationmark")
                    .font(.headline)
                Text(formatter.failure(failure))
                    .foregroundStyle(HealthTheme.secondaryText)
                retryButton
            case .loaded(.noReport, _):
                ReportEmptyState()
                retryButton
            case .loaded(.report, _):
                EmptyView()
            }
        }
        .foregroundStyle(HealthTheme.primaryText)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var retryButton: some View {
        Button(state == .idle ? "Load report" : "Try again") {
            Task { await retry() }
        }
        .buttonStyle(HealthPrimaryButtonStyle())
        .disabled(state.isRequestInFlight)
        .accessibilityIdentifier("report.retry")
    }
}

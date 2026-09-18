import SwiftUI

struct ReportStatusView: View {
    let content: ReportViewModel.Content
    let retry: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.regular) {
            switch content {
            case .idle, .loading:
                ProgressView("Retrieving your report")
                    .tint(HealthTheme.action)
                Text("Connecting securely to the laboratory service…")
                    .font(.subheadline)
                    .foregroundStyle(HealthTheme.secondaryText)
            case .failed(let message):
                Label("We couldn't load the report", systemImage: "wifi.exclamationmark")
                    .font(.headline)
                Text(message)
                    .foregroundStyle(HealthTheme.secondaryText)
                retryButton
            case .loaded(.noReport):
                ReportEmptyState()
                retryButton
            case .loaded(.report):
                EmptyView()
            }
        }
        .foregroundStyle(HealthTheme.primaryText)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var retryButton: some View {
        Button("Try again") {
            Task { await retry() }
        }
        .buttonStyle(HealthPrimaryButtonStyle())
        .accessibilityIdentifier("report.retry")
    }
}

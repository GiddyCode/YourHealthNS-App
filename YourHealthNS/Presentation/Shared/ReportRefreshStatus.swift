import SwiftUI

struct ReportRefreshStatus: View {
    let status: ReportState.Refresh
    let formatter: ReportFormatting

    var body: some View {
        if status == .loading {
            ProgressView("Refreshing report…")
                .tint(HealthTheme.action)
        } else if let message = formatter.refreshMessage(status) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(HealthTheme.secondaryText)
        }
    }
}

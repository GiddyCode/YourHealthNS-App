import SwiftUI

struct ReportSummaryView: View {
    let report: LabReport

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.regular) {
            Image("Microscope")
                .resizable()
                .scaledToFit()
                .frame(width: HealthTheme.microscopeSize, height: HealthTheme.microscopeSize)
                .background(.white, in: RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                .clipShape(RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                .accessibilityHidden(true)

            Text(report.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(HealthTheme.primaryText)
                .accessibilityAddTraits(.isHeader)
            Text(ReportFormatting.status(report.status))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(HealthTheme.primaryText)
                .padding(.horizontal, HealthTheme.Space.medium)
                .padding(.vertical, HealthTheme.Space.small)
                .background(HealthTheme.border, in: Capsule())

            Label(report.performers.isEmpty ? "Performer unavailable" : report.performers.joined(separator: ", "), systemImage: "building.2")
            Label(ReportFormatting.effective(report.effective), systemImage: "calendar")
        }
        .font(.subheadline)
        .foregroundStyle(HealthTheme.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ReportRefreshStatus: View {
    let state: ReportViewModel.State

    var body: some View {
        if state.isRefreshing {
            ProgressView("Refreshing report…")
                .tint(HealthTheme.action)
        } else if let message = state.refreshMessage {
            Text(message)
                .font(.footnote)
                .foregroundStyle(HealthTheme.secondaryText)
        }
    }
}

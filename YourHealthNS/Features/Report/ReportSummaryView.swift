import SwiftUI

struct ReportSummaryView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let report: LabReport
    var horizontal = false

    var body: some View {
        let layout = horizontal && !dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(HStackLayout(alignment: .top, spacing: HealthTheme.Space.regular))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: HealthTheme.Space.regular))

        layout {
            Image("Microscope")
                .resizable()
                .scaledToFit()
                .frame(width: HealthTheme.microscopeSize, height: HealthTheme.microscopeSize)
                .background(.white, in: RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                .clipShape(RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                Text(report.name)
                    .font(horizontal ? .headline : .title3.weight(.semibold))
                    .foregroundStyle(HealthTheme.primaryText)
                    .accessibilityAddTraits(.isHeader)
                ReportBadge(text: ReportFormatting.status(report.status), tint: report.status == .final ? .green : HealthTheme.action)

                Label(report.performers.isEmpty ? "Performer unavailable" : report.performers.joined(separator: ", "), systemImage: "building.2")
                Label(ReportFormatting.effective(report.effective), systemImage: "calendar")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
        .foregroundStyle(HealthTheme.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ReportBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, HealthTheme.Space.medium)
            .padding(.vertical, HealthTheme.Space.small)
            .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: HealthTheme.Radius.control))
            .background {
                if tint == .black && colorScheme == .dark {
                    RoundedRectangle(cornerRadius: HealthTheme.Radius.control)
                        .fill(.white.opacity(0.85))
                }
            }
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

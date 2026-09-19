import SwiftUI

struct ReportSummaryView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let report: LabReport
    let formatter: ReportFormatting
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
                Text(formatter.reportName(report))
                    .font(horizontal ? .headline : .title3.weight(.semibold))
                    .foregroundStyle(HealthTheme.primaryText)
                    .accessibilityAddTraits(.isHeader)
                ReportBadge(text: formatter.status(report.status), style: report.status == .final ? .positive : .informational)

                Label(formatter.performers(report.performers), systemImage: "building.2")
                Label(formatter.effective(report.effective), systemImage: "calendar")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
        .foregroundStyle(HealthTheme.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
}

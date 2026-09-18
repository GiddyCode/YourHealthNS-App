import SwiftUI

struct HomeView: View {
    @ObservedObject var model: ReportViewModel
    let openReport: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HealthTheme.Space.section) {
                VStack(alignment: .leading, spacing: HealthTheme.Space.large) {
                    BrandWordmark()

                    VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                        Text("Your lab report")
                            .font(.largeTitle.bold())
                            .foregroundStyle(HealthTheme.primaryText)
                            .accessibilityAddTraits(.isHeader)
                        Text("A clear view of your hematology results.")
                            .font(.body)
                            .foregroundStyle(HealthTheme.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: HealthTheme.Space.large) {
                    Text("Latest report")
                        .font(.headline)
                        .foregroundStyle(HealthTheme.primaryText)
                        .accessibilityAddTraits(.isHeader)

                    ReportRefreshStatus(state: model.state)
                    if case .loaded(.report(let report)) = model.state.content {
                        ReportSummaryView(report: report)
                        Button(action: openReport) {
                            HStack(spacing: HealthTheme.Space.small) {
                                Text("View report")
                                Image(systemName: "chevron.right")
                                    .accessibilityHidden(true)
                            }
                        }
                        .buttonStyle(HealthPrimaryButtonStyle())
                        .accessibilityIdentifier("home.viewReport")
                    } else {
                        ReportStatusView(content: model.state.content) {
                            await model.load(refresh: true)
                        }
                    }
                }
                .modifier(HealthSurface())
            }
            .padding(HealthTheme.Space.screen)
            .frame(maxWidth: HealthTheme.contentWidth)
            .frame(maxWidth: .infinity)
        }
        .background { HealthCanvas() }
        .refreshable { await model.load(refresh: true) }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("home.content")
    }
}

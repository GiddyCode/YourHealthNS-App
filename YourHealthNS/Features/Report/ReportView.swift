import SwiftUI

struct ReportView: View {
    @ObservedObject var model: ReportViewModel
    let goBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HealthTheme.Space.large) {
                ReportRefreshStatus(state: model.state)
                if case .loaded(.report(let report)) = model.state.content {
                    ReportSummaryView(report: report, horizontal: true)
                        .modifier(HealthSurface())

                    Text("Results · \(report.results.count)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(HealthTheme.primaryText)
                        .accessibilityAddTraits(.isHeader)

                    if report.unavailableResultCount > 0 {
                        Label("Some results are unavailable (\(report.unavailableResultCount) of \(report.results.count)).", systemImage: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(HealthTheme.secondaryText)
                    }
                    if report.results.isEmpty {
                        Text("No report results available.")
                            .foregroundStyle(HealthTheme.secondaryText)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(report.results) { result in
                                ResultRow(result: result)
                                if result.id != report.results.last?.id {
                                    Divider()
                                        .overlay(Color.gray.opacity(0.3))
                                }
                            }
                        }
                        .modifier(HealthSurface())
                    }
                } else {
                    ReportStatusView(content: model.state.content) {
                        await model.load(refresh: true)
                    }
                    .modifier(HealthSurface())
                }
            }
            .padding(HealthTheme.Space.screen)
            .frame(maxWidth: HealthTheme.contentWidth)
            .frame(maxWidth: .infinity)
        }
        .background { HealthCanvas() }
        .refreshable { await model.load(refresh: true) }
        .navigationTitle("Lab Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
        }
        .accessibilityIdentifier("report.content")
    }

    private var backButton: some View {
        Button(action: goBack) {
            Image(systemName: "chevron.left")
                .font(.body.weight(.semibold))
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(HealthTheme.action)
        .accessibilityLabel("Back to Home")
        .accessibilityIdentifier("report.back")
    }
}

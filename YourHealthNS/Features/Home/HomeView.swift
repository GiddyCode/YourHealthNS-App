import SwiftUI

struct HomeView: View {
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

                    ReportEmptyState()

                    Button(action: openReport) {
                        HStack(spacing: HealthTheme.Space.small) {
                            Text("View report")
                            Image(systemName: "chevron.right")
                                .accessibilityHidden(true)
                        }
                    }
                    .buttonStyle(HealthPrimaryButtonStyle())
                    .accessibilityIdentifier("home.viewReport")
                }
                .modifier(HealthSurface())
            }
            .padding(HealthTheme.Space.screen)
            .frame(maxWidth: HealthTheme.contentWidth)
            .frame(maxWidth: .infinity)
        }
        .background { HealthCanvas() }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("home.content")
    }
}

#Preview("Home") {
    HomeView(openReport: {})
}

#Preview("Home · dark") {
    HomeView(openReport: {})
        .preferredColorScheme(.dark)
}

#Preview("Home · accessibility text") {
    HomeView(openReport: {})
        .environment(\.dynamicTypeSize, .accessibility3)
}

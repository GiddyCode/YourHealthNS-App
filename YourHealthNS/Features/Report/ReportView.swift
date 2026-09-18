import SwiftUI

struct ReportView: View {
    var body: some View {
        ScrollView {
            ReportEmptyState()
                .modifier(HealthSurface())
                .padding(HealthTheme.Space.screen)
                .frame(maxWidth: HealthTheme.contentWidth)
                .frame(maxWidth: .infinity)
        }
        .background { HealthCanvas() }
        .navigationTitle("Lab report")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("report.content")
    }
}

#Preview("Report") {
    NavigationStack {
        ReportView()
    }
}

#Preview("Report · dark") {
    NavigationStack {
        ReportView()
    }
    .preferredColorScheme(.dark)
}

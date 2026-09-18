import SwiftUI

enum AppTab: Hashable {
    case home
    case report
}

struct AppTabs: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeView {
                    selection = .report
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                ReportView()
            }
            .tabItem {
                Label("Report", systemImage: "doc.text.fill")
            }
            .tag(AppTab.report)
        }
        .tint(HealthTheme.action)
    }
}

#Preview("App tabs") {
    AppTabs()
}

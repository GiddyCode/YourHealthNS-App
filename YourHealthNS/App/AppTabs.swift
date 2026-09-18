import SwiftUI

enum AppTab: Hashable {
    case home
    case report
}

struct AppTabs: View {
    @ObservedObject var model: ReportViewModel
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeView(model: model) {
                    selection = .report
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                ReportView(model: model)
            }
            .tabItem {
                Label("Report", systemImage: "doc.text.fill")
            }
            .tag(AppTab.report)
        }
        .tint(HealthTheme.action)
    }
}

//  YourHealthNS
//  Created by Gideon Ogbonna.

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingSplash = true
    @StateObject private var model = ReportViewModel(
        repository: LiveReportRepository(endpoint: "https://build.fhir.org/diagnosticreport-example.json")
    )

    var body: some View {
        ZStack {
            AppTabs(model: model)
                .allowsHitTesting(!showingSplash && scenePhase == .active)
                .accessibilityHidden(showingSplash || scenePhase != .active)

            if showingSplash {
                SplashView()
                    .transition(.opacity)
                    .accessibilityHidden(scenePhase != .active)
            }

            if scenePhase != .active {
                // Cover content before the scene enters the background.
                PrivacyCoverView()
                    .transition(.identity)
                    .transaction { $0.animation = nil }
                    .zIndex(1)
            }
        }
        .task { await model.load() }
        .task {
            guard showingSplash else { return }
            // The report request runs independently of the introduction.
            do {
                try await Task.sleep(for: .milliseconds(reduceMotion ? 300 : 800))
                try Task.checkCancellation()
                withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.2)) {
                    showingSplash = false
                }
            } catch {
                return
            }
        }
    }
}

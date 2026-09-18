//  YourHealthNS
//  Created by Gideon Ogbonna.

import SwiftUI

struct ContentView: View {
    @StateObject private var model = ReportViewModel(
        repository: LiveReportRepository(endpoint: "https://build.fhir.org/diagnosticreport-example.json")
    )

    var body: some View {
        AppTabs(model: model)
            .task { await model.load() }
    }
}

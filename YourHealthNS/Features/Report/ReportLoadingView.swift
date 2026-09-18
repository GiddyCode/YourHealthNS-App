import SwiftUI

struct ReportLoadingView: View {
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.large) {
            if showDetails {
                Image("Microscope")
                    .resizable()
                    .scaledToFit()
                    .frame(width: HealthTheme.microscopeSize, height: HealthTheme.microscopeSize)
                    .background(.white, in: RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                    .clipShape(RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
            }

            VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                ProgressView("Retrieving your report")
                    .font(.headline)
                    .tint(HealthTheme.action)
                Text("Connecting securely to the laboratory service…")
                    .font(.subheadline)
                    .foregroundStyle(HealthTheme.secondaryText)
            }

            if showDetails {
                VStack(alignment: .leading, spacing: HealthTheme.Space.regular) {
                    ForEach(0..<3) { _ in
                        VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                            RoundedRectangle(cornerRadius: 4)
                                .frame(height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .frame(maxWidth: 140)
                                .frame(height: 10)
                        }
                    }
                }
                .foregroundStyle(HealthTheme.border)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Retrieving your report")
        .accessibilityIdentifier("report.loading")
        .task {
            // Fast requests skip the expanded loading layout.
            do {
                try await Task.sleep(for: .milliseconds(200))
                try Task.checkCancellation()
                showDetails = true
            } catch {
                return
            }
        }
    }
}

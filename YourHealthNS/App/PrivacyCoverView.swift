import SwiftUI

struct PrivacyCoverView: View {
    var body: some View {
        ZStack {
            HealthTheme.canvas.ignoresSafeArea()

            VStack(spacing: HealthTheme.Space.large) {
                BrandWordmark()

                Label("Report hidden", systemImage: "lock.fill")
                    .font(.headline)
                    .foregroundStyle(HealthTheme.primaryText)

                Text("Return to the app to view your report.")
                    .font(.body)
                    .foregroundStyle(HealthTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(HealthTheme.Space.screen)
            .frame(maxWidth: HealthTheme.contentWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Report hidden")
        .accessibilityIdentifier("app.privacyCover")
    }
}

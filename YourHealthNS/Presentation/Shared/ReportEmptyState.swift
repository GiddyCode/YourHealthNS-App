import SwiftUI

struct ReportEmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.regular) {
            Image("Microscope")
                .resizable()
                .scaledToFit()
                .frame(width: HealthTheme.microscopeSize, height: HealthTheme.microscopeSize)
                .background(.white, in: RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                .clipShape(RoundedRectangle(cornerRadius: HealthTheme.Radius.illustration))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                Text("No report available")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(HealthTheme.primaryText)
                Text("The laboratory service returned no report.")
                    .font(.body)
                    .foregroundStyle(HealthTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

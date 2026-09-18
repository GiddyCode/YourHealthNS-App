import SwiftUI

struct BrandWordmark: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image("NSWordmark")
            .resizable()
            .scaledToFit()
            .frame(width: HealthTheme.wordmarkWidth)
            .padding(HealthTheme.Space.small)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: HealthTheme.Radius.control)
                        .fill(.white)
                }
            }
            .accessibilityLabel("Nova Scotia Health")
    }
}

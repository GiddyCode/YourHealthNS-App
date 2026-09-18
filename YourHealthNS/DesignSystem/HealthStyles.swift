import SwiftUI

struct HealthSurface: ViewModifier {
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        content
            .padding(HealthTheme.Space.regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HealthTheme.surface, in: RoundedRectangle(cornerRadius: HealthTheme.Radius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HealthTheme.Radius.surface)
                    .strokeBorder(
                        contrast == .increased ? HealthTheme.secondaryText : HealthTheme.border,
                        lineWidth: 1
                    )
            }
    }
}

struct HealthPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(HealthTheme.actionText)
            .padding(HealthTheme.Space.regular)
            .frame(maxWidth: .infinity, minHeight: HealthTheme.minimumControlHeight)
            .background(HealthTheme.action, in: RoundedRectangle(cornerRadius: HealthTheme.Radius.control))
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.5)
    }
}

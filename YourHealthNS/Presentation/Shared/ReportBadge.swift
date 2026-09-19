import SwiftUI

struct ReportBadge: View {
    enum Style: Equatable {
        case positive, negative, informational, critical

        var color: Color {
            switch self {
            case .positive: .green
            case .negative: .red
            case .informational: .blue
            case .critical: .black
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
    let text: String
    let style: Style

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(style.color)
            .padding(.horizontal, HealthTheme.Space.medium)
            .padding(.vertical, HealthTheme.Space.small)
            .background(style.color.opacity(0.16), in: RoundedRectangle(cornerRadius: HealthTheme.Radius.control))
            .background {
                if style == .critical && colorScheme == .dark {
                    RoundedRectangle(cornerRadius: HealthTheme.Radius.control)
                        .fill(.white.opacity(0.85))
                }
            }
            .fixedSize(horizontal: false, vertical: true)
    }
}

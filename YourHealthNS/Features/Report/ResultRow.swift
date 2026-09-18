import SwiftUI

struct ResultRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let result: LabResult

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: HealthTheme.Space.small))
                : AnyLayout(HStackLayout(alignment: .center, spacing: HealthTheme.Space.medium))

            layout {
                VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                    Text(result.name)
                        .font(.headline)
                    Text(ReportFormatting.value(result.value))
                        .font(result.value.isUnavailable ? .body : .title2.weight(.semibold))
                }
                .foregroundStyle(HealthTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

                if !result.interpretations.isEmpty {
                    ReportBadge(text: result.interpretations.joined(separator: " · "), tint: interpretationTint)
                }
            }

            if let status = result.status, status != .final {
                Text("Status: \(ReportFormatting.status(status))")
                    .font(.subheadline.weight(.medium))
            }
            ForEach(Array(result.referenceRanges.enumerated()), id: \.offset) { _, range in
                Text("Reference range: \(ReportFormatting.range(range))")
                    .font(.footnote)
            }
        }
        .foregroundStyle(HealthTheme.secondaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HealthTheme.Space.regular)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("report.result.\(result.id)")
    }

    private var interpretationTint: Color {
        let interpretations = result.interpretations.map { $0.lowercased() }
        if interpretations.contains("critical high") || interpretations.contains("critical low") {
            return .black
        }
        if interpretations.contains("high") || interpretations.contains("abnormal") {
            return .red
        }
        if interpretations.contains("low") {
            return .blue
        }
        if interpretations.contains("normal") {
            return .green
        }
        return HealthTheme.action
    }
}

import SwiftUI

struct ResultRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let result: LabResult
    let formatter: ReportFormatting

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: HealthTheme.Space.small))
                : AnyLayout(HStackLayout(alignment: .center, spacing: HealthTheme.Space.medium))

            layout {
                VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
                    Text(formatter.resultName(result))
                        .font(.headline)
                    Text(formatter.value(result.value))
                        .font(result.value.isUnavailable ? .body : .title2.weight(.semibold))
                }
                .foregroundStyle(HealthTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

                if !result.interpretations.isEmpty {
                    ReportBadge(text: result.interpretations.map(formatter.interpretation).joined(separator: " · "), style: interpretationStyle)
                }
            }

            if let status = result.status, status != .final {
                Text("Status: \(formatter.status(status))")
                    .font(.subheadline.weight(.medium))
            }
            ForEach(Array(result.referenceRanges.enumerated()), id: \.offset) { _, range in
                Text("Reference range: \(formatter.range(range))")
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

    private var interpretationStyle: ReportBadge.Style {
        let kinds = result.interpretations.map(\.kind)
        if kinds.contains(.criticalHigh) || kinds.contains(.criticalLow) {
            return .critical
        }
        if kinds.contains(.high) || kinds.contains(.abnormal) {
            return .negative
        }
        if kinds.contains(.normal) && !kinds.contains(.low) {
            return .positive
        }
        return .informational
    }
}

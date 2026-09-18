import SwiftUI

struct ResultRow: View {
    let result: LabResult

    var body: some View {
        VStack(alignment: .leading, spacing: HealthTheme.Space.small) {
            Text(result.name)
                .font(.headline)
                .foregroundStyle(HealthTheme.primaryText)
            Text(ReportFormatting.value(result.value))
                .font(result.value.isUnavailable ? .body : .title2.weight(.semibold))
                .foregroundStyle(HealthTheme.primaryText)

            if let status = result.status, status != .final {
                Text("Status: \(ReportFormatting.status(status))")
                    .font(.subheadline.weight(.medium))
            }
            if !result.interpretations.isEmpty {
                Text(result.interpretations.joined(separator: " · "))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(HealthTheme.primaryText)
            }
            ForEach(Array(result.referenceRanges.enumerated()), id: \.offset) { _, range in
                Text("Reference range: \(ReportFormatting.range(range))")
                    .font(.subheadline)
            }
        }
        .foregroundStyle(HealthTheme.secondaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HealthTheme.Space.small)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("report.result.\(result.id)")
    }
}

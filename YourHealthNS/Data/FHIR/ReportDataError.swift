enum ReportDataError: Error, Equatable, Sendable {
    case invalidPayload
    case unsupportedBundle
    case multipleReports
    case unsupportedReportModifier
}

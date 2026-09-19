import Foundation

struct ReportFormatting {
    let locale: Locale

    func reportName(_ report: LabReport) -> String {
        report.name ?? "Lab report"
    }

    func resultName(_ result: LabResult) -> String {
        result.name ?? "Result \(result.id + 1)"
    }

    func performers(_ performers: [LabReport.Performer]) -> String {
        guard !performers.isEmpty else { return "Performer unavailable" }
        return performers.map { $0.name ?? "Performer unavailable" }.joined(separator: ", ")
    }

    func interpretation(_ interpretation: ResultInterpretation) -> String {
        if let text = interpretation.text { return text }
        if let display = interpretation.codings.compactMap(\.display).first { return display }
        switch interpretation.kind {
        case .normal: return "Normal"
        case .high: return "High"
        case .low: return "Low"
        case .criticalHigh: return "Critical high"
        case .criticalLow: return "Critical low"
        case .abnormal: return "Abnormal"
        case .unknown: return interpretation.codings.compactMap(\.code).first ?? "Interpretation unavailable"
        }
    }

    func failure(_ failure: ReportFailure) -> String {
        switch failure {
        case .offline: "You're offline. Check your connection and try again."
        case .timedOut: "The request timed out. Please try again."
        case .invalidReport: "The report couldn't be read. Please try again later."
        case .serviceUnavailable: "The laboratory service couldn't provide a report. Please try again."
        }
    }

    func refreshMessage(_ refresh: ReportState.Refresh) -> String? {
        switch refresh {
        case .idle, .loading: nil
        case .updated: "Report updated."
        case .failed(let error): "Couldn't refresh. Showing the previous response. " + failure(error)
        }
    }

    func status(_ status: ClinicalStatus) -> String {
        switch status {
        case .enteredInError: "Entered in error"
        default: status.rawValue.capitalized
        }
    }

    func quantity(_ quantity: ClinicalQuantity) -> String {
        let value = NSDecimalNumber(decimal: quantity.value).description(withLocale: locale)
        return [quantity.comparator, value, quantity.unit ?? quantity.unitCode]
            .compactMap { $0 }.joined(separator: " ")
    }

    func value(_ value: ClinicalValue) -> String {
        switch value {
        case .quantity(let result): quantity(result)
        case .text(let text): text
        case .boolean(let result): result ? "Yes" : "No"
        case .integer(let result): String(result)
        case .dateTime(let source): date(source)
        case .time(let source): source
        case .period(let start, let end): period(start: start, end: end)
        case .absent(let reason): reason ?? "Result unavailable"
        case .unavailable(let reason):
            switch reason {
            case .restrictedStatus: "Measurement unavailable for this status"
            case .groupedResult: "Grouped result cannot be displayed"
            case .unsupportedValue: "This result format cannot be displayed"
            default: "Result unavailable"
            }
        }
    }

    func range(_ range: ClinicalReferenceRange) -> String {
        var parts: [String] = []
        switch (range.low, range.high) {
        case (let low?, let high?): parts.append("\(quantity(low)) – \(quantity(high))")
        case (let low?, nil): parts.append("At least \(quantity(low))")
        case (nil, let high?): parts.append("Up to \(quantity(high))")
        case (nil, nil): break
        }
        if let text = range.text { parts.append(text) }
        if let kind = range.kind { parts.append(kind) }
        parts.append(contentsOf: range.appliesTo)
        if let low = range.ageLow { parts.append("Age from \(quantity(low))") }
        if let high = range.ageHigh { parts.append("Age up to \(quantity(high))") }
        return parts.isEmpty ? "Not provided" : parts.joined(separator: " · ")
    }

    func effective(_ effective: ClinicalDate?) -> String {
        switch effective {
        case .dateTime(let source): date(source)
        case .period(let start, let end): period(start: start, end: end)
        case nil: "Result date unavailable"
        }
    }

    private func period(start: String?, end: String?) -> String {
        "Period: \(start.map(date) ?? "Start unavailable") – \(end.map(date) ?? "End unavailable")"
    }

    private func date(_ source: String) -> String {
        guard source.contains("T") else { return source }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var parsed = parser.date(from: source)
        if parsed == nil {
            parser.formatOptions = [.withInternetDateTime]
            parsed = parser.date(from: source)
        }
        guard let parsed else { return source }

        // Display the laboratory's offset, not the device's time zone.
        let offset = source.hasSuffix("Z") ? "+00:00" : String(source.suffix(6))
        let parts = offset.dropFirst().split(separator: ":")
        guard parts.count == 2, let hours = parts.first.flatMap({ Int($0) }),
              let minutes = parts.last.flatMap({ Int($0) }),
              let zone = TimeZone(secondsFromGMT: (hours * 3600 + minutes * 60) * (offset.hasPrefix("-") ? -1 : 1)) else {
            return source
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = zone
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(formatter.string(from: parsed)) (UTC\(offset))"
    }
}

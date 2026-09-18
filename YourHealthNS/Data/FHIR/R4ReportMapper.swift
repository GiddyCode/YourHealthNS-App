import Foundation
import ModelsR4

struct R4ReportMapper {
    func map(_ bundle: R4ReportBundle) throws -> ReportOutcome {
        let reports = bundle.entries.compactMap { entry -> (DiagnosticReport, String?)? in
            guard case .report(let report) = entry.resource else { return nil }
            return (report, entry.fullUrl)
        }
        // This feed contains one report; multiple reports are ambiguous.
        guard reports.count <= 1 else { throw ReportDataError.multipleReports }
        guard let (report, fullURL) = reports.first else { return .noReport }
        guard report.modifierExtension?.isEmpty != false, report.implicitRules == nil else {
            throw ReportDataError.unsupportedReportModifier
        }

        let resolver = R4ReferenceResolver(
            entries: bundle.entries, reportFullURL: fullURL, contained: report.contained ?? []
        )
        let status = ClinicalStatus(rawValue: report.status.value?.rawValue ?? "unknown") ?? .unknown
        let results = (report.result ?? []).enumerated().map { index, reference in
            guard status.permitsMeasurements else {
                return unavailable(index, reason: .restrictedStatus)
            }
            switch resolver.resolve(reference.reference?.value?.string) {
            case .unavailable(let reason):
                return unavailable(index, reason: reason)
            case .found(let resource, let observationURL):
                guard case .observation(let observation) = resource else {
                    return unavailable(index, reason: .wrongResourceType)
                }
                if let reportSubject = report.subject?.reference?.value?.string,
                   let observationSubject = observation.subject?.reference?.value?.string,
                   R4ReferenceResolver.canonical(reportSubject, relativeTo: fullURL)
                    != R4ReferenceResolver.canonical(observationSubject, relativeTo: observationURL) {
                    return unavailable(index, reason: .conflictingSubject)
                }
                return map(observation, index: index)
            }
        }

        return .report(LabReport(
            name: label(report.code) ?? "Lab report",
            status: status,
            performers: (report.performer ?? []).compactMap { performer($0, resolver: resolver) },
            effective: effective(report.effective),
            issued: report.issued?.value?.description,
            results: results
        ))
    }

    private func map(_ observation: Observation, index: Int) -> LabResult {
        let name = label(observation.code) ?? "Unnamed test"
        let status = ClinicalStatus(rawValue: observation.status.value?.rawValue ?? "unknown") ?? .unknown
        guard observation.modifierExtension?.isEmpty != false, observation.implicitRules == nil,
              !(observation.referenceRange ?? []).contains(where: { $0.modifierExtension?.isEmpty == false }) else {
            return unavailable(index, reason: .unsupportedModifier)
        }
        guard status.permitsMeasurements else {
            return unavailable(index, name: name, status: status, reason: .restrictedStatus)
        }
        // Grouped results cannot be represented as a single measurement.
        guard observation.component?.isEmpty != false, observation.hasMember?.isEmpty != false else {
            return unavailable(index, name: name, status: status, reason: .groupedResult)
        }
        guard observation.value == nil || observation.dataAbsentReason == nil else {
            return unavailable(index, name: name, status: status, reason: .inconsistentValue)
        }
        return LabResult(
            id: index, name: name, status: status,
            value: value(observation.value, absentReason: observation.dataAbsentReason),
            referenceRanges: (observation.referenceRange ?? []).map(referenceRange),
            interpretations: (observation.interpretation ?? []).compactMap(interpretation)
        )
    }

    private func unavailable(
        _ index: Int, name: String? = nil, status: ClinicalStatus? = nil,
        reason: ResultUnavailableReason
    ) -> LabResult {
        LabResult(id: index, name: name ?? "Result \(index + 1)", status: status,
                  value: .unavailable(reason), referenceRanges: [], interpretations: [])
    }

    private func performer(_ reference: Reference, resolver: R4ReferenceResolver) -> String? {
        if let display = nonempty(reference.display?.value?.string) { return display }
        if case .found(.organization(let organization), _) = resolver.resolve(reference.reference?.value?.string),
           organization.modifierExtension?.isEmpty != false, organization.implicitRules == nil {
            return nonempty(organization.name?.value?.string) ?? "Performer unavailable"
        }
        return "Performer unavailable"
    }

    private func effective(_ value: DiagnosticReport.EffectiveX?) -> ClinicalDate? {
        switch value {
        case .dateTime(let date): date.value.map { .dateTime($0.description) }
        case .period(let period): .period(start: period.start?.value?.description, end: period.end?.value?.description)
        case nil: nil
        }
    }

    private func value(_ value: Observation.ValueX?, absentReason: CodeableConcept?) -> ClinicalValue {
        switch value {
        case .quantity(let source):
            return quantity(source).map(ClinicalValue.quantity) ?? .absent(reason: nil)
        case .string(let source):
            return nonempty(source.value?.string).map(ClinicalValue.text) ?? .absent(reason: nil)
        case .codeableConcept(let source):
            return label(source).map(ClinicalValue.text) ?? .absent(reason: nil)
        case .boolean(let source):
            return source.value.map { .boolean($0.bool) } ?? .absent(reason: nil)
        case .integer(let source):
            return source.value.map { .integer($0.integer) } ?? .absent(reason: nil)
        case .dateTime(let source):
            return source.value.map { .dateTime($0.description) } ?? .absent(reason: nil)
        case .time(let source):
            return source.value.map { .time($0.description) } ?? .absent(reason: nil)
        case .period(let source):
            return .period(start: source.start?.value?.description, end: source.end?.value?.description)
        case .range, .ratio, .sampledData:
            return .unavailable(.unsupportedValue)
        case nil:
            return .absent(reason: absentReason.flatMap(label))
        }
    }

    private func quantity(_ source: Quantity?) -> ClinicalQuantity? {
        guard let source, let decimal = source.value?.value?.decimal else { return nil }
        // FHIRModels does not retain trailing zeros in Decimal values.
        return ClinicalQuantity(
            value: decimal, comparator: source.comparator?.value?.rawValue,
            unit: nonempty(source.unit?.value?.string),
            unitCode: nonempty(source.code?.value?.string),
            unitSystem: source.system?.value?.url.absoluteString
        )
    }

    private func referenceRange(_ source: ObservationReferenceRange) -> ClinicalReferenceRange {
        ClinicalReferenceRange(
            low: quantity(source.low), high: quantity(source.high),
            text: nonempty(source.text?.value?.string), kind: source.type.flatMap(label),
            appliesTo: (source.appliesTo ?? []).compactMap(label),
            ageLow: quantity(source.age?.low), ageHigh: quantity(source.age?.high)
        )
    }

    private func label(_ concept: CodeableConcept) -> String? {
        if let text = nonempty(concept.text?.value?.string) { return text }
        let codings = concept.coding ?? []
        return codings.compactMap { nonempty($0.display?.value?.string) }.first
            ?? codings.compactMap { nonempty($0.code?.value?.string) }.first
    }

    private func interpretation(_ concept: CodeableConcept) -> String? {
        if let text = nonempty(concept.text?.value?.string) { return text }
        for coding in concept.coding ?? [] {
            if let display = nonempty(coding.display?.value?.string) { return display }
            if coding.system?.value?.url.absoluteString == "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation" {
                switch coding.code?.value?.string {
                case "H": return "High"
                case "L": return "Low"
                case "HH": return "Critical high"
                case "LL": return "Critical low"
                case "N": return "Normal"
                case "A": return "Abnormal"
                default: break
                }
            }
        }
        return label(concept)
    }

    private func nonempty(_ value: String?) -> String? {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return value
    }
}

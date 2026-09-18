import Foundation
import ModelsR4

struct R4ReportBundle: Decodable {
    let entries: [Entry]

    struct Entry: Decodable {
        let fullUrl: String?
        let resource: Resource?
    }

    enum Resource: Decodable {
        case report(DiagnosticReport)
        case observation(Observation)
        case organization(Organization)
        case unrelated

        private enum CodingKeys: String, CodingKey { case resourceType }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            switch try container.decode(String.self, forKey: .resourceType) {
            case "DiagnosticReport": self = .report(try DiagnosticReport(from: decoder))
            case "Observation": self = .observation(try Observation(from: decoder))
            case "Organization": self = .organization(try Organization(from: decoder))
            default: self = .unrelated
            }
        }

        init(_ resource: ResourceProxy) {
            switch resource {
            case .diagnosticReport(let value): self = .report(value)
            case .observation(let value): self = .observation(value)
            case .organization(let value): self = .organization(value)
            default: self = .unrelated
            }
        }

        var relativeReference: String? {
            switch self {
            case .report(let value): value.id?.value.map { "DiagnosticReport/\($0.string)" }
            case .observation(let value): value.id?.value.map { "Observation/\($0.string)" }
            case .organization(let value): value.id?.value.map { "Organization/\($0.string)" }
            case .unrelated: nil
            }
        }
    }

    private enum CodingKeys: String, CodingKey { case resourceType, type, entry }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard try container.decode(String.self, forKey: .resourceType) == "Bundle",
              try container.decode(String.self, forKey: .type) == "collection" else {
            throw ReportDataError.unsupportedBundle
        }
        entries = try container.decodeIfPresent([Entry].self, forKey: .entry) ?? []
    }
}

import Foundation
import ModelsR4

struct R4ReferenceResolver {
    enum Resolution {
        case found(R4ReportBundle.Resource, fullURL: String?)
        case unavailable(ResultUnavailableReason)
    }

    let entries: [R4ReportBundle.Entry]
    let reportFullURL: String?
    let contained: [ResourceProxy]

    func resolve(_ reference: String?) -> Resolution {
        guard let reference, !reference.isEmpty else {
            return .unavailable(.unresolvedReference)
        }

        if reference.hasPrefix("#") {
            let id = String(reference.dropFirst())
            let matches = contained.map(R4ReportBundle.Resource.init).filter {
                $0.relativeReference?.split(separator: "/").last.map(String.init) == id
            }
            guard matches.count == 1, let match = matches.first else {
                return .unavailable(matches.isEmpty ? .unresolvedReference : .ambiguousReference)
            }
            return .found(match, fullURL: reportFullURL)
        }

        let canonical = Self.canonical(reference, relativeTo: reportFullURL)
        let matches = entries.filter { entry in
            if let fullURL = entry.fullUrl { return fullURL == canonical }
            // Relative IDs are matched only when neither resource has an HTTP base.
            return Self.baseURL(reportFullURL) == nil
                && reference == canonical
                && entry.resource?.relativeReference == reference
        }
        guard matches.count == 1, let entry = matches.first, let resource = entry.resource else {
            return .unavailable(matches.count > 1 ? .ambiguousReference : .unresolvedReference)
        }
        return .found(resource, fullURL: entry.fullUrl)
    }

    static func canonical(_ reference: String, relativeTo fullURL: String?) -> String {
        let parts = reference.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts.contains(where: { $0.isEmpty || $0 == ".." || $0 == "." }),
              !reference.contains(":"), !reference.contains("?"), !reference.contains("#"),
              let base = baseURL(fullURL) else { return reference }
        return base.appendingPathComponent(reference).absoluteString
    }

    private static func baseURL(_ fullURL: String?) -> URL? {
        guard let fullURL, let url = URL(string: fullURL),
              (url.scheme == "https" || url.scheme == "http"), url.host != nil,
              url.query == nil, url.fragment == nil,
              url.pathComponents.count >= 3 else { return nil }
        return url.deletingLastPathComponent().deletingLastPathComponent()
    }
}

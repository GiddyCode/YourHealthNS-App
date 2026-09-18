import Foundation

actor LiveReportRepository: ReportRepository {
    private let endpoint: String
    private let session: URLSession
    private let decoder: R4ReportDecoder

    init(endpoint: String, session: URLSession? = nil, decoder: R4ReportDecoder = R4ReportDecoder()) {
        self.endpoint = endpoint
        self.session = session ?? Self.makeSession()
        self.decoder = decoder
    }

    func fetchReport() async throws -> ReportOutcome {
        guard let url = URL(string: endpoint), url.scheme == "https" else {
            throw ReportRequestError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/fhir+json, application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse else {
            throw ReportRequestError.invalidResponse
        }
        guard (200..<300).contains(response.statusCode) else {
            throw ReportRequestError.httpStatus(response.statusCode)
        }
        guard !data.isEmpty else { throw ReportRequestError.emptyResponse }
        guard let mime = response.mimeType?.lowercased(),
              mime == "application/json" || mime == "application/fhir+json" else {
            throw ReportRequestError.invalidResponse
        }
        return try await decoder.decode(data)
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.urlCredentialStorage = nil
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration)
    }
}

enum ReportRequestError: Error {
    case invalidResponse
    case httpStatus(Int)
    case emptyResponse
}

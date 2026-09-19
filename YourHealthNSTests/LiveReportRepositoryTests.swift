import Foundation
import XCTest
@testable import YourHealthNS

final class LiveReportRepositoryTests: XCTestCase {
    func testJSONAndFHIRJSONResponsesDecode() async throws {
        for path in ["json", "fhir"] {
            let outcome = try await fetch(path)
            XCTAssertEqual(outcome, .noReport)
        }
    }

    func testTransportFailuresAreTranslated() async {
        await assertFailure("offline", .offline)
        await assertFailure("timeout", .timedOut)
        await assertFailure("server", .serviceUnavailable)
    }

    func testInvalidResponsesAreRejected() async {
        for path in ["http-error", "empty", "html"] {
            await assertFailure(path, .serviceUnavailable)
        }
        await assertFailure("malformed", .invalidReport)
    }

    private func fetch(_ path: String, scheme: String = "https") async throws -> ReportOutcome {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ReportURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        return try await LiveReportRepository(
            endpoint: "\(scheme)://report-tests.invalid/\(path)", session: session
        ).fetchReport()
    }

    private func assertFailure(
        _ path: String, _ expected: ReportFailure,
        file: StaticString = #filePath, line: UInt = #line
    ) async {
        do {
            _ = try await fetch(path)
            XCTFail("Expected request failure", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? ReportFailure, expected, file: file, line: line)
        }
    }
}

private final class ReportURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url,
              request.httpMethod == "GET",
              request.value(forHTTPHeaderField: "Accept") == "application/fhir+json, application/json"
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        let path = url.lastPathComponent
        let errors: [String: URLError.Code] = [
            "offline": .notConnectedToInternet, "timeout": .timedOut,
            "server": .cannotConnectToHost, "cancelled": .cancelled
        ]
        if let code = errors[path] {
            client?.urlProtocol(self, didFailWithError: URLError(code))
            return
        }
        let mime = path == "html" ? "text/html" :
            (path == "fhir" ? "application/fhir+json" : "application/json")
        guard let response = HTTPURLResponse(
            url: url, statusCode: path == "http-error" ? 503 : 200,
            httpVersion: "HTTP/1.1", headerFields: ["Content-Type": mime]
        ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let body = path == "empty" ? "" : (path == "malformed" ? "{" :
            #"{"resourceType":"Bundle","type":"collection","entry":[]}"#)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

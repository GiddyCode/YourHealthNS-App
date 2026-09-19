import Foundation
import XCTest
@testable import YourHealthNS

@MainActor
final class ReportViewModelTests: XCTestCase {
    func testInitialLoadAndRepeatedLoadUseOneResponse() async {
        let repository = ScriptedRepository([.success(.noReport)])
        let model = ReportViewModel(repository: repository)
        XCTAssertEqual(model.state, .idle)
        await model.load()
        XCTAssertEqual(model.state, .loaded(.noReport))
        await model.load()
        let calls = await repository.callCount
        XCTAssertEqual(calls, 1)
    }

    func testFailureCanBeRetried() async {
        let repository = ScriptedRepository([.failure(ReportFailure.offline), .success(.noReport)])
        let model = ReportViewModel(repository: repository)
        await model.load()
        XCTAssertEqual(model.state, .failed(.offline))
        await model.load(refresh: true)
        XCTAssertEqual(model.state, .loaded(.noReport, refresh: .updated))
    }

    func testFailedRefreshRetainsPreviousReport() async {
        let report = LabReport(
            name: "Blood count", status: .final, performers: [],
            effective: nil, issued: nil, results: []
        )
        let repository = ScriptedRepository([
            .success(.report(report)), .failure(ReportFailure.timedOut)
        ])
        let model = ReportViewModel(repository: repository)
        await model.load()
        await model.load(refresh: true)
        XCTAssertEqual(model.state, .loaded(.report(report), refresh: .failed(.timedOut)))
        XCTAssertEqual(model.state.report, report)
        XCTAssertFalse(model.state.isRequestInFlight)
    }

    func testConcurrentLoadIsIgnoredWhileRequestIsPending() async {
        let repository = SuspendedRepository()
        let model = ReportViewModel(repository: repository)
        let first = Task { await model.load() }
        await repository.waitUntilStarted()
        XCTAssertEqual(model.state, .loading)
        await model.load(refresh: true)
        let calls = await repository.callCount
        XCTAssertEqual(calls, 1)
        await repository.finish()
        await first.value
        XCTAssertEqual(model.state, .loaded(.noReport))
    }

    func testCancelledTaskCannotPublishSuccessfulResponse() async {
        let repository = SuspendedRepository()
        let model = ReportViewModel(repository: repository)
        let request = Task { await model.load() }
        await repository.waitUntilStarted()
        request.cancel()
        await repository.finish()
        await request.value
        XCTAssertEqual(model.state, .idle)
    }
}

private actor ScriptedRepository: ReportRepository {
    private var responses: [Result<ReportOutcome, Error>]
    private(set) var callCount = 0

    init(_ responses: [Result<ReportOutcome, Error>]) {
        self.responses = responses
    }

    func fetchReport() async throws -> ReportOutcome {
        callCount += 1
        guard !responses.isEmpty else { throw ReportFailure.serviceUnavailable }
        return try responses.removeFirst().get()
    }
}

private actor SuspendedRepository: ReportRepository {
    private(set) var callCount = 0
    private var pending: CheckedContinuation<ReportOutcome, Never>?
    private var started: CheckedContinuation<Void, Never>?

    func fetchReport() async throws -> ReportOutcome {
        callCount += 1
        return await withCheckedContinuation { continuation in
            pending = continuation
            started?.resume()
            started = nil
        }
    }

    func waitUntilStarted() async {
        guard pending == nil else { return }
        await withCheckedContinuation { started = $0 }
    }

    func finish() {
        pending?.resume(returning: .noReport)
        pending = nil
    }
}

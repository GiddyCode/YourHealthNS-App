import Foundation
import XCTest
@testable import YourHealthNS

final class R4ReportDecoderTests: XCTestCase {
    func testCapturedReportMetadataAndAllSeventeenResults() async throws {
        let report = try await decodeReport(fixtureData())
        XCTAssertEqual(report.name, "Complete Blood Count")
        XCTAssertEqual(report.status, .final)
        XCTAssertEqual(report.performers.map(\.name), ["Acme Laboratory, Inc"])
        XCTAssertEqual(report.effective, .dateTime("2011-03-04T08:30:00+11:00"))
        XCTAssertEqual(report.issued, "2011-03-04T11:45:33+11:00")
        XCTAssertEqual(report.results.count, 17)
        XCTAssertEqual(report.results.map(\.id), Array(0..<17))
        XCTAssertEqual(report.unavailableResultCount, 0)

        let expected: [(String, String, String, String?, String?)] = [
            ("Haemoglobin", "176", "g/L", "135", "180"),
            ("Red Cell Count", "5.9", "x10*12/L", "4.2", "6.0"),
            ("Haematocrit", "55", "%", "38", "52"),
            ("Mean Cell Volume", "99", "fL", "80", "98"),
            ("Mean Cell Haemoglobin", "36", "pg", "27", "35"),
            ("Platelet Count", "444", "x10*9/L", "150", "450"),
            ("White Cell Count", "4.6", "x10*9/L", "4.0", "11.0"),
            ("Neutrophils", "20", "%", nil, nil),
            ("Neutrophils", "0.9", "x10*9/L", "2.0", "7.5"),
            ("Lymphocytes", "20", "%", nil, nil),
            ("Lymphocytes", "0.9", "x10*9/L", "1.1", "4.0"),
            ("Monocytes", "20", "%", nil, nil),
            ("Monocytes", "0.9", "x10*9/L", "0.2", "1.0"),
            ("Eosinophils", "20", "%", nil, nil),
            ("Eosinophils", "0.92", "x10*9/L", "0.04", "0.40"),
            ("Basophils", "20", "%", nil, nil),
            ("Basophils", "0.92", "x10*9/L", nil, "0.21")
        ]
        for (result, source) in zip(report.results, expected) {
            XCTAssertEqual(result.name, source.0)
            guard case .quantity(let quantity) = result.value else {
                return XCTFail("Expected quantity at result position \(result.id)")
            }
            XCTAssertEqual(quantity.value, Decimal(string: source.1))
            XCTAssertEqual(quantity.unit, source.2)
            XCTAssertEqual(result.referenceRanges.first?.low?.value, source.3.flatMap { Decimal(string: $0) })
            XCTAssertEqual(result.referenceRanges.first?.high?.value, source.4.flatMap { Decimal(string: $0) })
        }
        let hematocrit = try XCTUnwrap(report.results.first { $0.id == 2 })
        XCTAssertEqual(hematocrit.interpretations.map(\.kind), [.high])
        let volume = try XCTUnwrap(report.results.first { $0.id == 3 })
        XCTAssertEqual(volume.interpretations.map(\.kind), [.high])
        XCTAssertEqual(report.results.last?.interpretations, [])
    }

    func testOnlyLinkedResultsAppearAndMissingReferencesKeepTheirPosition() async throws {
        let report = try await decodeReport(entries: [
            entry(reportResource(references: ["Observation/b", "Observation/missing", "Observation/a"]), "DiagnosticReport/report"),
            entry(observation("a"), "Observation/a"),
            entry(observation("b"), "Observation/b"),
            entry(observation("unrelated"), "Observation/unrelated")
        ])
        XCTAssertEqual(report.results.map(\.name), ["Test b", nil, "Test a"])
        XCTAssertEqual(report.results.map(\.id), [0, 1, 2])
        XCTAssertEqual(report.results.first { $0.id == 1 }?.value, .unavailable(.unresolvedReference))
        XCTAssertEqual(report.unavailableResultCount, 1)
    }

    func testSameFragmentInSeparateResourcesDoesNotMatchSubjects() async throws {
        var resource = reportResource()
        resource["subject"] = ["reference": "#patient"]
        resource["contained"] = [["resourceType": "Patient", "id": "patient"]]
        var result = observation("a")
        result["subject"] = ["reference": "#patient"]
        result["contained"] = [["resourceType": "Patient", "id": "patient"]]
        let report = try await decodeReport(entries: [
            entry(resource, "DiagnosticReport/report"), entry(result, "Observation/a")
        ])
        XCTAssertEqual(report.results.first?.value, .unavailable(.conflictingSubject))
        XCTAssertNil(report.results.first?.name)
    }

    func testContainedObservationCanShareReportsContainedPatient() async throws {
        var resource = reportResource(references: ["#a"])
        resource["subject"] = ["reference": "#patient"]
        var result = observation("a")
        result["subject"] = ["reference": "#patient"]
        resource["contained"] = [result, ["resourceType": "Patient", "id": "patient"]]
        let report = try await decodeReport(entries: [entry(resource, "DiagnosticReport/report")])
        XCTAssertEqual(report.unavailableResultCount, 0)
        XCTAssertEqual(report.results.first?.name, "Test a")
    }

    func testInterpretationKindsComeFromStandardCodesNotRangeInference() async throws {
        let cases: [(String, ResultInterpretation.Kind)] = [
            ("N", .normal), ("H", .high), ("L", .low),
            ("HH", .criticalHigh), ("LL", .criticalLow), ("A", .abnormal)
        ]
        for (code, kind) in cases {
            var result = observation("a")
            result["interpretation"] = [["coding": [[
                "system": "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation",
                "code": code
            ]]]]
            let report = try await oneResult(result)
            XCTAssertEqual(report.results.first?.interpretations.map(\.kind), [kind])
        }
        var result = observation("a")
        result["referenceRange"] = [["low": ["value": 1], "high": ["value": 100]]]
        let unflagged = try await oneResult(result)
        XCTAssertEqual(unflagged.results.first?.interpretations, [])
        result["interpretation"] = [["coding": [[
            "system": "https://example.invalid/codes", "code": "H", "display": "High"
        ]]]]
        let custom = try await oneResult(result)
        XCTAssertEqual(custom.results.first?.interpretations.first?.kind, .unknown)
        XCTAssertEqual(custom.results.first?.interpretations.first?.codings.first?.display, "High")
    }

    func testConflictingSubjectsDoNotLeakResultLabelsOrValues() async throws {
        var other = observation("a")
        other["subject"] = ["reference": "Patient/different"]
        let report = try await decodeReport(entries: [entry(reportResource(), "DiagnosticReport/report"), entry(other, "Observation/a")])
        XCTAssertEqual(report.results.first?.value, .unavailable(.conflictingSubject))
        XCTAssertNil(report.results.first?.name)
        XCTAssertNil(report.results.first?.status)
    }

    func testMissingQuantityIsAbsentNotZero() async throws {
        var result = observation("a")
        result["valueQuantity"] = ["unit": "g/L"]
        let report = try await oneResult(result)
        XCTAssertEqual(report.results.first?.value, .absent(reason: nil))
    }

    func testUnsupportedModifiersAndStatusesSuppressMeasurements() async throws {
        for status in ["cancelled", "entered-in-error", "unknown", "registered"] {
            var result = observation("a")
            result["status"] = status
            let report = try await oneResult(result)
            XCTAssertEqual(report.results.first?.value, .unavailable(.restrictedStatus))
            XCTAssertEqual(report.results.first?.status?.rawValue, status)
        }
        var result = observation("a")
        result["modifierExtension"] = [["url": "https://example.invalid/modifier", "valueBoolean": true]]
        let modified = try await oneResult(result)
        XCTAssertEqual(modified.results.first?.value, .unavailable(.unsupportedModifier))
    }

    func testNoReportAndReportWithoutResultsAreDistinct() async throws {
        let noReport = try await R4ReportDecoder().decode(bundleData([]))
        XCTAssertEqual(noReport, .noReport)
        let empty = try await decodeReport(entries: [entry(reportResource(references: []), "DiagnosticReport/report")])
        XCTAssertTrue(empty.results.isEmpty)
    }

    func testMalformedRequiredResourceAndUnknownStatusFailClearly() async throws {
        var malformed = observation("a")
        malformed.removeValue(forKey: "code")
        await assertFailure(.invalidPayload, entries: [entry(reportResource(), "DiagnosticReport/report"), entry(malformed, "Observation/a")])
        var unknown = observation("a")
        unknown["status"] = "not-an-r4-status"
        await assertFailure(.invalidPayload, entries: [entry(reportResource(), "DiagnosticReport/report"), entry(unknown, "Observation/a")])
    }

    private let base = "https://example.invalid/base/"

    private func fixtureData() throws -> Data {
        let bundle = Bundle(for: R4ReportDecoderTests.self)
        let url = try XCTUnwrap(
            bundle.url(forResource: "diagnosticreport-example", withExtension: "json")
                ?? bundle.url(forResource: "diagnosticreport-example", withExtension: "json", subdirectory: "Fixtures")
        )
        return try Data(contentsOf: url)
    }

    private func reportResource(references: [String] = ["Observation/a"]) -> [String: Any] {
        ["resourceType": "DiagnosticReport", "id": "report", "status": "final",
         "code": ["text": "Synthetic report"], "subject": ["reference": "Patient/synthetic"],
         "result": references.map { ["reference": $0] }]
    }

    private func observation(_ id: String) -> [String: Any] {
        ["resourceType": "Observation", "id": id, "status": "final", "code": ["text": "Test \(id)"],
         "subject": ["reference": "Patient/synthetic"], "valueQuantity": ["value": 42, "unit": "g/L"]]
    }

    private func entry(_ resource: [String: Any], _ reference: String) -> [String: Any] {
        ["fullUrl": base + reference, "resource": resource]
    }

    private func bundleData(_ entries: [[String: Any]]) throws -> Data {
        try JSONSerialization.data(withJSONObject: ["resourceType": "Bundle", "type": "collection", "entry": entries])
    }

    private func decodeReport(entries: [[String: Any]]) async throws -> LabReport {
        try await decodeReport(bundleData(entries))
    }

    private func decodeReport(_ data: Data) async throws -> LabReport {
        let outcome = try await R4ReportDecoder().decode(data)
        guard case .report(let report) = outcome else { throw FixtureError.noReport }
        return report
    }

    private func oneResult(_ observation: [String: Any]) async throws -> LabReport {
        try await decodeReport(entries: [entry(reportResource(), "DiagnosticReport/report"), entry(observation, "Observation/a")])
    }

    private func assertFailure(_ expected: ReportDataError, entries: [[String: Any]]) async {
        do {
            _ = try await R4ReportDecoder().decode(bundleData(entries))
            XCTFail("Expected a data-boundary failure")
        } catch let error as ReportDataError {
            XCTAssertEqual(error, expected)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    private enum FixtureError: Error { case noReport }
}

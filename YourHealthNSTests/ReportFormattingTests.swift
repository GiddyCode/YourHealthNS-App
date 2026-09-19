import Foundation
import XCTest
@testable import YourHealthNS

final class ReportFormattingTests: XCTestCase {
    private let formatting = ReportFormatting(locale: Locale(identifier: "en_US"))

    func testMissingValueIsNotFormattedAsZero() {
        XCTAssertEqual(formatting.value(.absent(reason: nil)), "Result unavailable")
        XCTAssertEqual(formatting.value(.absent(reason: "Not performed")), "Not performed")
    }

    func testDateUsesLaboratoryOffset() {
        let value = formatting.effective(.dateTime("2011-03-04T08:30:00+11:00"))
        XCTAssertTrue(value.contains("8:30"))
        XCTAssertTrue(value.hasSuffix("(UTC+11:00)"))
    }

}

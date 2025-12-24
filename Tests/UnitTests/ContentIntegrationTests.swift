import XCTest
@testable import MrBase64

final class ContentIntegrationTests: XCTestCase {
    func testMakeMarkdownGeneratesExpectedBase64AndMarkdown() {
        let data = Data([1, 2, 3, 4]) // AQIDBA==
        let filename = "example.png"
        let uti = "public.png"

        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 12
        dateComponents.day = 21
        dateComponents.hour = 10
        dateComponents.minute = 20
        dateComponents.second = 30
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: dateComponents)!

        let result = Base64Encoder.makeMarkdown(from: data, filename: filename, uti: uti, date: date)

        XCTAssertEqual(result.base64String, "AQIDBA==")
        // timestamp for 2025-12-21 10:20:30 UTC -> yyMMdd-HHmmss = 251221-102030
        let expectedTimestamp = "251221-102030"
        let expectedReference = "example-\(expectedTimestamp)"
        XCTAssertTrue(result.markdown.contains("![\(filename)][\(expectedReference)]"))
        XCTAssertTrue(result.markdown.contains("[\(expectedReference)]: data:image/png;base64,\(result.base64String)"))
    }

    func testPasteboardCopySimulation() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let value = "test-pasteboard-string"
        pasteboard.setString(value, forType: .string)
        XCTAssertEqual(pasteboard.string(forType: .string), value)
    }
}

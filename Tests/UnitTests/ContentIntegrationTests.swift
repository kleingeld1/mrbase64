import XCTest
@testable import MrBase64

final class ContentIntegrationTests: XCTestCase {
    func testMakeMarkdownGeneratesExpectedBase64AndMarkdown() {
        let data = Data([1,2,3,4]) // AQIDBA==
        let filename = "example.png"
        let uti = "public.png"

        var dc = DateComponents()
        dc.year = 2025
        dc.month = 12
        dc.day = 21
        dc.hour = 10
        dc.minute = 20
        dc.second = 30
        dc.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: dc)!

        let result = Base64Encoder.makeMarkdown(from: data, filename: filename, uti: uti, date: date)

        XCTAssertEqual(result.base64String, "AQIDBA==")
        // timestamp for 2025-12-21 10:20:30 UTC -> yyMMdd-HHmmss = 251221-102030
        let expectedTimestamp = "251221-102030"
        let expectedReference = "example-\(expectedTimestamp)"
        XCTAssertTrue(result.markdown.contains("![\(filename)][\(expectedReference)]"))
        XCTAssertTrue(result.markdown.contains("[\(expectedReference)]: data:image/png;base64,\(result.base64String)"))
    }

    func testPasteboardCopySimulation() {
        let pb = NSPasteboard.general
        pb.clearContents()
        let s = "test-pasteboard-string"
        pb.setString(s, forType: .string)
        XCTAssertEqual(pb.string(forType: .string), s)
    }
}

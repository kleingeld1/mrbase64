import XCTest
@testable import MrBase64

final class Base64EncoderTests: XCTestCase {
    func testBase64EncodingSimple() throws {
        let data = Data([0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(Base64Encoder.base64String(from: data), "AQIDBA==")
    }

    func testMimeTypeHeicFallback() throws {
        let mime = Base64Encoder.mimeType(for: "public.heic", fallbackFilename: "image.heic")
        XCTAssertEqual(mime, "image/heic")
    }
}

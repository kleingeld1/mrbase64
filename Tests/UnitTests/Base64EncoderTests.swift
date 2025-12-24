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

    func testMimeTypeCommonImageTypes() throws {
        XCTAssertEqual(Base64Encoder.mimeType(for: "public.png", fallbackFilename: ""), "image/png")
        XCTAssertEqual(Base64Encoder.mimeType(for: "public.jpeg", fallbackFilename: ""), "image/jpeg")
        XCTAssertEqual(Base64Encoder.mimeType(for: "com.compuserve.gif", fallbackFilename: ""), "image/gif")
        XCTAssertEqual(Base64Encoder.mimeType(for: "public.tiff", fallbackFilename: ""), "image/tiff")
        XCTAssertEqual(Base64Encoder.mimeType(for: "public.image", fallbackFilename: ""), "image/*")
    }

    func testMimeTypeFallbackByExtension() throws {
        XCTAssertEqual(Base64Encoder.mimeType(for: "public.data", fallbackFilename: "photo.avif"), "image/avif")
        XCTAssertEqual(Base64Encoder.mimeType(for: "public.data", fallbackFilename: "photo.jpg"), "image/jpeg")
    }

    func testMakeMarkdownWithFixedDate() throws {
        let data = Data("Hello".utf8)
        let filename = "hello.txt"
        let uti = "public.plain-text"
        let date = Date(timeIntervalSince1970: 0)

        let result = Base64Encoder.makeMarkdown(from: data, filename: filename, uti: uti, date: date)

        XCTAssertEqual(result.base64String, "SGVsbG8=")
        let expected = "![hello.txt][hello-700101-000000]\n\n" +
            "[hello-700101-000000]: data:text/plain;base64,SGVsbG8="
        XCTAssertEqual(result.markdown, expected)
    }
}

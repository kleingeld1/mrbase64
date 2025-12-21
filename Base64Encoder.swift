import Foundation
import UniformTypeIdentifiers

enum Base64Encoder {
    static func base64String(from data: Data) -> String {
        return data.base64EncodedString()
    }

    static func mimeType(for uti: String, fallbackFilename: String = "") -> String {
        if let ut = UTType(uti) {
            if let preferred = ut.preferredMIMEType {
                return preferred
            }
            if ut.conforms(to: .png) { return "image/png" }
            if ut.conforms(to: .jpeg) { return "image/jpeg" }
            if ut.conforms(to: .gif) { return "image/gif" }
            if ut.conforms(to: .tiff) { return "image/tiff" }
            if ut.conforms(to: .image) { return "image/*" }
        }
        // fallback by extension
        let ext = (fallbackFilename as NSString).pathExtension.lowercased()
        switch ext {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "tiff", "tif": return "image/tiff"
        case "heic": return "image/heic"
        case "avif": return "image/avif"
        default: return "application/octet-stream"
        }
    }

    /// Generate a base64 string and a reference-style Markdown data-URL for an image.
    /// - Parameters:
    ///   - data: The image data
    ///   - filename: The filename used for markdown reference generation
    ///   - uti: The UTI for mime type detection
    ///   - date: Date used to create a stable timestamp for tests (defaults to now)
    /// - Returns: A tuple of `(base64String, markdownString)`
    static func makeMarkdown(from data: Data, filename: String, uti: String, date: Date = Date()) -> (base64String: String, markdown: String) {
        let base64 = base64String(from: data)
        let mime = mimeType(for: uti, fallbackFilename: filename)
        let dataUrl = "data:\(mime);base64,\(base64)"

        let filenameWithoutExt = (filename as NSString).deletingPathExtension
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd-HHmmss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let timestamp = dateFormatter.string(from: date)
        let reference = "\(filenameWithoutExt)-\(timestamp)"

        let markdown = "![\(filename)][\(reference)]\n\n[\(reference)]: \(dataUrl)"
        return (base64, markdown)
    }
}


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
}

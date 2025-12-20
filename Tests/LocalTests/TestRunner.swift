import Foundation

// Simple assertions for Base64Encoder without adding an Xcode test target.
// This file will be compiled together with Base64Encoder.swift in CI.

func assertEqual(_ a: String, _ b: String, message: String) {
    if a != b {
        print("FAIL: \(message) — expected: [\(b)] got: [\(a)]")
        exit(2)
    }
}

// Test 1: known byte sequence
let data1 = Data([0x01, 0x02, 0x03, 0x04])
let got1 = Base64Encoder.base64String(from: data1)
let want1 = "AQIDBA=="
assertEqual(got1, want1, message: "base64 encoding of 01020304")

// Test 2: mime detection by extension fallback
let mimeHeic = Base64Encoder.mimeType(for: "public.heic", fallbackFilename: "image.heic")
if mimeHeic != "image/heic" {
    print("FAIL: mime detection heic — got \(mimeHeic)")
    exit(2)
}

print("All tests passed")

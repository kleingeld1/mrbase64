
# MrBase64

MrBase64 is a lightweight macOS utility (SwiftUI) that converts images into Base64 and provides two convenient output formats: raw Base64 or a Markdown reference-style image link. The app includes a mascot, Mr. Base64, displayed in the UI to make the process more approachable.

Project summary

- Encode image files to Base64 for embedding or processing
- Toggle between raw Base64 or Markdown reference-style output
- Reference keys are generated from the filename (without extension) plus a `yymmdd-HHmmss` timestamp to ensure uniqueness
- Output preference is persisted between launches

How to use

1. Build and run the app from Xcode or via the command line (example):

```bash
xcodebuild -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug build
open "$(xcodebuild -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug -showBuildSettings | awk -F= '/BUILT_PRODUCTS_DIR/{print $2}' | tr -d ' ')/MrBase64.app"
```

2. Drop an image onto the app window or use File → Open.
3. Select the desired output format (Base64 or Markdown) using the radio controls.
4. Click **Copy** to copy the current output to the clipboard.

Example Markdown output (reference-style):

```markdown
![photo.jpg][photo-251221-103015]

[photo-251221-103015]: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD...
```

Build & test

- Build: `xcodebuild -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug build`
- Test: `xcodebuild test -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug -destination 'platform=macOS'`
- CI: GitHub Actions workflow (`.github/workflows/ci.yml`) is included and runs build/tests on macOS runners.

Files of interest

- `MrBase64App.swift` — application lifecycle and file-open integration
- `ContentView.swift` — main UI, mascot view, format toggle, preview and copy actions
- `Base64Encoder.swift` — encoding and MIME type detection helpers
- `Info.plist` — app metadata and document type declarations
- `MrBase64Mascot.svg`, `MrBase64Portrait.svg` — mascot artwork
- `Tests/UnitTests/` — unit tests (XCTest)

Technical notes

- Platform: macOS 11.0+ (uses `UniformTypeIdentifiers`)
- Language: Swift 5 and SwiftUI
- Bundle identifier: `de.klngld.MrBase64`
- The app persists the output-format selection using `@AppStorage` (UserDefaults)

### Build from command line

You can build once you have an Xcode project set up:

```bash
xcodebuild -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug build
```

### If xcodebuild reports CommandLineTools is active

If `xcodebuild` fails with "requires Xcode, but active developer directory ... is a command line tools instance", run:

```bash
sudo xcode-select -s /Applications/Xcode.app
xcodebuild -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug build
```

## Usage

- **Drop & Drag**: Drop an image file onto the app window or its Dock icon
- **File Menu**: Use File → Open or Finder → Open With → MrBase64
- **Encoding**: The app displays Mr. Base64 alongside your image and produces a Base64 string
- **Copy Options**: 
  - *Copy Base64* — Copy the raw Base64 string
  - *Copy Markdown* — Copy a Markdown `data:` URL for embedding in `.md` files
- **Clear**: Reset and encode a new image

## Features

- **Drag & Drop Support**: Seamlessly drop images onto the window
- **File Open Integration**: Native macOS file open dialog and Finder integration
- **Base64 Encoding**: Standard Base64 format conversion
- **Markdown Export**: Ready-to-use Markdown data URLs for `.md` files
- **Wide Format Support**: PNG, JPEG, HEIC, HEIF, AVIF, WebP, TIFF, GIF, and more
- **Mr. Base64 Mascot**: A friendly, nerdy character with white shirt and nametag (Nerd Herd style!)

## Technical Details

- **Platform**: macOS 11.0+ (Big Sur) or later
- **Language**: Swift 5 with SwiftUI
- **APIs**: UniformTypeIdentifiers, NSPasteboard, AppKit
- **Bundle ID**: `de.klngld.MrBase64`

## Testing

Unit tests verify Base64 encoding and MIME type detection:

```bash
xcodebuild test -project MrBase64.xcodeproj -scheme MrBase64 -configuration Debug -destination 'platform=macOS'
```

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) automatically builds and tests on push/PR to main/master branches.

## Files

- `MrBase64App.swift` — App entry point, window management, file open integration
- `ContentView.swift` — Main UI with mascot display, drag & drop, copy actions, and MascotView
- `Base64Encoder.swift` — Base64 encoding and MIME type detection utilities
- `Info.plist` — App metadata, document type declarations, bundle identifier
- `MrBase64Mascot.svg` — Full-body mascot illustration (main interface)
- `MrBase64Portrait.svg` — Portrait mascot for app icon
- `Tests/UnitTests/Base64EncoderTests.swift` — Unit tests for encoding logic
- `.github/workflows/ci.yml` — CI/CD workflow

## AI provenance (disclaimer)

This project was developed with substantial assistance from an AI coding agent operating within the repository. The AI produced scaffolding, performed iterative edits, and helped configure the Xcode project. A human developer reviewed changes and ran local build/test cycles.

### Summary of AI-assisted work:

- Generated initial app scaffolding and source files
- Performed iterative `xcodebuild` debugging and fixed build/test settings
- Added unit tests and configured the test target linkage
- Renamed project and updated bundle identifiers to `de.klngld.MrBase64`
- Created mascot SVG artwork and integrated it into the UI
- Implemented persistent format selection and filename+timestamp reference-style Markdown generation

Note: Please review signing, entitlements, and distribution settings before releasing binaries.

If you would like, I can convert the portrait SVG into an AppIcon asset, add UI tests, or add multi-image reference numbering.

Last updated: 2025-12-21

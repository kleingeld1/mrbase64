# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-12-23
### Changed
- Moved encoding and file loading off the main thread to keep the UI responsive with large images.
- Reworked output rendering to use an `NSTextView` for smoother large-text updates.
- Added output caching so Base64/Markdown switching does not recompute or block.

## [1.0.0] - 2025-12-21
### Added
- Initial stable release of **MrBase64**: encode images to Base64 and copy output as raw Base64 or Markdown reference-style data-URLs.
- Persistent output preference using `@AppStorage`.
- Drag & drop support and File → Open integration.
- Professional mascot integrated via `Assets.xcassets/MascotCharacter.imageset`.
- App icon added and asset catalog fixes applied.
- `swiftlint` and `swiftformat` configuration added and a lint job (`.github/workflows/lint.yml`) added to CI.
- Main window fixed-size (non-resizable) and app quits when main window is closed.
- Unit tests for encoding and MIME type detection.

### Changed
- Various build and project configuration fixes to ensure asset catalog processing and successful local CI runs.

### Fixed
- Resolved app icon asset and `project.pbxproj` issues that prevented correct icon compilation.

---

(For previous development notes see the repository history.)

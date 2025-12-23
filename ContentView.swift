import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var nsImage: NSImage? = nil
    @State private var filename: String = ""
    @State private var sourceData: Data? = nil
    @State private var sourceUTI: String = UTType.image.identifier
    @State private var base64Cache: String? = nil
    @State private var markdownCache: String? = nil
    @State private var encodeToken = UUID()
    @State private var isTargeted: Bool = false
    @AppStorage("MrBase64.outputFormat") private var outputFormat: String = "base64"

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                ImagePreviewView(image: nsImage)

                ControlsView(
                    filename: filename,
                    outputFormat: $outputFormat,
                    canCopy: !displayedString.isEmpty,
                    onCopy: copyOutput,
                    onClear: clear
                )
                
                Spacer()
            }
            .padding()
            .onDrop(of: [UTType.fileURL.identifier, UTType.image.identifier], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
            .background(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)

            OutputView(text: displayedString)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didOpenFile)) { note in
            if let url = note.object as? URL {
                load(url: url)
            }
        }
        .onChange(of: outputFormat) { _ in
            generateOutput()
        }
    }

    var displayedString: String {
        if outputFormat == "markdown" {
            return markdownCache ?? ""
        }
        return base64Cache ?? ""
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for prov in providers {
            if prov.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                prov.loadFileRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { url, _ in
                    if let url = url {
                        load(url: url)
                        return
                    }
                    prov.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                        if let url = item as? URL {
                            load(url: url)
                            return
                        }
                        if let data = item as? Data {
                            if let url = URL(dataRepresentation: data, relativeTo: nil) {
                                load(url: url)
                                return
                            }
                            if let str = String(data: data, encoding: .utf8), let url = URL(string: str) {
                                load(url: url)
                            }
                        }
                    }
                }
                return true
            }
            if prov.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                prov.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    if let d = data {
                        let pastedFilename = "pasted-image"
                        DispatchQueue.global(qos: .userInitiated).async {
                            let image = NSImage(data: d)
                            DispatchQueue.main.async {
                            self.nsImage = image
                            self.filename = pastedFilename
                            self.sourceData = d
                            self.sourceUTI = UTType.image.identifier
                            self.base64Cache = nil
                            self.markdownCache = nil
                            self.generateOutput()
                        }
                    }
                }
                }
                return true
            }
        }
        return false
    }

    private func load(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url) else { return }
            let uti = (try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) ?? UTType.image.identifier
            let image = NSImage(data: data)
            DispatchQueue.main.async {
                self.nsImage = image
                self.filename = url.lastPathComponent
                self.sourceData = data
                self.sourceUTI = uti
                self.base64Cache = nil
                self.markdownCache = nil
                self.generateOutput()
            }
        }
    }

    private func generateOutput() {
        guard let data = sourceData else { return }
        if outputFormat == "markdown", markdownCache != nil { return }
        if outputFormat == "base64", base64Cache != nil { return }
        let resolvedFilename = filename.isEmpty ? "image" : filename
        let uti = sourceUTI
        let format = outputFormat
        let cachedBase64 = base64Cache
        let token = UUID()
        encodeToken = token
        DispatchQueue.global(qos: .userInitiated).async {
            let base64Used = cachedBase64 ?? Base64Encoder.base64String(from: data)
            let output: String
            if format == "markdown" {
                output = Base64Encoder.makeMarkdown(fromBase64: base64Used, filename: resolvedFilename, uti: uti).markdown
            } else {
                output = base64Used
            }
            DispatchQueue.main.async {
                if self.encodeToken == token {
                    if format == "markdown" {
                        self.markdownCache = output
                        self.base64Cache = base64Used
                    } else {
                        self.base64Cache = output
                    }
                }
            }
        }
    }

    private func copyOutput() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(displayedString, forType: .string)
    }

    private func clear() {
        nsImage = nil
        filename = ""
        sourceData = nil
        base64Cache = nil
        markdownCache = nil
    }
}

private struct ImagePreviewView: View {
    let image: NSImage?

    var body: some View {
        VStack {
            if let img = image {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180, maxHeight: 240)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            } else {
                MascotView()
                    .frame(width: 180, height: 280)
            }
        }
        .frame(width: 200)
    }
}

private struct ControlsView: View {
    let filename: String
    @Binding var outputFormat: String
    let canCopy: Bool
    let onCopy: () -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mr. Base64").font(.title2).fontWeight(.bold)
            Text("Encode your images to Base64").font(.caption).foregroundColor(.secondary)

            Divider()

            Text(filename.isEmpty ? "No image loaded" : filename)
                .font(.subheadline)
                .lineLimit(2)

            VStack(alignment: .leading, spacing: 8) {
                Text("Output Format").font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                Picker("Output Format", selection: $outputFormat) {
                    Text("Base64").tag("base64")
                    Text("Markdown").tag("markdown")
                }
                .labelsHidden()
                .pickerStyle(.radioGroup)
            }

            HStack(spacing: 8) {
                Button(action: onCopy) {
                    Label("Copy", systemImage: "doc.on.clipboard")
                }
                .disabled(!canCopy)
            }

            Button(action: onClear) {
                Label("Clear", systemImage: "xmark.circle")
            }
            .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct OutputView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainerInset = NSSize(width: 6, height: 6)
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.allowsUndo = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.layoutManager?.allowsNonContiguousLayout = true

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        textView.textContainer?.containerSize = NSSize(width: nsView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.frame.size.width = nsView.contentSize.width
        if textView.string != text, let storage = textView.textStorage {
            storage.beginEditing()
            storage.mutableString.setString(text)
            storage.endEditing()
        }
    }
}


struct MascotView: View {
    var body: some View {
        // Display the new Mr. Base64 mascot character (full-body illustration)
        // The image shows a professional character with glasses, white shirt, tie,
        // holding a document with base64 data and giving a thumbs up
        VStack {
            Image("MascotCharacter")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 280)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

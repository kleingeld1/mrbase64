import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var nsImage: NSImage? = nil
    @State private var base64String: String = ""
    @State private var markdownString: String = ""
    @State private var filename: String = ""
    @State private var isTargeted: Bool = false
    @AppStorage("MrBase64.outputFormat") private var outputFormat: String = "base64"

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                // Mr. Base64 Mascot on left
                VStack {
                    if let img = nsImage {
                        Image(nsImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180, maxHeight: 240)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                    } else {
                        // Show mascot illustration when no image is loaded
                        MascotView()
                            .frame(width: 180, height: 280)
                    }
                }
                .frame(width: 200)

                // Controls on right
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mr. Base64").font(.title2).fontWeight(.bold)
                    Text("Encode your images to Base64").font(.caption).foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text(filename.isEmpty ? "No image loaded" : filename)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Output Format").font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: outputFormat == "base64" ? "circle.fill" : "circle")
                                    .foregroundColor(outputFormat == "base64" ? .blue : .secondary)
                                Text("Base64")
                                    .font(.caption)
                                    .foregroundColor(outputFormat == "base64" ? .primary : .secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                outputFormat = "base64"
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: outputFormat == "markdown" ? "circle.fill" : "circle")
                                    .foregroundColor(outputFormat == "markdown" ? .blue : .secondary)
                                Text("Markdown")
                                    .font(.caption)
                                    .foregroundColor(outputFormat == "markdown" ? .primary : .secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                outputFormat = "markdown"
                            }
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: copyOutput) {
                            Label("Copy", systemImage: "doc.on.clipboard")
                        }
                        .disabled(base64String.isEmpty)
                    }
                    
                    Button(action: clear) {
                        Label("Clear", systemImage: "xmark.circle")
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Spacer()
            }
            .padding()
            .onDrop(of: [UTType.fileURL.identifier, UTType.image.identifier], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
            .background(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)

            TextEditor(text: Binding(
                get: { displayedString },
                set: { _ in }
            ))
                .font(.system(.body, design: .monospaced))
                .disabled(true)
                .frame(minHeight: 120)
                .padding([.leading, .trailing, .bottom])
        }
        .onReceive(NotificationCenter.default.publisher(for: .didOpenFile)) { note in
            if let url = note.object as? URL {
                load(url: url)
            }
        }
        .onAppear { }
    }

    var displayedString: String {
        outputFormat == "markdown" ? markdownString : base64String
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for prov in providers {
            if prov.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                prov.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    if let data = item as? Data, let str = String(data: data, encoding: .utf8), let url = URL(string: str) {
                        load(url: url)
                    } else if let url = item as? URL {
                        load(url: url)
                    }
                }
                return true
            }
            if prov.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                prov.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    if let d = data {
                        DispatchQueue.main.async {
                            self.nsImage = NSImage(data: d)
                            self.filename = "pasted-image"
                            encode(data: d, uti: UTType.image.identifier)
                        }
                    }
                }
                return true
            }
        }
        return false
    }

    private func load(url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        DispatchQueue.main.async {
            self.nsImage = NSImage(data: data)
            self.filename = url.lastPathComponent
            let uti = (try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) ?? UTType.image.identifier
            encode(data: data, uti: uti)
        }
    }

    private func encode(data: Data, uti: String) {
        let mime = Base64Encoder.mimeType(for: uti, fallbackFilename: filename)
        self.base64String = Base64Encoder.base64String(from: data)
        let dataUrl = "data:\(mime);base64,\(self.base64String)"
        
        // Generate reference from filename and timestamp (yymmdd-hhmmss)
        let filenameWithoutExt = (filename as NSString).deletingPathExtension
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd-HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let reference = "\(filenameWithoutExt)-\(timestamp)"
        
        self.markdownString = "![\(filename)][\(reference)]\n\n[\(reference)]: \(dataUrl)"
    }

    private func copyBase64() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(base64String, forType: .string)
    }

    private func copyMarkdown() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(markdownString, forType: .string)
    }

    private func copyOutput() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(displayedString, forType: .string)
    }

    private func clear() {
        nsImage = nil
        base64String = ""
        markdownString = ""
        filename = ""
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


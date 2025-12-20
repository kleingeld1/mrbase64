import SwiftUI
import AppKit

@main
struct MrBase64App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("MrBase64") {
            ContentView()
                .frame(minWidth: 700, minHeight: 400)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu("File") {
                Button("Open…") {
                    openPanel()
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
        }
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { resp in
            if resp == .OK, let url = panel.url {
                NotificationCenter.default.post(name: .didOpenFile, object: url)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            NotificationCenter.default.post(name: .didOpenFile, object: url)
        }
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let first = filenames.first {
            let url = URL(fileURLWithPath: first)
            NotificationCenter.default.post(name: .didOpenFile, object: url)
        }
        sender.reply(toOpenOrPrint: .success)
    }
}

extension Notification.Name {
    static let didOpenFile = Notification.Name("MrBase64.didOpenFile")
}

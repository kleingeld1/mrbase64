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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Make any created windows non-resizable and clamp size to current frame
        // This ensures the main window is fixed size and cannot be resized by the user.
        DispatchQueue.main.async {
            for window in NSApp.windows {
                window.styleMask.remove(.resizable)
                window.minSize = window.frame.size
                window.maxSize = window.frame.size
            }
        }

        // Also observe future windows in case SwiftUI creates them afterwards
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeMainNotification, object: nil, queue: .main) { note in
            if let window = note.object as? NSWindow {
                window.styleMask.remove(.resizable)
                window.minSize = window.frame.size
                window.maxSize = window.frame.size
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension Notification.Name {
    static let didOpenFile = Notification.Name("MrBase64.didOpenFile")
}

import AppKit

@MainActor
final class MenuBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let toggleItem = NSMenuItem()
    private let window: NSWindow
    private var notchVisible = true

    init(window: NSWindow) {
        self.window = window
        super.init()
        configure()
    }

    private func configure() {
        statusItem.button?.image = NSImage(
            systemSymbolName: "soccerball",
            accessibilityDescription: "SportsNotch"
        )

        toggleItem.title = "Hide Notch"
        toggleItem.action = #selector(toggleNotch)
        toggleItem.target = self

        let quitItem = NSMenuItem(title: "Quit SportsNotch", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self

        let menu = NSMenu()
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    @objc private func toggleNotch() {
        notchVisible.toggle()
        if notchVisible {
            window.orderFrontRegardless()
            toggleItem.title = "Hide Notch"
        } else {
            window.orderOut(nil)
            toggleItem.title = "Show Notch"
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

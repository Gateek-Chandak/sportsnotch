import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 300, height: 120),
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)
window.title = "Sportsnotch"
if let screen = NSScreen.main {
    let screenFrame = screen.frame
    let notchHeight = screen.safeAreaInsets.top
    let x = screenFrame.midX - window.frame.width / 2
    let y = screenFrame.maxY - notchHeight - window.frame.height
    window.setFrameOrigin(NSPoint(x: x, y: y))
}
window.makeKeyAndOrderFront(nil)

app.activate(ignoringOtherApps: true)
app.run()


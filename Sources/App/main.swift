import AppKit
import SwiftUI

final class ClickableHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main!
let screenFrame = screen.frame
let notchHeight = screen.safeAreaInsets.top > 0 ? screen.safeAreaInsets.top : 32

let notchWidth: CGFloat = {
    guard let left = screen.auxiliaryTopLeftArea,
          let right = screen.auxiliaryTopRightArea else { return 200 }
    return screenFrame.width - left.width - right.width
}()

let metrics = NotchMetrics(
    notchWidth: notchWidth,
    notchHeight: notchHeight,
    collapsedEar: 16,
    expandedEar: 58
)

let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: metrics.windowWidth, height: metrics.windowHeight),
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)

let originX = screenFrame.midX - metrics.windowWidth / 2
let originY = screenFrame.maxY - metrics.windowHeight
window.setFrameOrigin(NSPoint(x: originX, y: originY))

window.level = .statusBar
window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
window.isMovable = false
window.isOpaque = false
window.backgroundColor = .clear
window.hasShadow = false
window.acceptsMouseMovedEvents = true
window.contentView = ClickableHostingView(rootView: NotchView(games: Game.today, metrics: metrics))
window.makeKeyAndOrderFront(nil)

app.activate(ignoringOtherApps: true)
app.run()

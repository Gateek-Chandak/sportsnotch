import Foundation

struct NotchMetrics {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let collapsedEar: CGFloat
    let expandedEar: CGFloat
    var windowHeight: CGFloat = 540

    var windowWidth: CGFloat { notchWidth + expandedEar * 2 }
}

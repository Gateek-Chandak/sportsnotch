import Foundation

struct NotchMetrics {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    var collapsedEar: CGFloat = 16
    var expandedEar: CGFloat = 56
    var windowHeight: CGFloat = 540

    var windowWidth: CGFloat { notchWidth + expandedEar * 2 }
}

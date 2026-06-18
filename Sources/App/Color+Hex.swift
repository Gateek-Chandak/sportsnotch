import SwiftUI

extension Color {
    init(hex: String) {
        let (r, g, b) = rgb(hex)
        self.init(red: r, green: g, blue: b)
    }
}

func teamDotColors(
    awayColor: String, awayAltColor: String,
    homeColor: String, homeAltColor: String
) -> (away: Color, home: Color) {
    let away = visibleHex(awayColor, alt: awayAltColor)
    var home = visibleHex(homeColor, alt: homeAltColor)
    if colorsClash(away, home) {
        home = (home == homeColor) ? homeAltColor : homeColor
    }
    return (brightened(away), brightened(home))
}

private func visibleHex(_ primary: String, alt: String) -> String {
    isNearBlack(primary) ? alt : primary
}

private func brightened(_ hex: String) -> Color {
    var (r, g, b) = rgb(hex)
    let luminance = 0.299 * r + 0.587 * g + 0.114 * b
    if luminance < 0.06 {
        return Color(white: 0.92)
    }
    let floor = 0.45
    if luminance < floor {
        let factor = floor / luminance
        r = min(r * factor, 1)
        g = min(g * factor, 1)
        b = min(b * factor, 1)
    }
    return Color(red: r, green: g, blue: b)
}

private func isNearBlack(_ hex: String) -> Bool {
    let (r, g, b) = rgb(hex)
    return r + g + b < 0.25
}

private func colorsClash(_ a: String, _ b: String) -> Bool {
    let (r1, g1, b1) = rgb(a)
    let (r2, g2, b2) = rgb(b)
    return abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2) < 0.5
}

private func rgb(_ hex: String) -> (Double, Double, Double) {
    let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
    let value = UInt64(cleaned, radix: 16) ?? 0
    return (
        Double((value >> 16) & 0xFF) / 255,
        Double((value >> 8) & 0xFF) / 255,
        Double(value & 0xFF) / 255
    )
}

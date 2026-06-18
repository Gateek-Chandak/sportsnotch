import SwiftUI

extension Color {
    init(hex: String) {
        let (r, g, b) = hexToRGB(hex)
        self.init(red: r, green: g, blue: b)
    }
}

func hexToRGB(_ hex: String) -> (red: Double, green: Double, blue: Double) {
    let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
    let value = UInt64(cleaned, radix: 16) ?? 0
    return (
        Double((value >> 16) & 0xFF) / 255,
        Double((value >> 8) & 0xFF) / 255,
        Double(value & 0xFF) / 255
    )
}

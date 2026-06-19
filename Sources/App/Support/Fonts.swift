import SwiftUI
import CoreText

enum AppFont {
    static func register() {
        guard let url = Bundle.module.url(forResource: "Geist", withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}

extension Font {
    static func geist(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Geist", size: size).weight(weight)
    }
}

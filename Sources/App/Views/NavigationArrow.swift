import SwiftUI

struct NavigationArrow: View {
    let symbol: String
    let alignment: Alignment
    let enabled: Bool
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(enabled ? (hovering ? 1 : 0.5) : 0.15))
            .frame(width: 26, height: 22, alignment: alignment)
            .contentShape(Rectangle())
            .onHover { h in
                withAnimation(.easeOut(duration: 0.15)) { hovering = enabled && h }
            }
            .onTapGesture(perform: action)
    }
}

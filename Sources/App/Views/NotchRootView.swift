import SwiftUI

struct NotchRootView: View {
    let metrics: NotchMetrics
    @State private var store = LiveScoresStore()

    var body: some View {
        Group {
            if store.games.isEmpty {
                Color.clear
            } else {
                NotchView(games: store.games, metrics: metrics)
            }
        }
        .frame(width: metrics.windowWidth, height: metrics.windowHeight, alignment: .top)
        .task { await store.pollForever() }
    }
}

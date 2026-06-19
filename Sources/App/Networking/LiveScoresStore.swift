import Foundation
import Observation

@MainActor
@Observable
final class LiveScoresStore {
    private static let refreshInterval: Duration = .seconds(10)

    var games: [Game] = []

    func pollForever() async {
        while !Task.isCancelled {
            if let fetched = try? await fetchTodaysGames() {
                games = fetched
            }
            try? await Task.sleep(for: Self.refreshInterval)
        }
    }
}

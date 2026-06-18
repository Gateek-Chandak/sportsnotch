import Foundation
import Observation

@MainActor
@Observable
final class LiveScoresStore {
    var games: [Game] = []

    func pollForever() async {
        while !Task.isCancelled {
            if let fetched = try? await fetchTodaysGames() {
                games = fetched
            }
            try? await Task.sleep(for: .seconds(10))
        }
    }
}

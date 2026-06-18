import Foundation

private let scoreboardURL = URL(
    string: "https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard"
)!

func fetchTodaysGames() async throws -> [Game] {
    let (data, _) = try await URLSession.shared.data(from: scoreboardURL)
    let response = try JSONDecoder().decode(ESPNScoreboardResponse.self, from: data)
    return response.events.compactMap(makeGame)
}

private func makeGame(from event: ESPNEvent) -> Game? {
    guard let competition = event.competitions.first,
          let home = competition.competitors.first(where: { $0.homeAway == "home" }),
          let away = competition.competitors.first(where: { $0.homeAway == "away" })
    else { return nil }

    let state = competition.status.type.state
    let status = state == "pre"
        ? (kickoffTime(from: event.date) ?? competition.status.type.shortDetail)
        : competition.status.type.shortDetail

    let goals: [Goal] = (competition.details ?? []).compactMap { detail in
        guard detail.scoringPlay == true else { return nil }
        let kind: GoalKind = detail.ownGoal == true ? .ownGoal
            : detail.penaltyKick == true ? .penalty
            : .normal
        return Goal(
            minute: detail.clock?.displayValue ?? "",
            scorer: detail.athletesInvolved?.first?.shortName ?? "—",
            isHome: detail.team?.id == home.id,
            kind: kind
        )
    }

    return Game(
        awayAbbreviation: away.team.abbreviation,
        homeAbbreviation: home.team.abbreviation,
        awayScore: Int(away.score ?? "0") ?? 0,
        homeScore: Int(home.score ?? "0") ?? 0,
        status: status,
        isLive: state == "in",
        awayColor: away.team.color ?? "888888",
        homeColor: home.team.color ?? "888888",
        awayAltColor: away.team.alternateColor ?? "FFFFFF",
        homeAltColor: home.team.alternateColor ?? "FFFFFF",
        goals: goals
    )
}

private func kickoffTime(from iso: String?) -> String? {
    guard let iso else { return nil }
    let parser = DateFormatter()
    parser.locale = Locale(identifier: "en_US_POSIX")
    parser.timeZone = TimeZone(identifier: "UTC")
    parser.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
    guard let date = parser.date(from: iso) else { return nil }

    let formatter = DateFormatter()
    formatter.timeZone = .current
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
}

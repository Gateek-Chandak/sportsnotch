import Foundation

private let scoreboardURL = URL(
    string: "https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard"
)!

private let statDefinitions: [(name: String, label: String)] = [
    ("possessionPct", "Possession"),
    ("totalShots", "Shots"),
    ("shotsOnTarget", "On Target"),
    ("wonCorners", "Corners"),
    ("foulsCommitted", "Fouls"),
]

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

    let type = competition.status.type
    let status: String
    switch type.state {
    case "in": status = competition.status.displayClock ?? type.shortDetail
    case "pre": status = kickoffTime(from: event.date) ?? type.shortDetail
    default: status = readableStatus(type.shortDetail)
    }

    let events: [MatchEvent] = (competition.details ?? []).compactMap { detail in
        let kind: MatchEventKind
        if detail.scoringPlay == true {
            kind = detail.ownGoal == true ? .ownGoal : (detail.penaltyKick == true ? .penalty : .goal)
        } else if detail.redCard == true {
            kind = .redCard
        } else if detail.yellowCard == true {
            kind = .yellowCard
        } else {
            return nil
        }
        return MatchEvent(
            minute: detail.clock?.displayValue ?? "",
            player: detail.athletesInvolved?.first?.shortName ?? "—",
            isHome: detail.team?.id == home.id,
            kind: kind
        )
    }

    let stats: [TeamStat] = statDefinitions.compactMap { def in
        guard let awayValue = statValue(def.name, away),
              let homeValue = statValue(def.name, home) else { return nil }
        return TeamStat(
            label: def.label,
            away: formatStat(def.name, awayValue),
            home: formatStat(def.name, homeValue)
        )
    }

    return Game(
        awayAbbreviation: away.team.abbreviation,
        homeAbbreviation: home.team.abbreviation,
        awayScore: Int(away.score ?? "0") ?? 0,
        homeScore: Int(home.score ?? "0") ?? 0,
        status: status,
        isLive: type.state == "in",
        isFinished: type.state == "post",
        awayColor: away.team.color ?? "888888",
        homeColor: home.team.color ?? "888888",
        awayAltColor: away.team.alternateColor ?? "FFFFFF",
        homeAltColor: home.team.alternateColor ?? "FFFFFF",
        awayRecord: away.records?.first?.summary ?? "",
        homeRecord: home.records?.first?.summary ?? "",
        events: events,
        stats: stats
    )
}

private func statValue(_ name: String, _ competitor: ESPNCompetitor) -> String? {
    competitor.statistics?.first(where: { $0.name == name })?.displayValue
}

private func formatStat(_ name: String, _ value: String) -> String {
    guard name == "possessionPct" else { return value }
    return "\(Int((Double(value) ?? 0).rounded()))%"
}

private func readableStatus(_ status: String) -> String {
    switch status {
    case "FT": return "Full Time"
    case "HT": return "Half Time"
    default: return status
    }
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

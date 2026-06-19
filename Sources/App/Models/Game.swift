import Foundation

enum MatchEventKind {
    case goal, penalty, ownGoal, yellowCard, redCard
}

struct MatchEvent: Identifiable {
    let id = UUID()
    let minute: String
    let player: String
    let isHome: Bool
    let kind: MatchEventKind
}

struct TeamStat: Identifiable {
    let id = UUID()
    let label: String
    let away: String
    let home: String
}

struct Game: Identifiable {
    let id = UUID()
    let awayAbbreviation: String
    let homeAbbreviation: String
    let awayScore: Int
    let homeScore: Int
    let status: String
    let isLive: Bool
    let isFinished: Bool
    let awayColor: String
    let homeColor: String
    let awayAltColor: String
    let homeAltColor: String
    let awayRecord: String
    let homeRecord: String
    let events: [MatchEvent]
    let stats: [TeamStat]
}

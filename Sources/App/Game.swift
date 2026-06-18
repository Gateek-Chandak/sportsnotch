import Foundation

enum GoalKind {
    case normal, penalty, ownGoal

    var badge: String? {
        switch self {
        case .normal: return nil
        case .penalty: return "Penalty"
        case .ownGoal: return "Own Goal"
        }
    }
}

struct Goal: Identifiable {
    let id = UUID()
    let minute: String
    let scorer: String
    let isHome: Bool
    let kind: GoalKind
}

struct Game: Identifiable {
    let id = UUID()
    let awayAbbr: String
    let homeAbbr: String
    let awayScore: Int
    let homeScore: Int
    let status: String
    let isLive: Bool
    let awayColor: String
    let homeColor: String
    let awayAltColor: String
    let homeAltColor: String
    let goals: [Goal]
}

extension Game {
    static let sample = Game(
        awayAbbr: "JOR",
        homeAbbr: "AUT",
        awayScore: 1,
        homeScore: 3,
        status: "FT",
        isLive: false,
        awayColor: "E70000",
        homeColor: "d72b2c",
        awayAltColor: "ffffff",
        homeAltColor: "000000",
        goals: [
            Goal(minute: "21'", scorer: "R. Schmid", isHome: true, kind: .normal),
            Goal(minute: "50'", scorer: "A. Olwan", isHome: false, kind: .normal),
            Goal(minute: "76'", scorer: "Y. Al-Arab", isHome: true, kind: .ownGoal),
            Goal(minute: "90'+12'", scorer: "M. Arnautovic", isHome: true, kind: .penalty),
        ]
    )

    static let live = Game(
        awayAbbr: "ARG",
        homeAbbr: "BRA",
        awayScore: 1,
        homeScore: 2,
        status: "67'",
        isLive: true,
        awayColor: "75AADB",
        homeColor: "FFDF00",
        awayAltColor: "FFFFFF",
        homeAltColor: "009C3B",
        goals: [
            Goal(minute: "12'", scorer: "L. Messi", isHome: false, kind: .normal),
            Goal(minute: "34'", scorer: "Vinícius Jr", isHome: true, kind: .normal),
            Goal(minute: "61'", scorer: "Raphinha", isHome: true, kind: .penalty),
        ]
    )

    static let upcoming = Game(
        awayAbbr: "FRA",
        homeAbbr: "GER",
        awayScore: 0,
        homeScore: 0,
        status: "20:00 Kickoff",
        isLive: false,
        awayColor: "002654",
        homeColor: "000000",
        awayAltColor: "FFFFFF",
        homeAltColor: "FFFFFF",
        goals: []
    )

    static let today: [Game] = [sample, live, upcoming]
}

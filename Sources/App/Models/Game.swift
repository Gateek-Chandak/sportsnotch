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
    let awayAbbreviation: String
    let homeAbbreviation: String
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

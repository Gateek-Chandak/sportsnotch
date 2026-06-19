import Foundation

struct ESPNScoreboardResponse: Decodable {
    let events: [ESPNEvent]
}

struct ESPNEvent: Decodable {
    let date: String?
    let competitions: [ESPNCompetition]
}

struct ESPNCompetition: Decodable {
    let competitors: [ESPNCompetitor]
    let details: [ESPNDetail]?
    let status: ESPNStatus
}

struct ESPNStatus: Decodable {
    let displayClock: String?
    let type: ESPNStatusType
}

struct ESPNStatusType: Decodable {
    let shortDetail: String
    let state: String
}

struct ESPNCompetitor: Decodable {
    let id: String
    let homeAway: String
    let score: String?
    let team: ESPNTeam
    let records: [ESPNRecord]?
    let statistics: [ESPNStatistic]?
}

struct ESPNTeam: Decodable {
    let abbreviation: String
    let color: String?
    let alternateColor: String?
}

struct ESPNRecord: Decodable {
    let summary: String
}

struct ESPNStatistic: Decodable {
    let name: String
    let displayValue: String
}

struct ESPNDetail: Decodable {
    let clock: ESPNClock?
    let scoringPlay: Bool?
    let penaltyKick: Bool?
    let ownGoal: Bool?
    let yellowCard: Bool?
    let redCard: Bool?
    let team: ESPNTeamRef?
    let athletesInvolved: [ESPNAthlete]?
}

struct ESPNClock: Decodable {
    let displayValue: String
}

struct ESPNTeamRef: Decodable {
    let id: String
}

struct ESPNAthlete: Decodable {
    let shortName: String
}

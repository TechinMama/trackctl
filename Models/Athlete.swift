import Foundation

enum AthleteStatus: String, Codable, CaseIterable {
    case active   = "active"
    case injured  = "injured"
    case inactive = "inactive"
    case retired  = "retired"
    case archived = "archived"

    var isVisible: Bool {
        self != .archived
    }
}

struct Athlete: Identifiable, Codable {
    let id: String
    let name: String
    let country: String
    let discipline: String
    let personalBest: String
    var isFollowing: Bool
    let recentResults: [Result]
    var status: AthleteStatus

    enum CodingKeys: String, CodingKey {
        case id, name, country, discipline, status
        case personalBest = "personal_best"
        case isFollowing = "is_following"
        case recentResults = "recent_results"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        name          = try c.decode(String.self, forKey: .name)
        country       = try c.decodeIfPresent(String.self, forKey: .country) ?? ""
        discipline    = try c.decodeIfPresent(String.self, forKey: .discipline) ?? ""
        personalBest  = try c.decodeIfPresent(String.self, forKey: .personalBest) ?? ""
        isFollowing   = try c.decodeIfPresent(Bool.self, forKey: .isFollowing) ?? false
        recentResults = try c.decodeIfPresent([Result].self, forKey: .recentResults) ?? []
        status        = try c.decodeIfPresent(AthleteStatus.self, forKey: .status) ?? .active
    }
}

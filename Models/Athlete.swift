import Foundation

enum AthleteStatus: String, Codable, CaseIterable {
    case active
    case injured
    case inactive
    case retired
    case archived

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
}

extension Athlete {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id            = try container.decode(String.self, forKey: .id)
        name          = try container.decode(String.self, forKey: .name)
        country       = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        discipline    = try container.decodeIfPresent(String.self, forKey: .discipline) ?? ""
        personalBest  = try container.decodeIfPresent(String.self, forKey: .personalBest) ?? ""
        isFollowing   = try container.decodeIfPresent(Bool.self, forKey: .isFollowing) ?? false
        recentResults = try container.decodeIfPresent([Result].self, forKey: .recentResults) ?? []
        status        = try container.decodeIfPresent(AthleteStatus.self, forKey: .status) ?? .active
    }
}

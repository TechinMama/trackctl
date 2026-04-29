import Foundation

struct Athlete: Identifiable, Codable {
    let id: String
    let name: String
    let country: String
    let discipline: String
    let personalBest: String
    let profileImageURL: URL?
    var isFollowing: Bool
    let recentResults: [Result]
    
    enum CodingKeys: String, CodingKey {
        case id, name, country, discipline
        case personalBest = "personal_best"
        case profileImageURL = "profile_image_url"
        case isFollowing = "is_following"
        case recentResults = "recent_results"
    }
}

import Foundation

struct Meet: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let date: Date
    let events: [Event]
    let competitiveLevel: String
    let watchURL: URL?
    let status: MeetStatus
    
    enum CodingKeys: String, CodingKey {
        case id, name, location, date, events
        case competitiveLevel = "competitive_level"
        case watchURL = "watch_url"
        case status
    }
}

enum MeetStatus: String, Codable {
    case upcoming, ongoing, completed
}

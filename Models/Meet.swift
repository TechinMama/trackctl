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

    init(
        id: String,
        name: String,
        location: String,
        date: Date,
        events: [Event],
        competitiveLevel: String,
        watchURL: URL?,
        status: MeetStatus
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.date = date
        self.events = events
        self.competitiveLevel = competitiveLevel
        self.watchURL = watchURL
        self.status = status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? "TBD"
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        events = try container.decodeIfPresent([Event].self, forKey: .events) ?? []
        competitiveLevel = try container.decodeIfPresent(String.self, forKey: .competitiveLevel) ?? ""
        watchURL = try container.decodeIfPresent(URL.self, forKey: .watchURL)
        status = try container.decodeIfPresent(MeetStatus.self, forKey: .status) ?? .upcoming
    }
}

enum MeetStatus: String, Codable {
    case upcoming, ongoing, completed
}

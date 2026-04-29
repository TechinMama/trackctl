import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let name: String
    let discipline: String
    let meetID: String
    let scheduledTime: Date
    let results: [Result]
    
    enum CodingKeys: String, CodingKey {
        case id, name, discipline
        case meetID = "meet_id"
        case scheduledTime = "scheduled_time"
        case results
    }
}

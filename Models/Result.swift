import Foundation

struct Result: Identifiable, Codable {
    let id: String
    let athleteID: String
    let athleteName: String
    let eventID: String
    let eventName: String
    let placement: Int
    let time: String?
    let date: Date
    let aiInsight: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case athleteID = "athlete_id"
        case athleteName = "athlete_name"
        case eventID = "event_id"
        case eventName = "event_name"
        case placement, time, date
        case aiInsight = "ai_insight"
    }
}

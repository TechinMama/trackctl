import Foundation

struct CompetitiveStoryline: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let relatedAthletes: [Athlete]
    let relatedMeets: [Meet]
    let aiGeneratedInsight: String
    let createdDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case relatedAthletes = "related_athletes"
        case relatedMeets = "related_meets"
        case aiGeneratedInsight = "ai_generated_insight"
        case createdDate = "created_date"
    }
}

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

    init(
        id: String,
        title: String,
        description: String,
        relatedAthletes: [Athlete],
        relatedMeets: [Meet],
        aiGeneratedInsight: String,
        createdDate: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.relatedAthletes = relatedAthletes
        self.relatedMeets = relatedMeets
        self.aiGeneratedInsight = aiGeneratedInsight
        self.createdDate = createdDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        relatedAthletes = try container.decodeIfPresent([Athlete].self, forKey: .relatedAthletes) ?? []
        relatedMeets = try container.decodeIfPresent([Meet].self, forKey: .relatedMeets) ?? []
        aiGeneratedInsight = try container.decodeIfPresent(String.self, forKey: .aiGeneratedInsight)
            ?? "Insight unavailable pending guardrail review."
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
    }
}

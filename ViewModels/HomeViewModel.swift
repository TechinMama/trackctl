import Foundation
import Observation

@MainActor
@Observable
class HomeViewModel {
    var storylines: [CompetitiveStoryline] = []
    var upcomingMeets: [Meet] = []
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?
    var generatedAt: Date?
    var sourceCitationText = NotificationService.sourceCitationText
    var dataWarning: String?
    var isUsingFallback = false
    
    private let apiService = APIService.shared
    private let followedIDsKey = "athena.followedAthleteIDs"
    
    @MainActor
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        dataWarning = nil
        isUsingFallback = false
        
        async let storylinesTask = apiService.fetchCompetitiveStorylines()
        async let meetsTask = apiService.fetchUpcomingMeets()

        let (storylineResponse, meetResponse) = await (storylinesTask, meetsTask)
        self.storylines = rankStorylines(storylineResponse.value)
        self.upcomingMeets = meetResponse.value

        let fetchedTimes = [storylineResponse.metadata.fetchedAt, meetResponse.metadata.fetchedAt]
        self.lastUpdated = fetchedTimes.max()
        self.generatedAt = [storylineResponse.metadata.generatedAt, meetResponse.metadata.generatedAt].compactMap { $0 }.max()

        let citations = Array(Set(storylineResponse.metadata.citations + meetResponse.metadata.citations)).sorted()
        self.sourceCitationText = citations.isEmpty ? NotificationService.sourceCitationText : "Sources: \(citations.joined(separator: " • "))"

        self.isUsingFallback = storylineResponse.metadata.source == .fallback || meetResponse.metadata.source == .fallback
        let warnings = [storylineResponse.metadata.warning, meetResponse.metadata.warning].compactMap { $0 }
        self.dataWarning = warnings.first
        isLoading = false
    }

    private func rankStorylines(_ items: [CompetitiveStoryline]) -> [CompetitiveStoryline] {
        let followedIDs = Set(UserDefaults.standard.stringArray(forKey: followedIDsKey) ?? [])

        return items.sorted { lhs, rhs in
            storylineScore(lhs, followedIDs: followedIDs) > storylineScore(rhs, followedIDs: followedIDs)
        }
    }

    private func storylineScore(_ item: CompetitiveStoryline, followedIDs: Set<String>) -> Int {
        var score = 40

        if !followedIDs.isEmpty {
            let related = Set(item.relatedAthletes.map { $0.id })
            let overlap = related.intersection(followedIDs).count
            score += overlap * 18
        }

        let upcomingRelatedMeets = item.relatedMeets.filter { $0.status == .upcoming }.count
        score += min(upcomingRelatedMeets * 8, 16)

        let hoursAgo = Date().timeIntervalSince(item.createdDate) / 3600
        if hoursAgo <= 24 {
            score += 14
        } else if hoursAgo <= 72 {
            score += 8
        } else if hoursAgo <= 168 {
            score += 4
        }

        return score
    }

    @MainActor
    func headlineRankingExplanation() -> String {
        "Ranked by followed athletes, upcoming meet relevance, and storyline recency."
    }
}

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
    
    private let apiService = APIService.shared
    private let followedIDsKey = "athena.followedAthleteIDs"
    
    @MainActor
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let storylinesTask = apiService.fetchCompetitiveStorylines()
            async let meetsTask = apiService.fetchUpcomingMeets()
            
            let (fetchedStorylines, fetchedMeets) = try await (storylinesTask, meetsTask)
            self.storylines = rankStorylines(fetchedStorylines)
            self.upcomingMeets = fetchedMeets
            self.lastUpdated = Date()
            isLoading = false
        } catch {
            errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
            isLoading = false
        }
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

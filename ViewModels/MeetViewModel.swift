import Foundation
import Observation

@MainActor
@Observable
class MeetViewModel {
    var meets: [Meet] = []
    var upcomingMeets: [Meet] = []
    var selectedMeet: Meet?
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?
    var generatedAt: Date?
    var sourceCitationText = NotificationService.sourceCitationText
    var dataWarning: String?
    var isUsingFallback = false
    
    private let apiService = APIService.shared
    
    @MainActor
    func loadMeets() async {
        isLoading = true
        errorMessage = nil

        let response = await apiService.fetchMeets()
        meets = response.value
        upcomingMeets = meets.filter { $0.status == .upcoming }
        lastUpdated = response.metadata.fetchedAt
        generatedAt = response.metadata.generatedAt
        sourceCitationText = response.metadata.citations.isEmpty
            ? NotificationService.sourceCitationText
            : "Sources: \(response.metadata.citations.joined(separator: " • "))"
        isUsingFallback = response.metadata.source == .fallback
        dataWarning = response.metadata.warning
        isLoading = false
    }
    
    @MainActor
    func selectMeet(id: String) async {
        do {
            selectedMeet = try await apiService.fetchMeet(id: id)
            if let meet = selectedMeet {
                NotificationService.shared.scheduleMeetReminder(meet: meet)
            }
        } catch {
            errorMessage = "Failed to load meet details: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func getMeetsByStatus(_ status: MeetStatus) -> [Meet] {
        let filtered = meets.filter { $0.status == status }
        if status == .upcoming {
            return filtered.sorted { watchPriorityScore(for: $0) > watchPriorityScore(for: $1) }
        }
        return filtered.sorted { $0.date > $1.date }
    }

    @MainActor
    func watchPriorityScore(for meet: Meet) -> Int {
        var score = 60

        switch meet.competitiveLevel.lowercased() {
        case let level where level.contains("world"):
            score += 28
        case let level where level.contains("diamond"):
            score += 18
        default:
            score += 10
        }

        score += min(meet.events.count * 2, 10)
        if meet.watchURL != nil {
            score += 6
        }

        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: meet.date).day ?? 0
        if daysUntil < 0 {
            score -= 14
        } else if daysUntil <= 3 {
            score += 10
        } else if daysUntil <= 7 {
            score += 7
        } else if daysUntil <= 21 {
            score += 3
        }

        return max(0, min(100, score))
    }

    @MainActor
    func watchPriorityLabel(for meet: Meet) -> String {
        let score = watchPriorityScore(for: meet)
        if score >= 90 { return "Elite Watch" }
        if score >= 80 { return "High Priority" }
        if score >= 70 { return "Strong Watch" }
        return "Watchlist"
    }

    @MainActor
    func watchPriorityExplanation(for meet: Meet) -> String {
        "Score uses competition level, event depth, watch availability, and event timing."
    }
}

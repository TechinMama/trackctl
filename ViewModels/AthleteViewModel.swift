import Foundation
import Observation

@MainActor
@Observable
class AthleteViewModel {
    var athletes: [Athlete] = []
    var followingAthletes: [Athlete] = []
    var selectedAthlete: Athlete?
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?
    var dataWarning: String?
    
    private let apiService = APIService.shared
    private let followedIDsKey = "athena.followedAthleteIDs"

    private var followedIDs: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: followedIDsKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: followedIDsKey) }
    }

    @MainActor
    func loadAthletes() async {
        isLoading = true
        errorMessage = nil
        dataWarning = nil
        
        let response = await apiService.fetchAthletes()
        athletes = response.value
        let saved = followedIDs
        for i in athletes.indices {
            athletes[i].isFollowing = saved.contains(athletes[i].id)
        }
        followingAthletes = athletes.filter { $0.isFollowing }
        lastUpdated = response.metadata.fetchedAt
        dataWarning = response.metadata.warning
        isLoading = false
    }
    
    @MainActor
    func selectAthlete(id: String) async {
        do {
            selectedAthlete = try await apiService.fetchAthlete(id: id)
        } catch {
            errorMessage = "Failed to load athlete details: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func followAthlete(id: String) async {
        guard let index = athletes.firstIndex(where: { $0.id == id }) else { return }
        athletes[index].isFollowing.toggle()
        followingAthletes = athletes.filter { $0.isFollowing }
        var saved = followedIDs
        if athletes[index].isFollowing {
            saved.insert(id)
        } else {
            saved.remove(id)
        }
        followedIDs = saved

        if !athletes[index].isFollowing {
            NotificationService.shared.setAthleteAlertEnabled(athleteID: id, enabled: false)
        }
    }

    @MainActor
    func isAthleteNotificationEnabled(id: String) -> Bool {
        NotificationService.shared.isAthleteAlertEnabled(athleteID: id)
    }

    @MainActor
    func setAthleteNotificationEnabled(id: String, enabled: Bool) {
        NotificationService.shared.setAthleteAlertEnabled(athleteID: id, enabled: enabled)
    }

    @MainActor
    func momentumScore(for athlete: Athlete) -> Int {
        guard !athlete.recentResults.isEmpty else { return 55 }

        var score = 55
        for result in athlete.recentResults {
            switch result.placement {
            case 1:
                score += 18
            case 2:
                score += 12
            case 3:
                score += 8
            case 4...8:
                score += 4
            default:
                score -= 2
            }

            let daysAgo = Calendar.current.dateComponents([.day], from: result.date, to: Date()).day ?? 45
            if daysAgo <= 14 {
                score += 8
            } else if daysAgo <= 30 {
                score += 5
            } else if daysAgo <= 60 {
                score += 2
            }
        }

        return max(0, min(100, score))
    }

    @MainActor
    func momentumLabel(for athlete: Athlete) -> String {
        let score = momentumScore(for: athlete)
        if score >= 85 { return "Surging" }
        if score >= 72 { return "In Form" }
        if score >= 60 { return "Steady" }
        return "Building"
    }

    @MainActor
    func momentumSummary(for athlete: Athlete) -> String {
        let score = momentumScore(for: athlete)
        return "Momentum Index \(score). Based on placement quality and recent form over a 30-60 day window."
    }

    @MainActor
    func resetFollowingPreferences() {
        followedIDs = []
        for i in athletes.indices {
            athletes[i].isFollowing = false
            NotificationService.shared.setAthleteAlertEnabled(athleteID: athletes[i].id, enabled: false)
        }
        followingAthletes = []
    }
}

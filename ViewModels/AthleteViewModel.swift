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

    var searchQuery: String = ""
    private let pageSize = 40
    private(set) var loadedPageCount: Int = 1

    var filteredAthletes: [Athlete] {
        let base = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? athletes
            : athletes.filter { athlete in
                    let query = searchQuery.lowercased()
                    return athlete.name.lowercased().contains(query)
                        || athlete.country.lowercased().contains(query)
                        || athlete.discipline.lowercased().contains(query)
            }
        let limit = loadedPageCount * pageSize
        var paged: [Athlete] = []
            for athlete in base {
                paged.append(athlete)
            if paged.count == limit { break }
        }
        return paged
    }

    var hasMoreAthletes: Bool {
        let base = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? athletes
            : athletes.filter { athlete in
                    let query = searchQuery.lowercased()
                    return athlete.name.lowercased().contains(query)
                        || athlete.country.lowercased().contains(query)
                        || athlete.discipline.lowercased().contains(query)
            }
        return filteredAthletes.count < base.count
    }

    func loadNextPage() {
        loadedPageCount += 1
    }

    func resetSearch() {
        searchQuery = ""
        loadedPageCount = 1
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
        loadedPageCount = 1
    }
    
    private let apiService = APIService.shared
    private let followedIDsKey = "athena.followedAthleteIDs"
    private let athleteDirectoryCapKey = "athena.athleteDirectoryCap"
    private let athleteActiveWindowDays = 365

    private var athleteDirectoryCap: Int {
        let configured = UserDefaults.standard.integer(forKey: athleteDirectoryCapKey)
        return configured > 0 ? configured : 200
    }

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
        athletes = curatedDirectoryAthletes(from: response.value)
        let saved = followedIDs
        for index in athletes.indices {
            athletes[index].isFollowing = saved.contains(athletes[index].id)
        }
        followingAthletes = athletes.filter { $0.isFollowing }
        lastUpdated = response.metadata.fetchedAt
        dataWarning = response.metadata.warning
        if let warning = response.metadata.warning {
            AthenaLogger.shared.warning("athletes_load_warning", props: ["reason": warning])
        }
        AthenaLogger.shared.event("athletes_loaded", props: ["count": athletes.count])
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
            AthenaLogger.shared.event("athlete_followed", props: ["id": id])
        } else {
            saved.remove(id)
            AthenaLogger.shared.event("athlete_unfollowed", props: ["id": id])
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
    func athleteEventLabels(for athlete: Athlete, limit: Int = 5) -> [String] {
        let resultEvents = athlete.recentResults
            .map { $0.eventName.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if !resultEvents.isEmpty {
            var seen = Set<String>()
            var unique: [String] = []
            for event in resultEvents where !seen.contains(event) {
                seen.insert(event)
                unique.append(event)
                if unique.count == limit {
                    break
                }
            }
            return unique
        }

        let disciplineLabels = athlete.discipline
            .split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var limited: [String] = []
        for label in disciplineLabels {
            limited.append(label)
            if limited.count == limit {
                break
            }
        }

        return limited
    }

    @MainActor
    func curatedDirectoryAthletes(from candidates: [Athlete], now: Date = Date()) -> [Athlete] {
        let sorted = candidates
            .filter { isCurrentRunner($0, now: now) }
            .sorted { lhs, rhs in
                let lhsDate = lhs.recentResults.map(\.date).max() ?? .distantPast
                let rhsDate = rhs.recentResults.map(\.date).max() ?? .distantPast
                if lhsDate == rhsDate {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhsDate > rhsDate
            }

        var limited: [Athlete] = []
        for athlete in sorted {
            limited.append(athlete)
            if limited.count == athleteDirectoryCap {
                break
            }
        }

        return limited
    }

    private func isCurrentRunner(_ athlete: Athlete, now: Date) -> Bool {
        let runningSignalFromResults = athlete.recentResults.contains { isRunningDiscipline($0.eventName) }
        let runningSignalFromDiscipline = isRunningDiscipline(athlete.discipline)
        guard runningSignalFromResults || runningSignalFromDiscipline else {
            return false
        }

        guard let mostRecentCompetition = athlete.recentResults.map(\.date).max() else {
            return false
        }

        let daysSince = Calendar.current.dateComponents([.day], from: mostRecentCompetition, to: now).day ?? Int.max
        return daysSince >= 0 && daysSince <= athleteActiveWindowDays
    }

    private func isRunningDiscipline(_ value: String) -> Bool {
        let normalized = value.lowercased()

        let fieldSignals = ["vault", "jump", "shot put", "discus", "javelin", "hammer", "heptathlon", "decathlon", "throws"]
        if fieldSignals.contains(where: { normalized.contains($0) }) {
            return false
        }

        if normalized.range(of: #"\b\d{2,5}m(h)?\b"#, options: .regularExpression) != nil {
            return true
        }

        let runningSignals = ["hurdle", "steeple", "relay", "marathon", "mile", "sprint", "distance", "run", "xc", "cross country"]
        return runningSignals.contains(where: { normalized.contains($0) })
    }

    @MainActor
    func resetFollowingPreferences() {
        followedIDs = []
            for index in athletes.indices {
                athletes[index].isFollowing = false
                NotificationService.shared.setAthleteAlertEnabled(athleteID: athletes[index].id, enabled: false)
        }
        followingAthletes = []
    }
}

import Foundation
import Observation

@MainActor
@Observable
class AnalyticsViewModel {

    // MARK: - Ranking Impact

    func rankingImpact(for result: Result, now: Date = Date()) -> RankingImpactScore {
        let prestige = eventPrestige(for: result.eventName)
        let placement = placementPoints(for: result.placement)
        let recency = recencyBonus(for: result.date, now: now)
        let total = min(100, prestige + placement + recency)
        return RankingImpactScore(
            score: total,
            band: rankingImpactBand(for: total),
            eventPrestige: prestige,
            placementPoints: placement,
            recencyBonus: recency
        )
    }

    private func rankingImpactBand(for score: Int) -> RankingImpactScore.Band {
        switch score {
        case 85...: return .major
        case 65...: return .high
        case 40...: return .moderate
        default:    return .low
        }
    }

    // MARK: - Breakout Radar

    func breakoutRadar(for athlete: Athlete, now: Date = Date()) -> BreakoutScore {
        let results = athlete.recentResults
        let tier = detectTier(for: athlete)
        let quality    = breakoutCompetitionQuality(results: results)
        let dominance  = tierDominance(results: results)
        let velocity   = improvementVelocity(results: results)
            let repeatScore = repeatability(results: results)
        let recency    = breakoutRecency(results: results, now: now)
            let total = min(100, quality + dominance + velocity + repeatScore + recency)
        return BreakoutScore(
            score: total,
            band: breakoutBand(for: total),
            tier: tier,
            competitionQuality: quality,
            tierDominance: dominance,
            improvementVelocity: velocity,
                repeatability: repeatScore,
            recencyBonus: recency
        )
    }

    private func detectTier(for athlete: Athlete) -> BreakoutScore.Tier {
        let lower = athlete.discipline.lowercased()
        if lower.contains("high school") || lower.contains(" hs ") { return .highSchool }
        if lower.contains("ncaa") || lower.contains("collegiate") { return .ncaa }
        return .professional
    }

    private func breakoutCompetitionQuality(results: [Result]) -> Int {
        guard !results.isEmpty else { return 0 }
        let avg = results.map { eventPrestige(for: $0.eventName) }.reduce(0, +) / results.count
        return min(30, avg)
    }

    private func tierDominance(results: [Result]) -> Int {
        guard !results.isEmpty else { return 0 }
        let avg = Double(results.map(\.placement).reduce(0, +)) / Double(results.count)
        switch avg {
        case ..<1.5: return 20
        case ..<2.5: return 16
        case ..<3.5: return 12
        case ..<5.0: return 8
        default:     return 3
        }
    }

    private func improvementVelocity(results: [Result]) -> Int {
        let sorted = results.sorted { $0.date < $1.date }
        guard sorted.count >= 2 else { return 5 }
        let half = sorted.count / 2
        let oldAvg = Double(sorted.prefix(half).map(\.placement).reduce(0, +)) / Double(half)
        let newHalf = sorted.count - half
        let newAvg = Double(sorted.suffix(newHalf).map(\.placement).reduce(0, +)) / Double(newHalf)
        if newAvg < oldAvg - 1.0 { return 20 }
        if newAvg < oldAvg { return 14 }
        if newAvg == oldAvg { return 8 }
        return 2
    }

    private func repeatability(results: [Result]) -> Int {
        switch results.count {
        case 5...: return 15
        case 3..<5: return 10
        case 2:     return 6
        case 1:     return 3
        default:    return 0
        }
    }

    private func breakoutRecency(results: [Result], now: Date) -> Int {
        guard let mostRecent = results.map(\.date).max() else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: mostRecent, to: now).day ?? Int.max
        if days <= 30 { return 15 }
        if days <= 60 { return 10 }
        if days <= 90 { return 5 }
        return 0
    }

    private func breakoutBand(for score: Int) -> BreakoutScore.Band {
        switch score {
        case 80...: return .breakoutPriority
        case 60...: return .breakout
        case 40...: return .emerging
        default:    return .watchlist
        }
    }

    // MARK: - Record Threat

    func recordThreat(for athlete: Athlete, now: Date = Date()) -> RecordThreatScore {
        let results = athlete.recentResults
        let eliteRate  = eliteFinishRate(results: results)
        let peakCount  = peakPerformanceCount(results: results)
        let prestige   = recordMeetPrestige(results: results)
        let trend      = trendDirection(results: results)
        let total = min(100, eliteRate + peakCount + prestige + trend)
        return RecordThreatScore(
            score: total,
            band: recordBand(for: total),
            eliteFinishRate: eliteRate,
            peakPerformanceCount: peakCount,
            meetPrestige: prestige,
            trendDirection: trend
        )
    }

    private func eliteFinishRate(results: [Result]) -> Int {
        guard !results.isEmpty else { return 0 }
        let wins = results.filter { $0.placement == 1 }.count
        return Int(Double(wins) / Double(results.count) * 35)
    }

    private func peakPerformanceCount(results: [Result]) -> Int {
        guard !results.isEmpty else { return 0 }
        let topThree = results.filter { $0.placement <= 3 }.count
        return Int(Double(topThree) / Double(results.count) * 25)
    }

    private func recordMeetPrestige(results: [Result]) -> Int {
        guard !results.isEmpty else { return 0 }
        let avg = results.map { eventPrestige(for: $0.eventName) }.reduce(0, +) / results.count
        return Int(Double(avg) / 30.0 * 20.0)
    }

    private func trendDirection(results: [Result]) -> Int {
        let sorted = results.sorted { $0.date < $1.date }
        guard sorted.count >= 2 else { return 5 }
        let half = sorted.count / 2
        let oldAvg = Double(sorted.prefix(half).map(\.placement).reduce(0, +)) / Double(half)
        let newHalf = sorted.count - half
        let newAvg = Double(sorted.suffix(newHalf).map(\.placement).reduce(0, +)) / Double(newHalf)
        if newAvg < oldAvg - 1.0 { return 20 }
        if newAvg < oldAvg { return 14 }
        if newAvg == oldAvg { return 10 }
        return 5
    }

    private func recordBand(for score: Int) -> RecordThreatScore.Band {
        switch score {
        case 85...: return .eliteWatch
        case 65...: return .highPriority
        case 40...: return .strongWatch
        default:    return .watch
        }
    }

    // MARK: - Rivalry Heat

    func rivalryHeat(
        athleteA: Athlete, momentumA: Int,
        athleteB: Athlete, momentumB: Int,
        now: Date = Date()
    ) -> RivalryHeatScore {
        let discipline    = sharedDisciplineScore(athleteA: athleteA, athleteB: athleteB)
        let momentum      = momentumProximityScore(momentumA: momentumA, momentumB: momentumB)
        let h2h           = headToHeadScore(athleteA: athleteA, athleteB: athleteB)
        let overlap       = recentOverlapScore(athleteA: athleteA, athleteB: athleteB, now: now)
        let championship  = championshipRelevanceScore(now: now)
        let total = min(100, discipline + momentum + h2h + overlap + championship)
        return RivalryHeatScore(
            score: total,
            band: rivalryBand(for: total),
            athleteAID: athleteA.id,
            athleteAName: athleteA.name,
            athleteBID: athleteB.id,
            athleteBName: athleteB.name,
            sharedDiscipline: discipline,
            momentumProximity: momentum,
            headToHead: h2h,
            recentOverlap: overlap,
            championshipRelevance: championship
        )
    }

    func topRivals(
        for athlete: Athlete,
        candidates: [Athlete],
        momentumScore: (Athlete) -> Int,
        limit: Int = 3,
        now: Date = Date()
    ) -> [(Athlete, RivalryHeatScore)] {
        let myMomentum = momentumScore(athlete)
        let scored = candidates
            .filter { $0.id != athlete.id }
            .map { other in
                (other, rivalryHeat(
                    athleteA: athlete, momentumA: myMomentum,
                    athleteB: other, momentumB: momentumScore(other),
                    now: now
                ))
            }
        let sorted = scored.sorted { $0.1.score > $1.1.score }
        var result: [(Athlete, RivalryHeatScore)] = []
        for pair in sorted {
            result.append(pair)
            if result.count == limit { break }
        }
        return result
    }

    private func sharedDisciplineScore(athleteA: Athlete, athleteB: Athlete) -> Int {
        let aLabels = Set(athleteA.discipline.lowercased().split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) })
        let bLabels = Set(athleteB.discipline.lowercased().split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) })
        if !aLabels.isDisjoint(with: bLabels) { return 30 }

        let aEvents = Set(athleteA.recentResults.map { $0.eventName.lowercased() })
        let bEvents = Set(athleteB.recentResults.map { $0.eventName.lowercased() })
        if !aEvents.isDisjoint(with: bEvents) { return 25 }

        let aWords = Set(aLabels.flatMap { $0.split(separator: " ").map(String.init) })
        let bWords = Set(bLabels.flatMap { $0.split(separator: " ").map(String.init) })
        if !aWords.isDisjoint(with: bWords) { return 15 }
        return 0
    }

    private func momentumProximityScore(momentumA: Int, momentumB: Int) -> Int {
        let delta = abs(momentumA - momentumB)
        if delta <= 5 { return 25 }
        if delta <= 15 { return 18 }
        if delta <= 25 { return 10 }
        return 3
    }

    private func headToHeadScore(athleteA: Athlete, athleteB: Athlete) -> Int {
        let aEventIDs = Set(athleteA.recentResults.map(\.eventID))
        let bEventIDs = Set(athleteB.recentResults.map(\.eventID))
        switch aEventIDs.intersection(bEventIDs).count {
        case 3...: return 20
        case 2:    return 14
        case 1:    return 7
        default:   return 0
        }
    }

    private func recentOverlapScore(athleteA: Athlete, athleteB: Athlete, now: Date) -> Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: now) ?? now
        let aNames = Set(athleteA.recentResults.filter { $0.date >= cutoff }.map { $0.eventName.lowercased() })
        let bNames = Set(athleteB.recentResults.filter { $0.date >= cutoff }.map { $0.eventName.lowercased() })
        return min(15, aNames.intersection(bNames).count * 5)
    }

    private func championshipRelevanceScore(now: Date) -> Int {
        let month = Calendar.current.component(.month, from: now)
        if (6...9).contains(month) { return 10 }
        if (1...3).contains(month) { return 7 }
        if (4...5).contains(month) { return 5 }
        return 2
    }

    private func rivalryBand(for score: Int) -> RivalryHeatScore.Band {
        switch score {
        case 85...: return .mustWatch
        case 65...: return .highHeat
        case 40...: return .warm
        default:    return .watch
        }
    }

    // MARK: - Shared Helpers

    private func eventPrestige(for eventName: String) -> Int {
        let lower = eventName.lowercased()
        if lower.contains("olympic") || lower.contains("world championship") { return 30 }
        if lower.contains("diamond league") || lower.contains("world indoor") { return 25 }
        if lower.contains("continental") || lower.contains("national championship") || lower.contains("nationals") { return 18 }
        if lower.contains("invitational") || lower.contains("classic") || lower.contains("memorial") || lower.contains("games") { return 10 }
        return 5
    }

    private func placementPoints(for placement: Int) -> Int {
        switch placement {
        case 1:     return 25
        case 2:     return 18
        case 3:     return 12
        case 4...8: return 6
        default:    return 0
        }
    }

    private func recencyBonus(for date: Date, now: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: date, to: now).day ?? Int.max
        if days <= 7 { return 20 }
        if days <= 30 { return 12 }
        if days <= 90 { return 5 }
        return 0
    }
}

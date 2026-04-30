import Foundation

// MARK: - Ranking Impact

/// How much a specific result is likely to move an athlete's world ranking.
struct RankingImpactScore {
    let score: Int            // 0–100
    let band: Band
    let eventPrestige: Int    // 0–30
    let placementPoints: Int  // 0–25
    let recencyBonus: Int     // 0–20

    enum Band: String {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case major = "Major"
    }
}

// MARK: - Breakout Radar

/// How strongly an athlete is signalling a breakout performance arc.
struct BreakoutScore {
    let score: Int              // 0–100
    let band: Band
    let tier: Tier
    let competitionQuality: Int // 0–30
    let tierDominance: Int      // 0–20
    let improvementVelocity: Int // 0–20
    let repeatability: Int       // 0–15
    let recencyBonus: Int        // 0–15

    enum Band: String {
        case watchlist = "Watchlist"
        case emerging = "Emerging"
        case breakout = "Breakout"
        case breakoutPriority = "Breakout Priority"
    }

    enum Tier: String {
        case highSchool = "High School"
        case ncaa = "NCAA"
        case professional = "Professional"
    }
}

// MARK: - Record Threat

/// How close an athlete is to threatening a major milestone (WR/NR/SB).
struct RecordThreatScore {
    let score: Int               // 0–100
    let band: Band
    let eliteFinishRate: Int     // 0–35
    let peakPerformanceCount: Int // 0–25
    let meetPrestige: Int         // 0–20
    let trendDirection: Int       // 0–20

    enum Band: String {
        case watch = "Watch"
        case strongWatch = "Strong Watch"
        case highPriority = "High Priority"
        case eliteWatch = "Elite Watch"
    }
}

// MARK: - Rivalry Heat

/// How compelling the head-to-head dynamic is between two athletes.
struct RivalryHeatScore {
    let score: Int                  // 0–100
    let band: Band
    let athleteAID: String
    let athleteAName: String
    let athleteBID: String
    let athleteBName: String
    let sharedDiscipline: Int       // 0–30
    let momentumProximity: Int      // 0–25
    let headToHead: Int             // 0–20
    let recentOverlap: Int          // 0–15
    let championshipRelevance: Int  // 0–10

    enum Band: String {
        case watch = "Watch"
        case warm = "Warm"
        case highHeat = "High Heat"
        case mustWatch = "Must Watch"
    }
}

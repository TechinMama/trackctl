import SwiftUI

// MARK: - Shared Score Gauge

struct AnalyticsScoreGauge: View {
    let score: Int
    let accentColor: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(AthenaTheme.graphite, lineWidth: 5)
                .frame(width: 56, height: 56)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 56, height: 56)
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AthenaTheme.bone)
        }
    }
}

// MARK: - Breakout Radar Card

struct BreakoutRadarCard: View {
    let score: BreakoutScore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AthenaSectionHeader("Breakout Radar", detail: "Performance trajectory and emergence signal.")

            HStack(spacing: 16) {
                AnalyticsScoreGauge(score: score.score, accentColor: bandColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(score.band.rawValue)
                        .font(.headline)
                        .foregroundStyle(bandColor)
                    Text(score.tier.rawValue)
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.stone)
                    breakdownRow("Quality", score.competitionQuality, of: 30)
                    breakdownRow("Dominance", score.tierDominance, of: 20)
                    breakdownRow("Velocity", score.improvementVelocity, of: 20)
                }

                Spacer()
            }
        }
        .padding()
        .athenaCard()
    }

    private var bandColor: Color {
        switch score.band {
        case .watchlist:        return AthenaTheme.stone
        case .emerging:         return AthenaTheme.teal
        case .breakout:         return AthenaTheme.panelRaised
        case .breakoutPriority: return AthenaTheme.alert
        }
    }

    private func breakdownRow(_ label: String, _ value: Int, of max: Int) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(AthenaTheme.stone)
                .frame(width: 66, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AthenaTheme.graphite)
                    Capsule()
                        .fill(bandColor.opacity(0.7))
                        .frame(width: max > 0 ? geo.size.width * CGFloat(value) / CGFloat(max) : 0)
                }
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Record Threat Card

struct RecordThreatCard: View {
    let score: RecordThreatScore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AthenaSectionHeader("Record Threat", detail: "Win-rate, form trend, and meet quality signal.")

            HStack(spacing: 16) {
                AnalyticsScoreGauge(score: score.score, accentColor: bandColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(score.band.rawValue)
                        .font(.headline)
                        .foregroundStyle(bandColor)
                    Text("Based on \(score.eliteFinishRate + score.peakPerformanceCount + score.meetPrestige + score.trendDirection) signal points")
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.stone)
                    breakdownRow("Win Rate", score.eliteFinishRate, of: 35)
                    breakdownRow("Top-3 Rate", score.peakPerformanceCount, of: 25)
                    breakdownRow("Trend", score.trendDirection, of: 20)
                }

                Spacer()
            }
        }
        .padding()
        .athenaCard()
    }

    private var bandColor: Color {
        switch score.band {
        case .watch:        return AthenaTheme.stone
        case .strongWatch:  return AthenaTheme.teal
        case .highPriority: return AthenaTheme.panelRaised
        case .eliteWatch:   return AthenaTheme.alert
        }
    }

    private func breakdownRow(_ label: String, _ value: Int, of max: Int) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(AthenaTheme.stone)
                .frame(width: 66, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AthenaTheme.graphite)
                    Capsule()
                        .fill(bandColor.opacity(0.7))
                        .frame(width: max > 0 ? geo.size.width * CGFloat(value) / CGFloat(max) : 0)
                }
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Rivalry Heat Row

struct RivalryHeatRow: View {
    let rivalry: RivalryHeatScore
    let rivalName: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(rivalName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AthenaTheme.bone)
                Text(rivalry.band.rawValue)
                    .font(.caption)
                    .foregroundStyle(bandColor)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: bandIcon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(bandColor)
                Text("\(rivalry.score)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AthenaTheme.bone)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AthenaTheme.graphite)
            )
        }
        .padding(.vertical, 4)
    }

    private var bandColor: Color {
        switch rivalry.band {
        case .watch:    return AthenaTheme.stone
        case .warm:     return AthenaTheme.teal
        case .highHeat: return AthenaTheme.panelRaised
        case .mustWatch: return AthenaTheme.alert
        }
    }

    private var bandIcon: String {
        switch rivalry.band {
        case .watch:    return "eye"
        case .warm:     return "flame"
        case .highHeat: return "flame.fill"
        case .mustWatch: return "bolt.fill"
        }
    }
}

// MARK: - Ranking Impact Badge

struct RankingImpactBadge: View {
    let score: RankingImpactScore

    var body: some View {
        Text(score.band.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(bandColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule(style: .continuous)
                    .fill(bandColor.opacity(0.18))
            )
    }

    private var bandColor: Color {
        switch score.band {
        case .low:      return AthenaTheme.stone
        case .moderate: return AthenaTheme.teal
        case .high:     return AthenaTheme.panelRaised
        case .major:    return AthenaTheme.alert
        }
    }
}

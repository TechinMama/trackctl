import SwiftUI

struct AthleteListView: View {
    @Environment(AthleteViewModel.self) var viewModel
    @State private var selectedAthlete: Athlete?

    var body: some View {
        NavigationStack {
            ZStack {
                AthenaBackdrop()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(AthenaTheme.teal)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(AthenaTheme.alert)
                } else {
                    List {
                        Section {
                            AthenaHeroHeader(
                                title: "Athena Performance Insights",
                                subtitle: "Follow the competitors shaping your watchlist.",
                                eyebrow: "Athletes"
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }

                        if viewModel.searchQuery.isEmpty {
                            Section {
                                if viewModel.followingAthletes.isEmpty {
                                    Text("Follow athletes to see them first in your Following section.")
                                        .foregroundStyle(AthenaTheme.inkMuted)
                                } else {
                                    ForEach(viewModel.followingAthletes) { athlete in
                                        NavigationLink(destination: AthleteDetailView(athlete: athlete)) {
                                            AthleteRowView(athlete: athlete)
                                        }
                                    }
                                }
                            } header: {
                                AthenaSectionHeader("Following", detail: "Athletes you actively track.", onLightBackground: true)
                            }
                            .listRowBackground(Color.clear)
                        }

                        Section {
                            ForEach(viewModel.filteredAthletes) { athlete in
                                NavigationLink(destination: AthleteDetailView(athlete: athlete)) {
                                    AthleteRowView(athlete: athlete)
                                }
                            }
                            if viewModel.hasMoreAthletes {
                                Button {
                                    viewModel.loadNextPage()
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Load more")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(AthenaTheme.teal)
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                }
                                .listRowBackground(Color.clear)
                            }
                        } header: {
                            AthenaSectionHeader(
                                "Athlete Directory",
                                detail: viewModel.searchQuery.isEmpty
                                    ? "Browse all available athlete profiles."
                                    : "Search results",
                                onLightBackground: true
                            )
                        }
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(false)
                    .background(Color.clear)
                    .listStyle(.insetGrouped)
                    .listRowSpacing(10)
                    .environment(\.defaultMinListRowHeight, 68)
                    .searchable(
                        text: Binding(
                            get: { viewModel.searchQuery },
                            set: { newValue in
                                viewModel.updateSearchQuery(newValue)
                            }
                        ),
                        prompt: "Search name, country, or discipline"
                    )
                }
            }
            .task {
                await viewModel.loadAthletes()
            }
        }
    }
}

struct AthleteRowView: View {
    let athlete: Athlete
    @Environment(AthleteViewModel.self) var viewModel
    
    var body: some View {
        HStack(spacing: 12) {
            AthleteAvatarView(athlete: athlete, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(athlete.name)
                    .font(.headline)
                    .foregroundStyle(AthenaTheme.bone)
                HStack {
                    Text(athlete.discipline)
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.stone)
                    Text("•")
                        .foregroundStyle(AthenaTheme.stone)
                    Text(athlete.country)
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.stone)
                }

                let eventLabels = viewModel.athleteEventLabels(for: athlete, limit: 2)
                if !eventLabels.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(eventLabels, id: \.self) { label in
                            Text(label)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AthenaTheme.bone)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(AthenaTheme.tealMuted.opacity(0.8))
                                )
                        }
                    }
                }
            }
            
            Spacer()
            
            if athlete.isFollowing {
                Label("Following", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.teal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AthenaTheme.graphite)
                    )
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AthenaTheme.stone)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .athenaCard()
    }
}

struct AthleteDetailView: View {
    let athlete: Athlete
    @Environment(AthleteViewModel.self) var viewModel
    @Environment(AnalyticsViewModel.self) var analyticsViewModel
    @State private var athleteNotificationsEnabled = true
        @State private var insightText: String?
        @State private var insightCitations: [String] = []
        @State private var insightSource: String = "deterministic"
        @State private var insightLoading = false
    
    var body: some View {
        // Use live athlete state from ViewModel so follow toggle updates immediately
        let liveAthlete = viewModel.athletes.first(where: { $0.id == athlete.id }) ?? athlete
        ZStack {
            AthenaBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AthenaHeroHeader(
                        title: "Athena Performance Insights",
                        subtitle: "\(liveAthlete.name) • \(liveAthlete.discipline) • \(liveAthlete.country)",
                        eyebrow: "Athlete profile",
                        pills: athleteHeaderPills(for: liveAthlete)
                    )

                    HStack(spacing: 12) {
                        AthleteAvatarView(athlete: liveAthlete, size: 84)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(liveAthlete.name)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AthenaTheme.bone)
                            Text(liveAthlete.discipline)
                                .font(.subheadline)
                                .foregroundStyle(AthenaTheme.teal)
                            Text(liveAthlete.country)
                                .font(.subheadline)
                                .foregroundStyle(AthenaTheme.stone)
                        }
                        Spacer()
                    }
                    .padding()
                    .athenaCard()

                    Button(action: {
                        Task {
                            await viewModel.followAthlete(id: liveAthlete.id)
                        }
                        }, label: {
                            Label(
                                liveAthlete.isFollowing ? "Following" : "Follow",
                                systemImage: liveAthlete.isFollowing ? "checkmark.circle.fill" : "plus.circle"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        })
                    .buttonStyle(.borderedProminent)
                    .tint(liveAthlete.isFollowing ? AthenaTheme.tealMuted : AthenaTheme.teal)

                    if liveAthlete.isFollowing {
                        VStack(alignment: .leading, spacing: 10) {
                            AthenaSectionHeader("Athlete Alerts", detail: "Per-athlete notification control.")

                            Toggle(isOn: Binding(
                                get: { athleteNotificationsEnabled },
                                set: { newValue in
                                    athleteNotificationsEnabled = newValue
                                    viewModel.setAthleteNotificationEnabled(id: liveAthlete.id, enabled: newValue)
                                }
                            )) {
                                Text("Notify me about this athlete")
                                    .foregroundStyle(AthenaTheme.bone)
                            }
                            .tint(AthenaTheme.teal)
                        }
                        .padding()
                        .athenaCard()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        AthenaSectionHeader("Momentum Index", detail: "Algorithmic form signal across recent competition windows.")

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.momentumLabel(for: liveAthlete))
                                    .font(.headline)
                                    .foregroundStyle(AthenaTheme.teal)
                                Text(viewModel.momentumSummary(for: liveAthlete))
                                    .font(.caption)
                                    .foregroundStyle(AthenaTheme.stone)
                            }

                            Spacer()

                            Text("\(viewModel.momentumScore(for: liveAthlete))")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AthenaTheme.bone)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AthenaTheme.graphite)
                                )
                        }
                    }
                    .padding()
                    .athenaCard()

                    BreakoutRadarCard(score: analyticsViewModel.breakoutRadar(for: liveAthlete))

                    // AI Performance Insight card – storyboard Scene 4
                    if insightLoading || insightText != nil {
                        InsightCardView(
                            text: insightText ?? "",
                            citations: insightCitations,
                            isLoading: insightLoading,
                            source: insightSource
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal Best")
                            .font(.headline)
                            .foregroundStyle(AthenaTheme.stone)
                        Text(liveAthlete.personalBest)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AthenaTheme.teal)
                    }
                    .padding()
                    .athenaCard()

                    RecordThreatCard(score: analyticsViewModel.recordThreat(for: liveAthlete))

                    let rivals = analyticsViewModel.topRivals(
                        for: liveAthlete,
                        candidates: viewModel.athletes,
                        momentumScore: { viewModel.momentumScore(for: $0) }
                    )
                    if !rivals.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            AthenaSectionHeader("Rivalry Heat", detail: "Top competitive pairings by shared discipline, proximity, and head-to-head history.")
                            ForEach(rivals, id: \.0.id) { (rival, heat) in
                                RivalryHeatRow(rivalry: heat, rivalName: rival.name)
                            }
                        }
                        .padding()
                        .athenaCard()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AthenaSectionHeader("Recent Results", detail: "Performance context and intelligence.")

                        if liveAthlete.recentResults.isEmpty {
                            Text("No recent results available.")
                                .font(.caption)
                                .foregroundStyle(AthenaTheme.stone)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .athenaCard()
                        } else {
                            ForEach(liveAthlete.recentResults) { result in
                                ResultRowView(result: result)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            athleteNotificationsEnabled = viewModel.isAthleteNotificationEnabled(id: athlete.id)
        }
        .task(id: athlete.id) {
            await loadInsight(for: liveAthlete)
        }
    }

    private func loadInsight(for athlete: Athlete) async {
        insightLoading = true
        defer { insightLoading = false }
        do {
            let response = try await APIService.shared.fetchInsight(
                feature: "momentum",
                facts: ["name": athlete.name, "discipline": athlete.discipline, "personalBest": athlete.personalBest],
                analytics: ["momentum": Double(viewModel.momentumScore(for: athlete))],
                context: ["country": athlete.country],
                sources: ["World Athletics", "FloTrack"]
            )
            insightText = response.value.text ?? "Insight unavailable pending source coverage."
            insightCitations = response.metadata.citations
            insightSource = response.value.source
        } catch {
            insightText = nil
        }
    }

    private func athleteHeaderPills(for athlete: Athlete) -> [AthenaHeroHeader.PillItem] {
        let labels = viewModel.athleteEventLabels(for: athlete, limit: 5)
        if labels.isEmpty {
            return [
                .init(label: "Profile", systemImage: "person.text.rectangle")
            ]
        }

        return labels.map { .init(label: $0, systemImage: "figure.run") }
    }
}

struct AthleteAvatarView: View {
    let athlete: Athlete
    var size: CGFloat

    var body: some View {
        placeholder
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(AthenaTheme.teal.opacity(0.55), lineWidth: 1.2))
        .overlay(
            Circle()
                .stroke(AthenaTheme.bone.opacity(0.14), lineWidth: 0.8)
                .padding(2)
        )
        .shadow(color: AthenaTheme.teal.opacity(0.22), radius: 5, x: 0, y: 2)
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [AthenaTheme.panelRaised, AthenaTheme.graphite],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(initials(from: athlete.name))
                .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                .foregroundStyle(AthenaTheme.bone)
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters)
    }
}

struct ResultRowView: View {
    let result: Result
    @Environment(AnalyticsViewModel.self) var analyticsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.eventName)
                        .font(.headline)
                        .foregroundStyle(AthenaTheme.bone)
                    Text(result.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.stone)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(result.placement == 1 ? "🥇 1st" : "#\(result.placement)")
                        .font(.headline)
                        .foregroundStyle(AthenaTheme.bone)
                    if let time = result.time {
                        Text(time)
                            .font(.subheadline)
                            .foregroundStyle(AthenaTheme.teal)
                            .fontWeight(.semibold)
                    }
                    RankingImpactBadge(score: analyticsViewModel.rankingImpact(for: result))
                }
            }

            if let insight = result.aiInsight {
                Rectangle()
                    .fill(AthenaTheme.divider)
                    .frame(height: 1)
                HStack(alignment: .top, spacing: 8) {
                    AthenaMiniMark(size: 14)
                        .padding(.top, 1)
                    Text(insight)
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.bone)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .athenaCard()
    }
}

#Preview {
    AthleteListView()
        .environment(AthleteViewModel())
        .environment(AnalyticsViewModel())
}

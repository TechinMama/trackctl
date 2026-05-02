import SwiftUI

struct HomeView: View {
    @Environment(HomeViewModel.self) var viewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AthenaBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        AthenaHeroHeader(
                            title: "Athena",
                            subtitle: "Intelligent insights for modern athletics.",
                            eyebrow: "Rapid insights"
                        )
                        .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(AthenaTheme.teal)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(AthenaTheme.alert)
                                .padding()
                                .athenaCard()
                                .padding(.horizontal)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    Task {
                                        await viewModel.loadDashboard()
                                    }
                                } label: {
                                    Label("Refresh Feed", systemImage: "arrow.clockwise")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AthenaTheme.teal)

                                Text("Updates headlines and watch priorities based on latest signals.")
                                    .font(.caption)
                                    .foregroundStyle(AthenaTheme.inkMuted)

                                if let lastUpdated = viewModel.lastUpdated {
                                    Text("Last updated: \(lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption2)
                                        .foregroundStyle(AthenaTheme.inkMuted)
                                }

                                if let generatedAt = viewModel.generatedAt {
                                    Text("Generated: \(generatedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption2)
                                        .foregroundStyle(AthenaTheme.inkMuted)
                                }

                                if let warning = viewModel.dataWarning {
                                    Text(warning)
                                        .font(.caption)
                                        .foregroundStyle(AthenaTheme.alert)
                                }
                            }
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 14) {
                                AthenaSectionHeader("Recent Headlines", detail: "Read the signals shaping the season.", onLightBackground: true)
                                    .padding(.horizontal)

                                Text("Why this ranking: \(viewModel.headlineRankingExplanation())")
                                    .font(.caption)
                                    .foregroundStyle(AthenaTheme.inkMuted)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(Array(viewModel.storylines.prefix(3))) { storyline in
                                            StorylineCard(storyline: storyline)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                AthenaSectionHeader("Upcoming Meets", detail: "Upcoming events with watch windows and where they're airing.", onLightBackground: true)
                                    .padding(.horizontal)

                                ForEach(viewModel.upcomingMeets.prefix(3)) { meet in
                                    NavigationLink(destination: MeetDetailView(meet: meet)) {
                                        MeetCardView(meet: meet)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                }
                            }

                            Text(viewModel.sourceCitationText)
                                .font(.caption2)
                                .foregroundStyle(AthenaTheme.inkMuted)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Home Feed")
        }
    }
}

struct StorylineCard: View {
    let storyline: CompetitiveStoryline
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(storyline.title)
                .font(.headline)
                .foregroundStyle(AthenaTheme.bone)
            
            Text(storyline.description)
                .font(.caption)
                .foregroundStyle(AthenaTheme.stone)
            
            Rectangle()
                .fill(AthenaTheme.divider)
                .frame(height: 1)

            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.teal)
                    .padding(.top, 2)
                Text(storyline.aiGeneratedInsight)
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.bone)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Why this matters: context over prediction, grounded in public competition signals.")
                .font(.caption2)
                .foregroundStyle(AthenaTheme.stone)
        }
        .padding()
        .athenaCard()
        .frame(width: 280)
    }
}

struct MeetCardView: View {
    let meet: Meet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meet.name)
                        .font(.headline)
                        .foregroundStyle(AthenaTheme.bone)
                    Text(meet.location)
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.stone)
                }
                Spacer()
                Text(meet.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.teal)
            }
            
            HStack {
                Label("\(meet.events.count) events", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.bone)
                Spacer()
                     if meet.watchURL != nil {
                    Label("Watch", systemImage: "play.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.teal)
                }
            }
        }
        .padding()
        .athenaCard()
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel())
}

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
                                title: "Athletes",
                                subtitle: "Follow the competitors shaping your watchlist.",
                                eyebrow: "Tracking"
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }

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

                        Section {
                            ForEach(viewModel.athletes) { athlete in
                                NavigationLink(destination: AthleteDetailView(athlete: athlete)) {
                                    AthleteRowView(athlete: athlete)
                                }
                            }
                        } header: {
                            AthenaSectionHeader("Athlete Directory", detail: "Browse all available athlete profiles.", onLightBackground: true)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                    .listRowSpacing(10)
                    .environment(\.defaultMinListRowHeight, 68)
                }
            }
            .navigationTitle("Athletes")
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
    @State private var athleteNotificationsEnabled = true
    
    var body: some View {
        // Use live athlete state from ViewModel so follow toggle updates immediately
        let liveAthlete = viewModel.athletes.first(where: { $0.id == athlete.id }) ?? athlete
        ZStack {
            AthenaBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AthenaHeroHeader(
                        title: liveAthlete.name,
                        subtitle: "\(liveAthlete.discipline) • \(liveAthlete.country)",
                        eyebrow: "Athlete profile",
                        pills: [
                            .init(label: "Profile", systemImage: "person.text.rectangle"),
                            .init(label: "Insightful", systemImage: "eye.fill"),
                            .init(label: "Analytical", systemImage: "chart.line.uptrend.xyaxis"),
                            .init(label: "Performant", systemImage: "figure.run"),
                            .init(label: "Fast", systemImage: "bolt.fill")
                        ]
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
                    }) {
                        Label(
                            liveAthlete.isFollowing ? "Following" : "Follow",
                            systemImage: liveAthlete.isFollowing ? "checkmark.circle.fill" : "plus.circle"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    }
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
        .navigationTitle("Athlete Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            athleteNotificationsEnabled = viewModel.isAthleteNotificationEnabled(id: athlete.id)
        }
    }
}

struct AthleteAvatarView: View {
    let athlete: Athlete
    var size: CGFloat

    var body: some View {
        Group {
            if let url = athlete.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
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
                }
            }

            if let insight = result.aiInsight {
                Rectangle()
                    .fill(AthenaTheme.divider)
                    .frame(height: 1)
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.teal)
                        .padding(.top, 2)
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
}

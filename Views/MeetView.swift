import SwiftUI

struct MeetListView: View {
    @Environment(MeetViewModel.self) var viewModel
    @State private var selectedStatus: MeetStatus = .upcoming
    
    var body: some View {
        NavigationStack {
            ZStack {
                AthenaBackdrop()

                VStack(spacing: 16) {
                    AthenaHeroHeader(
                        title: "Events",
                        subtitle: "Upcoming events with location, timing, and where to watch.",
                        eyebrow: "Rapid insights"
                    )
                    .padding(.horizontal)

                    Picker("Status", selection: $selectedStatus) {
                        Text("Upcoming").tag(MeetStatus.upcoming)
                        Text("Ongoing").tag(MeetStatus.ongoing)
                        Text("Completed").tag(MeetStatus.completed)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if let lastUpdated = viewModel.lastUpdated {
                        Text("Last updated: \(lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(AthenaTheme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }

                    if let generatedAt = viewModel.generatedAt {
                        Text("Generated: \(generatedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(AthenaTheme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }

                    if let warning = viewModel.dataWarning {
                        Text(warning)
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.alert)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AthenaTheme.teal)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(AthenaTheme.alert)
                    } else {
                        List(viewModel.getMeetsByStatus(selectedStatus)) { meet in
                            NavigationLink(destination: MeetDetailView(meet: meet)) {
                                MeetListItemView(meet: meet)
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .scrollDisabled(false)
                        .background(Color.clear)
                        .listStyle(.plain)

                        Text(viewModel.sourceCitationText)
                            .font(.caption2)
                            .foregroundStyle(AthenaTheme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
            }
            .navigationTitle("Events")
            .task {
                await viewModel.loadMeets()
            }
        }
    }
}

struct MeetListItemView: View {
    let meet: Meet
    @Environment(MeetViewModel.self) var viewModel
    
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
                VStack(alignment: .trailing, spacing: 4) {
                    Text(meet.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.bone)
                    Text(meet.competitiveLevel)
                        .font(.caption2)
                        .foregroundStyle(AthenaTheme.teal)

                    Text("\(viewModel.watchPriorityLabel(for: meet)) • \(viewModel.watchPriorityScore(for: meet))")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AthenaTheme.bone)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(AthenaTheme.tealMuted.opacity(0.75))
                        )
                }
            }
            
            HStack(spacing: 12) {
                Label("\(meet.events.count)", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.bone)
                
                if let _ = meet.watchURL {
                    Label("Airing", systemImage: "play.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.teal)
                }
            }

            Text("Why this: \(viewModel.watchPriorityExplanation(for: meet))")
                .font(.caption2)
                .foregroundStyle(AthenaTheme.stone)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .athenaCard()
    }
}

struct MeetDetailView: View {
    let meet: Meet
    @Environment(MeetViewModel.self) var viewModel
    
    var body: some View {
        ZStack {
            AthenaBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AthenaHeroHeader(
                        title: meet.name,
                        subtitle: meet.location,
                        eyebrow: meet.competitiveLevel
                    )
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date")
                                .font(.caption)
                                .foregroundStyle(AthenaTheme.stone)
                            Text(meet.date.formatted(date: .long, time: .shortened))
                                .font(.headline)
                                .foregroundStyle(AthenaTheme.bone)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Level")
                                .font(.caption)
                                .foregroundStyle(AthenaTheme.stone)
                            Text(meet.competitiveLevel)
                                .font(.headline)
                                .foregroundStyle(AthenaTheme.teal)
                        }
                    }
                    .padding()
                    .athenaCard()
                    
                    if let watchURL = meet.watchURL {
                        Link(destination: watchURL) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Watch Live")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AthenaTheme.teal)

                        Text("Broadcast information is based on publicly available schedules and may vary by region.")
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.stone)
                            .padding(.top, 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        AthenaSectionHeader("Events (\(meet.events.count))", detail: "Event schedule, watch windows, and result context.", onLightBackground: true)
                        
                        ForEach(meet.events) { event in
                            EventRowView(event: event, meet: meet)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventRowView: View {
    let event: Event
    let meet: Meet
    @State private var reminderOn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.name)
                .font(.headline)
                .foregroundStyle(AthenaTheme.bone)
            Text("Watch window: \(event.scheduledTime.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(AthenaTheme.stone)
            Text("\(event.results.count) results")
                .font(.caption2)
                .foregroundStyle(AthenaTheme.teal)

            Button {
                Task {
                    if reminderOn {
                        NotificationService.shared.cancelEventReminder(eventID: event.id)
                        reminderOn = false
                    } else {
                        let granted = await NotificationService.shared.requestAuthorization()
                        if granted {
                            NotificationService.shared.scheduleEventReminder(event: event, meet: meet)
                            reminderOn = true
                        }
                    }
                }
            } label: {
                Label(
                    reminderOn ? "Reminder Set" : "Remind Me",
                    systemImage: reminderOn ? "checkmark.bell.fill" : "bell.badge"
                )
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(reminderOn ? AthenaTheme.tealMuted : AthenaTheme.graphite)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(AthenaTheme.teal.opacity(0.35), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding()
        .athenaCard()
        .onAppear {
            reminderOn = NotificationService.shared.isEventReminderEnabled(eventID: event.id)
        }
    }
}

#Preview {
    MeetListView()
        .environment(MeetViewModel())
}

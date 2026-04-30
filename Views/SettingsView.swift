import SwiftUI

struct SettingsView: View {
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(AthleteViewModel.self) var athleteViewModel
    @Environment(MeetViewModel.self) var meetViewModel

    @AppStorage("athena.notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("athena.intelligentInsightsEnabled") private var intelligentInsightsEnabled = true
    @AppStorage("athena.autoRefreshEnabled") private var autoRefresh = true
    @AppStorage("athena.notificationFrequency") private var notificationFrequency = "medium"
    @AppStorage("athena.notifySprints") private var notifySprints = true
    @AppStorage("athena.notifyHurdles") private var notifyHurdles = true
    @AppStorage("athena.notifyDistance") private var notifyDistance = true
    @AppStorage("athena.notifyField") private var notifyField = true
    @AppStorage("athena.liveAPIEnabled") private var liveAPIEnabled = true
    @AppStorage("athena.apiBaseURL") private var apiBaseURL = "http://localhost:8080"
    @AppStorage("athena.notificationDeliveryMode") private var notificationDeliveryMode = "local"
    
    var body: some View {
        NavigationStack {
            ZStack {
                AthenaBackdrop()

                Form {
                    Section {
                        AthenaHeroHeader(
                            title: "Settings",
                            subtitle: "Intelligent controls for alerts, insights, and app behavior.",
                            eyebrow: "Rapid insights"
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    Section("Preferences") {
                        Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        Toggle("Intelligent Insights", isOn: $intelligentInsightsEnabled)
                        Toggle("Auto Refresh Data", isOn: $autoRefresh)

                        Text("Intelligent Insights are filtered through Athena guardrails before display.")
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.stone)
                    }

                    Section("Notification Frequency") {
                        Picker("Alert Frequency", selection: $notificationFrequency) {
                            Text("Low").tag("low")
                            Text("Medium").tag("medium")
                            Text("High").tag("high")
                        }
                        .pickerStyle(.segmented)

                        Text("Low = major alerts only, Medium = balanced, High = near real-time event awareness.")
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.stone)
                    }

                    Section("Event Group Alerts") {
                        Toggle("Sprints", isOn: $notifySprints)
                        Toggle("Hurdles", isOn: $notifyHurdles)
                        Toggle("Distance", isOn: $notifyDistance)
                        Toggle("Field", isOn: $notifyField)

                        Text("Use these filters to keep notifications focused on the disciplines you care about.")
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.stone)
                    }

                    Section("Data Source") {
                        Toggle("Use Live API", isOn: $liveAPIEnabled)

                        TextField("Base URL", text: $apiBaseURL)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)

                        Text("If live API is unavailable, Athena automatically falls back to local data.")
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.stone)
                    }

                    Section("Notification Delivery") {
                        Picker("Delivery Mode", selection: $notificationDeliveryMode) {
                            Text("Local Device").tag("local")
                            Text("Backend Queue").tag("backend")
                        }

                        Text("Backend Queue mode prepares notifications for server-side scheduling and cooldown enforcement.")
                            .font(.caption)
                            .foregroundStyle(AthenaTheme.stone)
                    }

                    Section("Reset") {
                        Button("Reset Followed Athletes") {
                            athleteViewModel.resetFollowingPreferences()
                        }

                        Button("Reset Notification Preferences") {
                            NotificationService.shared.resetNotificationPreferences()
                            notificationsEnabled = true
                            notificationFrequency = "medium"
                            notifySprints = true
                            notifyHurdles = true
                            notifyDistance = true
                            notifyField = true
                        }

                        Button(role: .destructive) {
                            athleteViewModel.resetFollowingPreferences()
                            NotificationService.shared.resetNotificationPreferences()
                            notificationsEnabled = true
                            intelligentInsightsEnabled = true
                            autoRefresh = true
                            notificationFrequency = "medium"
                            notifySprints = true
                            notifyHurdles = true
                            notifyDistance = true
                            notifyField = true

                            Task {
                                await homeViewModel.loadDashboard()
                                await athleteViewModel.loadAthletes()
                                await meetViewModel.loadMeets()
                            }
                        } label: {
                            Text("Reset All Demo Preferences")
                        }
                    }
                    
                    Section("About") {
                        HStack {
                            Text("App Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(AthenaTheme.stone)
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("2026.1")
                                .foregroundStyle(AthenaTheme.stone)
                        }
                    }
                    
                    Section("Links") {
                        if let aboutURL = URL(string: "https://athena.example.com") {
                            Link("About Athena", destination: aboutURL)
                        }
                        NavigationLink("Privacy Policy") {
                            PrivacyView()
                        }
                        if let supportURL = URL(string: "mailto:support@athena.example.com") {
                            Link("Contact Support", destination: supportURL)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(false)
                .background(Color.clear)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

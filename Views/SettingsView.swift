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
    @AppStorage("athena.requireLiveData") private var requireLiveData = true
    @AppStorage("athena.notificationDeliveryMode") private var notificationDeliveryMode = "local"

    private var managedAPISettings: Bool {
        if let value = Bundle.main.object(forInfoDictionaryKey: "AthenaManagedAPISettings") as? Bool {
            return value
        }
        if let value = Bundle.main.object(forInfoDictionaryKey: "AthenaManagedAPISettings") as? String {
            return ["1", "true", "yes"].contains(value.lowercased())
        }
        return true
    }

    private var apiSettingsLocked: Bool {
#if DEBUG
        false
#else
        managedAPISettings
#endif
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AthenaBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AthenaHeroHeader(
                            title: "Athena Performance Insights",
                            subtitle: "Intelligent controls for alerts, insights, and app behavior.",
                            eyebrow: "Settings"
                        )
                        .padding(.top, 10)

                        SettingsCard(title: "Preferences", detail: "Core behavior and insight controls.") {
                            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                            Toggle("Intelligent Insights", isOn: $intelligentInsightsEnabled)
                            Toggle("Auto Refresh Data", isOn: $autoRefresh)

                            Text("Intelligent Insights are filtered through Athena guardrails before display.")
                                .font(.caption)
                                .foregroundStyle(AthenaTheme.stone)
                        }

                        SettingsCard(title: "Notification Frequency", detail: "Set how often you want updates.") {
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

                        SettingsCard(title: "Event Group Alerts", detail: "Focus on the disciplines you care about.") {
                            Toggle("Sprints", isOn: $notifySprints)
                            Toggle("Hurdles", isOn: $notifyHurdles)
                            Toggle("Distance", isOn: $notifyDistance)
                            Toggle("Field", isOn: $notifyField)
                        }

                        SettingsCard(title: "Live Data", detail: "Control how app data is fetched.") {
                            Toggle("Use Live API", isOn: $liveAPIEnabled)
                            Toggle("Require Live API", isOn: $requireLiveData)

                            Text("If live API is unavailable, Athena falls back to cached live snapshots only (never bundled local mock data).")
                                .font(.caption)
                                .foregroundStyle(AthenaTheme.stone)

                            if apiSettingsLocked {
                                Text("API settings are managed by this build configuration.")
                                    .font(.caption)
                                    .foregroundStyle(AthenaTheme.stone)
                            } else if managedAPISettings {
                                Text("Managed API settings are enabled for this build, but editable in Debug for local testing.")
                                    .font(.caption)
                                    .foregroundStyle(AthenaTheme.stone)
                            }
                        }
                        .disabled(apiSettingsLocked)

                        SettingsCard(title: "Notification Delivery", detail: "Choose where alerts are processed.") {
                            Picker("Delivery Mode", selection: $notificationDeliveryMode) {
                                Text("Local Device").tag("local")
                                Text("Backend Queue").tag("backend")
                            }
                            .pickerStyle(.segmented)

                            Text("Backend Queue mode prepares notifications for server-side scheduling and cooldown enforcement.")
                                .font(.caption)
                                .foregroundStyle(AthenaTheme.stone)
                        }

                        SettingsCard(title: "Quick Actions", detail: "Reset only what you need.") {
                            Button("Reset Followed Athletes") {
                                athleteViewModel.resetFollowingPreferences()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AthenaTheme.lavender)

                            Button("Reset Notification Preferences") {
                                NotificationService.shared.resetNotificationPreferences()
                                notificationsEnabled = true
                                notificationFrequency = "medium"
                                notifySprints = true
                                notifyHurdles = true
                                notifyDistance = true
                                notifyField = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AthenaTheme.panelRaised)

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
                            .buttonStyle(.borderedProminent)
                            .tint(AthenaTheme.alert)
                        }

                        SettingsCard(title: "About", detail: nil) {
                            HStack {
                                Text("App Version")
                                    .foregroundStyle(AthenaTheme.bone)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundStyle(AthenaTheme.stone)
                            }

                            HStack {
                                Text("Build")
                                    .foregroundStyle(AthenaTheme.bone)
                                Spacer()
                                Text("2026.1")
                                    .foregroundStyle(AthenaTheme.stone)
                            }
                        }

                        SettingsCard(title: "Support", detail: nil) {
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

                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .tint(AthenaTheme.teal)
                }
            }
        }
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    let detail: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AthenaTheme.bone)

            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(AthenaTheme.stone)
            }

            VStack(alignment: .leading, spacing: 10) {
                content
                    .foregroundStyle(AthenaTheme.bone)
            }
            .tint(AthenaTheme.teal)
        }
        .padding(16)
        .athenaCard()
    }
}

#Preview {
    SettingsView()
}

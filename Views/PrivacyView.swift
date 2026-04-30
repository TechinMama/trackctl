import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ZStack {
            AthenaBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AthenaHeroHeader(
                        title: "Privacy",
                        subtitle: "How Athena handles your data.",
                        eyebrow: "Transparency"
                    )

                    Group {
                        PrivacySection(
                            title: "Data We Store Locally",
                            icon: "iphone",
                            items: [
                                "Followed athlete IDs (stored in device UserDefaults)",
                                "Notification preferences and event group filters",
                                "API base URL and live API toggle state",
                                "Cached athlete, meet, and storyline data (device cache folder)",
                                    "App event log — rolling JSON file, 512 KB max, never transmitted"
                            ]
                        )

                        PrivacySection(
                            title: "Data We Do Not Collect",
                            icon: "xmark.shield",
                            items: [
                                "No account, sign-in, or personal profile",
                                "No location data",
                                "No photos, contacts, or biometric data",
                                "No advertising identifiers",
                                    "No analytics SDKs or third-party tracking"
                            ]
                        )

                        PrivacySection(
                            title: "AI Insights",
                            icon: "sparkles",
                            items: [
                                "Insights are generated from public competition results and deterministic analytics",
                                "No personal user data is sent to any AI model",
                                "All insights pass through Athena guardrails before display",
                                    "If source data is incomplete, the insight will say so explicitly"
                            ]
                        )

                        PrivacySection(
                            title: "Notifications",
                            icon: "bell",
                            items: [
                                "Local notifications are scheduled on-device only",
                                "Backend queue mode sends notification metadata to your configured API endpoint",
                                    "No notification content is shared with third parties"
                            ]
                        )

                        PrivacySection(
                            title: "Performance Data Sources",
                            icon: "link",
                            items: [
                                "World Athletics (worldathletics.org)",
                                "FloTrack (flotrack.org)",
                                "Track & Field News (trackandfieldnews.com)",
                                "MileSplit (milesplit.com)",
                                "Athletic.net",
                                    "LA28 Athletics schedule (hospitality.la28.org)"
                            ]
                        )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Contact")
                            .font(.headline)
                            .foregroundStyle(AthenaTheme.bone)
                        Text("Questions about this privacy disclosure?")
                            .font(.subheadline)
                            .foregroundStyle(AthenaTheme.stone)
                            if let contactURL = URL(string: "mailto:support@athena.example.com") {
                                Link("support@athena.example.com", destination: contactURL)
                            }
                            .font(.subheadline)
                            .foregroundStyle(AthenaTheme.teal)
                    }
                    .padding()
                    .athenaCard()

                    Text("Last updated: April 2026")
                        .font(.caption)
                        .foregroundStyle(AthenaTheme.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                }
                .padding()
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrivacySection: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AthenaTheme.teal)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AthenaTheme.bone)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("·")
                            .foregroundStyle(AthenaTheme.teal)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(AthenaTheme.stone)
                    }
                }
            }
        }
        .padding()
        .athenaCard()
    }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}

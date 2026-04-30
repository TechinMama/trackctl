import SwiftUI
import Sentry

private enum RuntimeSettingsBootstrap {
    private static let liveAPIEnabledKey = "athena.liveAPIEnabled"
    private static let requireLiveDataKey = "athena.requireLiveData"
    private static let baseURLKey = "athena.apiBaseURL"

    static func apply() {
        let defaults = UserDefaults.standard
        let managed = infoBool("AthenaManagedAPISettings", defaultValue: {
#if DEBUG
            false
#else
            true
#endif
        }())

        let liveEnabled = infoBool("AthenaLiveAPIEnabled", defaultValue: true)
        let requireLive = infoBool("AthenaRequireLiveData", defaultValue: true)
        let configuredBaseURL = (Bundle.main.object(forInfoDictionaryKey: "AthenaAPIBaseURL") as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if managed {
            defaults.set(liveEnabled, forKey: liveAPIEnabledKey)
            defaults.set(requireLive, forKey: requireLiveDataKey)
            if !configuredBaseURL.isEmpty {
                defaults.set(configuredBaseURL, forKey: baseURLKey)
            }
            return
        }

        if defaults.object(forKey: liveAPIEnabledKey) == nil {
            defaults.set(liveEnabled, forKey: liveAPIEnabledKey)
        }
        if defaults.object(forKey: requireLiveDataKey) == nil {
            defaults.set(requireLive, forKey: requireLiveDataKey)
        }
        if defaults.object(forKey: baseURLKey) == nil && !configuredBaseURL.isEmpty {
            defaults.set(configuredBaseURL, forKey: baseURLKey)
        }
    }

    private static func infoBool(_ key: String, defaultValue: Bool) -> Bool {
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? Bool {
            return value
        }
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String {
            return ["1", "true", "yes"].contains(value.lowercased())
        }
        return defaultValue
    }
}

@main
struct AthenaApp: App {
    init() {
        RuntimeSettingsBootstrap.apply()

        // DSN is baked into Info.plist at build time via the SENTRY_DSN build setting in project.yml.
        // Leave SENTRY_DSN empty in project.yml for local development — SDK will not start.
        let dsn = Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String ?? ""
        guard !dsn.isEmpty else { return }
        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = Bundle.main.object(forInfoDictionaryKey: "AppEnv") as? String ?? "development"
            options.tracesSampleRate = 0.2
            options.enableCrashHandler = true
            options.enableAppHangTracking = true
            options.enableNetworkTracking = false  // not needed; APIService handles its own logging
        }
    }
    @State private var homeViewModel = HomeViewModel()
    @State private var athleteViewModel = AthleteViewModel()
    @State private var meetViewModel = MeetViewModel()
    @State private var analyticsViewModel = AnalyticsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(homeViewModel)
                .environment(athleteViewModel)
                .environment(meetViewModel)
                .environment(analyticsViewModel)
                .tint(AthenaTheme.teal)
                .task {
                    let authorized = await NotificationService.shared.requestAuthorization()
                    if authorized {
                        print("Notifications authorized")
                    }
                }
        }
    }
}

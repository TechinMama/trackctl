import SwiftUI
import Sentry

@main
struct AthenaApp: App {
    init() {
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

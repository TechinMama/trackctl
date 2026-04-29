import SwiftUI

@main
struct AthenaApp: App {
    @State private var homeViewModel = HomeViewModel()
    @State private var athleteViewModel = AthleteViewModel()
    @State private var meetViewModel = MeetViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(homeViewModel)
                .environment(athleteViewModel)
                .environment(meetViewModel)
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

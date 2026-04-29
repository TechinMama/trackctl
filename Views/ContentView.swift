import SwiftUI

struct ContentView: View {
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(AthleteViewModel.self) var athleteViewModel
    @Environment(MeetViewModel.self) var meetViewModel
    
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case athletes
        case meets
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home Feed", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            AthleteListView()
                .tabItem {
                    Label("Athletes", systemImage: "figure.run")
                }
                .tag(Tab.athletes)
            
            MeetListView()
                .tabItem {
                    Label("Events", systemImage: "flag.pattern.checkered")
                }
                .tag(Tab.meets)
            
            SettingsView()
                .tabItem {
                    Label("Control", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.settings)
        }
        .toolbarBackground(AthenaTheme.graphite, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .task {
            await homeViewModel.loadDashboard()
            await athleteViewModel.loadAthletes()
            await meetViewModel.loadMeets()
        }
    }
}

#Preview {
    ContentView()
        .environment(HomeViewModel())
        .environment(AthleteViewModel())
        .environment(MeetViewModel())
}

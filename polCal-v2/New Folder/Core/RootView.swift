import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    @State var selectedTab = 0
    @State private var showSignInView: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
            TabView(selection: $selectedTab) {
                SVKElectionsView(selectedTab: $selectedTab, path:$path)
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Scenarios")
                    }
                    .tag(0)
                
                SVKLegislativeView(selectedTab: $selectedTab, path:$path)
                    .tabItem {
                        Image(systemName: "theatermasks.circle")
                        Text("Voting")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear.circle.fill")
                        Text("Settings")
                    }
                    .tag(3)
            }
        }
    }

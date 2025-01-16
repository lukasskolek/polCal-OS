import SwiftUI
import SwiftData

enum LegislativeViewType {
    case svk
    case czesnem
}

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    @State var selectedTab = 0
    @State private var showSignInView: Bool = false
    @State private var path = NavigationPath()
    @State private var legislativeViewType: LegislativeViewType = .svk // Default value
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SVKElectionsView(selectedTab: $selectedTab, path: $path)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Scenarios")
                }
                .tag(0)
            
            // Conditionally display the view based on the enum value
            Group {
                if legislativeViewType == .svk {
                    SVKLegislativeView(selectedTab: $selectedTab, path: $path, legislativeViewType: $legislativeViewType)
                } else {
                    CZESnemLegislativeView(selectedTab: $selectedTab, path: $path, legislativeViewType: $legislativeViewType)
                }
            }
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

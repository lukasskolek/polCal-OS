import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    @State var selectedTab = 0
    @State private var showSignInView: Bool = false
    @State private var path = NavigationPath()
    
    let firstAnnouncements = [
        NewsAnnouncement(
            title: "New Feature Released",
            date: Date(),
            content: "We're excited to announce the release of our new feature that will revolutionize your experience...",
            image: Image(systemName: "sparkles")
        )
        ]

    var body: some View {
            TabView(selection: $selectedTab) {
                ElectionsView(selectedTab: $selectedTab, path:$path)
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Scenarios")
                    }
                    .tag(0)
                
                PassingABillView()
                    .tabItem {
                        Image(systemName: "theatermasks.circle")
                        Text("Voting")
                    }
                    .tag(1)
                
                FeedView(announcements: firstAnnouncements)
                    .tabItem {
                        Image(systemName: "newspaper.circle.fill")
                        Text("News")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear.circle.fill")
                        Text("Settings")
                    }
                    .tag(3)
                
                AccountView(showSignInView: $showSignInView)
                    .tabItem {
                        Image(systemName: "person.circle.fill")
                        Text("Account")
                    }
                    .tag(4)
            }
            .onAppear {
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignInView = authUser == nil
            }
            .fullScreenCover(isPresented: $showSignInView) {
                NavigationStack {
                    AuthenticationView(showSignInView: $showSignInView)
                }
            }
        }
        
        
    }

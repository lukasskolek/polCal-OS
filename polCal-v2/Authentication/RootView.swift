import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    @State var selectedTab = 0
    @State private var showSignInView: Bool = false
    @State private var path = NavigationPath()
    
    let firstAnnouncement = [
        NewsAnnouncement(
            title: "What's next?",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 31))!,
            content: "I hope in the future news feed updates will include opinion polls just after they have been released, functionality for additional countries, different types of elections and a lot more. It will take some time and a lot of it depends on this initial feedback, so 🤞.",
            image: nil
        ),
        NewsAnnouncement(
            title: "Beta released!",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 31))!,
            content: "I'm excited to announce the release of this beta version! Please, play around with it and share it with people who might be interested. Thank you for being a part of this! It's my first time, so I am excited about this I am sure I will learn a lot from it. I am happy to talk and I look forward to your feedback and insights.",
            image: nil
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
                
                LegislativeView(selectedTab: $selectedTab, path:$path)
                    .tabItem {
                        Image(systemName: "theatermasks.circle")
                        Text("Voting")
                    }
                    .tag(1)
                
                FeedView(announcements: firstAnnouncement)
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

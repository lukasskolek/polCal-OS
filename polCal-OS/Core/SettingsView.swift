//
//  AccountView.swift
//  polCal
//
//  Created by Lukas on 28/08/2024.
//

import SwiftUI

struct SettingsView: View {
    
    enum Language: String, CaseIterable, Identifiable {
        case english
        var id: Self { self }
    }
    
    @State private var showingPPSheet = false //privacy policy
    @State private var showingTCsSheet = false //terms and conditions
    @State private var showingAboutAppSheet = false //about app
    @State private var showingAboutMeSheet = false //about developer
    @State private var selectedLanguage: Language = .english
    
    var body: some View {
        List{
            Section ("Preferred language") {
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(Language.allCases) { language in
                        Text(language.rawValue.capitalized)
                    }
                }
            }
            Section ("Details"){
                Button("About developer") {showingAboutMeSheet.toggle()}
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $showingAboutMeSheet) {
                        AboutMeSheetView()
                            }
                Button("Privacy policy") {showingPPSheet.toggle()}
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $showingPPSheet) {
                        PPSheetView()
                            }
                Button("Terms and conditions") {showingTCsSheet.toggle()}
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $showingTCsSheet) {
                        TCsSheetView()
                            }
                
            }
            Section ("Version and build"){
                Button("About app") {showingAboutAppSheet.toggle()}
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $showingAboutAppSheet) {
                        AboutAppSheetView()
                    }
            }
        }
    }
}

import SwiftUI

struct AboutAppSheetView: View {
    @Environment(\.dismiss) var dismiss

    var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "APP_VERSION") as? String ?? "Unknown"
    }

    var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "BUILD_NUMBER") as? String ?? "Unknown"
    }

    var body: some View {
        VStack {
            ZStack{
                HStack {
                     // Pushes the button to the far right

                    Button(action: {
                        // Dismiss the current view
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 24)) // Adjust size for smaller button
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                }

                Text("About PolCal")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            HStack {
                Text("\n\nApp Version: \(appVersion)\nBuild Number: \(buildNumber)\n")
                Spacer()
            }
            .padding(.bottom, 10)

            Text("""
                This app helps visualize election outcomes by providing a clear and interactive way of exploring election data. You can create your own scenarios or play around with the past elections.

                In the future, data from the latest opinion polls could be available to view in the app right after being publicly published.

                There is also a potential for further developing:
                - same functionality for more countries,
                - regional and municipal elections,
                - simulation of legislative process.
                """)
            Spacer()
        }
        .padding()
    }
}

struct TCsSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            ZStack{
                HStack {
                     // Pushes the button to the far right

                    Button(action: {
                        // Dismiss the current view
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 24)) // Adjust size for smaller button
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                }

                Text("Terms and conditions")
                    .font(.headline)
                    .fontWeight(.semibold)
            }


            Text("\n\nStill working on this.")
                .font(.body)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

struct PPSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            ZStack{
                HStack {
                     // Pushes the button to the far right

                    Button(action: {
                        // Dismiss the current view
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 24)) // Adjust size for smaller button
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                }

                Text("Privacy policy")
                    .font(.headline)
                    .fontWeight(.semibold)
            }


            Text("\n\nStill working on this.")
                .font(.body)
                .padding(.horizontal)

            Spacer()
        }
    .padding()
    }
}

struct AboutMeSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme  // Detects light or dark mode

    var body: some View {
        VStack {
            ZStack{
                HStack {
                     // Pushes the button to the far right

                    Button(action: {
                        // Dismiss the current view
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 24)) // Adjust size for smaller button
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                }

                Text("About developer")
                    .font(.headline)
                    .fontWeight(.semibold)
            }


            Text("\n\nHi, my name is Lukas Skolek and I'm from Bratislava, Slovakia 🇸🇰.\n\nI wrote this app in Swift, which is now my favourite programming language. I am still a beginner despite the fact that I've been trying to code on and off for a few years now. I never got any formal education in programming and 9 - 5 I'm usually at my work as a project manager in infrastructure. Before Swift, I tried some Python and R, which were interesting, because I wanted to do data science. However, it was hard for me to develop some fun bigger pastime project using those languages. \n\nIf you want to reach out, find me at:")
                .font(.body)
                .padding(.horizontal)
            HStack{
                Image(colorScheme == .dark ? "Xwhite" : "Xblack")  // Conditional image for dark/light mode
                    .resizable()
                    .frame(width: 16, height: 16)
                Text("[@luky_sklk](https://x.com/luky_sklk)")
                Spacer()
            }
            .padding(.horizontal)
            HStack{
                Image("Gmail")
                    .resizable()
                    .frame(width: 20, height: 16)
                Text("luky.skolek@gmail.com")
                Spacer()
            }
            .padding(.horizontal)

            Spacer()
        }
    .padding()
    }
}

#Preview {
    SettingsView()
}

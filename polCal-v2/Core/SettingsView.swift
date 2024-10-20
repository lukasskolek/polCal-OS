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

    @State private var showingAboutAppSheet = false
    @State private var showingAboutMeSheet = false
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
                Button("About app") {showingAboutAppSheet.toggle()}
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $showingAboutAppSheet) {
                        AboutAppSheetView()
                            }
                Button("About developer") {showingAboutMeSheet.toggle()}
                    .buttonStyle(.automatic)
                    .sheet(isPresented: $showingAboutMeSheet) {
                        AboutMeSheetView()
                            }
            }
        }
    }
}

struct AboutAppSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button(action: {
                    // Dismiss the current view
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                }
    }
}

import SwiftUI

struct AboutMeSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Dismiss the current view
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .foregroundStyle(.gray)
                }

                Spacer()

                Text("About developer")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center) // Center text within the available space
                Spacer(minLength: 40)

            }
            .padding()


            Text("Hi, my name is Lukas Skolek and I'm from Bratislava, Slovakia 🇸🇰.\n\nI wrote this app in Swift, which is now my favourite programming language. I am still a beginner despite the fact that I've been trying to code on and off for a few years now. I never got any formal education in programming and 9 - 5 I'm usually at my work as a project manager in infrastructure. Before Swift, I tried some Python and R, which were interesting, because I wanted to do data science. However, it was hard for me to develop some fun bigger pastime project using those languages. \n\nIf you want to reach out, find me at:")
                .font(.body)
                .padding(.horizontal)
            HStack{
                Image("Xblack")
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
    }
}

#Preview {
    SettingsView()
}

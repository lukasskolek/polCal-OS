//
//  polCal_OSApp.swift
//  polCal-OS
//
//  Created by Lukas on 06/10/2024.
//
import SwiftUI
import SwiftData

@main
struct polCal_OSApp: App {
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [ScenarioModel.self, SVKVoteModel.self])
    }
}


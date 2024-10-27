//
//  polCal_v2App.swift
//  polCal-v2
//
//  Created by Lukas on 06/10/2024.
//
import SwiftUI
import FirebaseAuth
import Firebase
import SwiftData

@main
struct polCal_v2App: App {
    // register app delegate for Firebase setup
       @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
       
       var body: some Scene {
           WindowGroup {
                  RootView()
           }
           .modelContainer(for: [ScenarioModel.self, Vote.self])
       }
   }

   class AppDelegate: NSObject, UIApplicationDelegate {
       func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
           FirebaseApp.configure()
           
           return true
       }
   }

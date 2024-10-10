import Foundation
import SwiftUI
import SwiftData

func loadScenarios() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby", withExtension: "json") else {
        print("Could not find mockVolby.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

import Foundation
import SwiftUI
import SwiftData

func loadUserScenarios() -> [Scenario]? {
    let fileManager = FileManager.default

    // Get the URL for the Documents directory
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Could not access the documents directory.")
        return nil
    }

    // Create the URL for savedVolby.json in the Documents directory
    let savedVolbyURL = documentsURL.appendingPathComponent("savedVolby.json")

    // Check if savedVolby.json exists
    if !fileManager.fileExists(atPath: savedVolbyURL.path) {
        print("savedVolby.json does not exist in the documents directory.")
        return nil
    }

    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: savedVolbyURL)

        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)

        return decodedScenarios
    } catch {
        print("Failed to load and parse savedVolby.json: \(error)")
        return nil
    }
}

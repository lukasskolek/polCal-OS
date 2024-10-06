import Foundation
import SwiftUI
import SwiftData

func loadScenarios() -> [ScenarioModel]? {
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
        
        // Convert Scenario structs to ScenarioModel instances
        let scenarioModels = decodedScenarios.map { scenario in
            // Map the parties from JSON to Party instances
            let parties = scenario.parties?.map { (party: Party) in
                Party(
                    name: party.name,
                    votes: party.votes,
                    coalitionStatus: party.coalitionStatus,
                    mandaty: party.mandaty,
                    zostatok: party.zostatok,
                    inGovernment: party.inGovernment,
                    red: party.red,
                    blue: party.blue,
                    green: party.green,
                    opacity: party.opacity
                )
            }
            
            // Initialize a ScenarioModel instance with required properties
            let scenarioModel = ScenarioModel(
                id: scenario.id,
                turnoutTotal: scenario.turnoutTotal,
                turnoutIncorrect: scenario.turnoutIncorrect,
                turnoutDistributed: scenario.turnoutDistributed,
                turnoutLeftToBeDistributed: scenario.turnoutLeftToBeDistributed,
                
                populus: scenario.populus,
                
                republikoveCislo: scenario.republikoveCislo,
                
                populusGotIn: scenario.populusGotIn,
                populusInvalidNotTurnedIn: scenario.populusInvalidNotTurnedIn,
                populusAttended: scenario.populusAttended,
                
                parties: parties // Assign mapped Party instances here
            )
            
            // Optionally, calculate mandates if needed
            scenarioModel.calculateMandates()
            
            return scenarioModel
        }
        
        return scenarioModels
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

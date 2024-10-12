import Foundation
import SwiftUI
import SwiftData

func saveScenario(_ scenarioModel: ScenarioModel) throws {
    let fileManager = FileManager.default

    // Check if the scenario's id starts with "New custom scenario"
    if scenarioModel.id.starts(with: "New custom scenario") {
        // Raise an error and do not save the scenario
        throw NSError(domain: "SaveScenarioErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot save a scenario with the default name. Please rename the scenario before saving."])
    }

    // Get the URL for the Documents directory
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Could not access the documents directory.")
        return
    }

    // Create the URL for savedVolby.json in the Documents directory
    let savedVolbyURL = documentsURL.appendingPathComponent("savedVolby.json")

    var scenarios = [Scenario]()

    // Check if savedVolby.json exists
    if fileManager.fileExists(atPath: savedVolbyURL.path) {
        do {
            // Read existing data
            let data = try Data(contentsOf: savedVolbyURL)
            // Decode existing scenarios
            scenarios = try JSONDecoder().decode([Scenario].self, from: data)
        } catch {
            print("Failed to load and parse savedVolby.json: \(error)")
            // If we can't read existing data, start with an empty array
            scenarios = []
        }
    } else {
        // If the file doesn't exist, start with an empty array
        scenarios = []
    }

    // Convert the ScenarioModel to Scenario
    let newScenario = scenarioModelToScenario(scenarioModel)

    if let index = scenarios.firstIndex(where: { $0.id == newScenario.id }) {
        // Scenario with the same id exists
        do {
            let existingScenario = scenarios[index]

            // Compare the existing scenario with the new one
            if existingScenario != newScenario {
                // Scenarios are not equal, replace it
                scenarios[index] = newScenario

                // Encode the updated array
                let data = try JSONEncoder().encode(scenarios)

                // Write data to savedVolby.json
                try data.write(to: savedVolbyURL)
                print("Scenario with id \(newScenario.id) updated in savedVolby.json.")
            } else {
                // Scenarios are equal, do nothing
                print("Scenario with id \(newScenario.id) already exists and is identical.")
            }
        } catch {
            print("Failed to compare or save scenarios: \(error)")
        }
    } else {
        // Scenario does not exist, append it
        scenarios.append(newScenario)

        do {
            // Encode the updated array
            let data = try JSONEncoder().encode(scenarios)

            // Write data to savedVolby.json
            try data.write(to: savedVolbyURL)
            print("Scenario with id \(newScenario.id) added to savedVolby.json.")
        } catch {
            print("Failed to save scenarios to savedVolby.json: \(error)")
        }
    }
}

// Helper function to convert ScenarioModel to Scenario
func scenarioModelToScenario(_ model: ScenarioModel) -> Scenario {
    // Map the parties from ScenarioModel to Party structs
    let parties = model.parties?.map { party in
        Party(
            name: party.name,
            votes: party.votes,
            coalitionStatus: party.coalitionStatus,
            mandaty: party.mandaty,
            zostatok: party.zostatok,
            inGovernment: party.inGovernment,
            red: party.red,
            green: party.green,
            blue: party.blue,
            opacity: party.opacity
        )
    }

    let scenario = Scenario(
        id: model.id,
        turnoutTotal: model.turnoutTotal,
        turnoutIncorrect: model.turnoutIncorrect,
        populus: model.populus,
        parties: parties
    )

    return scenario
}

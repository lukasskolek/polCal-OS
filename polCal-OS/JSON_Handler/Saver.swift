import Foundation
import SwiftUI
import SwiftData

func saveScenario(_ scenarioModel: ScenarioModel) throws {
    let fileManager = FileManager.default
    
    let defaultScenarioIDs: Set<String> = [
        "Slovak Parliamentary Election 2023",
        "Slovak Parliamentary Election 2020",
        "Slovak Parliamentary Election 2016",
        "Slovak Parliamentary Election 2012",
        "Slovak Parliamentary Election 2010",
        "Slovak Parliamentary Election 2006",
        "Slovak Parliamentary Election 2002",
        "Slovak Parliamentary Election 1998"
    ]

    // Check if the scenario's id starts with "New custom scenario"
    if scenarioModel.id.starts(with: "New custom scenario") || defaultScenarioIDs.contains(scenarioModel.id) {
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

func saveVote(_ voteModel: SVKVoteModel) throws {
    let fileManager = FileManager.default
    
    // Check if the scenario's id starts with "New custom scenario"
    if voteModel.id.starts(with: "New custom vote") {
        // Raise an error and do not save the scenario
        throw NSError(domain: "SaveVoteErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot save a vote with the default name. Please rename the vote before saving."])
    }

    // Get the URL for the Documents directory
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Could not access the documents directory.")
        return
    }

    // Create the URL for savedVolby.json in the Documents directory
    let savedVotesURL = documentsURL.appendingPathComponent("savedVotes.json")

    var votes = [SVKVote]()

    // Check if savedVolby.json exists
    if fileManager.fileExists(atPath: savedVotesURL.path) {
        do {
            // Read existing data
            let data = try Data(contentsOf: savedVotesURL)
            // Decode existing scenarios
            votes = try JSONDecoder().decode([SVKVote].self, from: data)
        } catch {
            print("Failed to load and parse savedVotes.json: \(error)")
            // If we can't read existing data, start with an empty array
            votes = []
        }
    } else {
        // If the file doesn't exist, start with an empty array
        votes = []
    }

    // Convert the ScenarioModel to Scenario
    let newVote = voteModelToVote(voteModel)

    if let index = votes.firstIndex(where: { $0.id == newVote.id }) {
        // Scenario with the same id exists
        do {
            let existingVote = votes[index]

            // Compare the existing scenario with the new one
            if existingVote != newVote {
                // Scenarios are not equal, replace it
                votes[index] = newVote

                // Encode the updated array
                let data = try JSONEncoder().encode(votes)

                // Write data to savedVolby.json
                try data.write(to: savedVotesURL)
                print("Vote with id \(newVote.id) updated in savedVotes.json.")
            } else {
                // Scenarios are equal, do nothing
                print("Vote with id \(newVote.id) already exists and is identical.")
            }
        } catch {
            print("Failed to compare or save votes: \(error)")
        }
    } else {
        // Scenario does not exist, append it
        votes.append(newVote)

        do {
            // Encode the updated array
            let data = try JSONEncoder().encode(votes)

            // Write data to savedVolby.json
            try data.write(to: savedVotesURL)
            print("Vote with id \(newVote.id) added to savedVotes.json.")
        } catch {
            print("Failed to save votes to savedVotes.json: \(error)")
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


func legPartyModelToLegParty(_ model: SVKlegPartyModel) -> SVKlegParty {
    return SVKlegParty(id: model.id, name: model.name)
}

func mpModelToMP(_ mpModel: SVKMPModel) -> SVKMP {
    let legParty = mpModel.legParty != nil ? legPartyModelToLegParty(mpModel.legParty!) : nil
    return SVKMP(name: mpModel.name, legParty: legParty, vote: mpModel.vote)
}

// Helper function to convert VoteModel to Vote
func voteModelToVote(_ model: SVKVoteModel) -> SVKVote {
    // Map the MPs from VoteModel to MP structs
    let mps = model.mps.map { mpModelToMP($0) }

    let vote = SVKVote(
        id: model.id,
        mps: mps,
        typevote: model.typevote
    )

    return vote
}

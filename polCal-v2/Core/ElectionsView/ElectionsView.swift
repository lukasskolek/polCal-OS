import SwiftUI
import SwiftData

struct ElectionsView: View {
    @Environment(\.modelContext) var modelContext
    @State private var sortOrder: [SortDescriptor<ScenarioModel>] = [SortDescriptor(\ScenarioModel.id)]
    @Binding var selectedTab: Int
    @Binding var path: NavigationPath
    
    @State private var userScenarios: [Scenario] = []

    var body: some View {
        NavigationStack {
            ScenarioModelView(sortOrder: sortOrder)
                .onAppear {
                    loadUserScenariosList()
                }
                .navigationTitle("Browse scenarios")
                .toolbar {
                    if selectedTab == 0 {
                        Menu {
                            Picker("Sort by", selection: $sortOrder) {
                                Text("Turnout Total (Low to High)")
                                    .tag([SortDescriptor(\ScenarioModel.turnoutTotal)])
                                Text("Turnout Total (High to Low)")
                                    .tag([SortDescriptor(\ScenarioModel.turnoutTotal, order: .reverse)])
                                Text("ID (A to Z)")
                                    .tag([SortDescriptor(\ScenarioModel.id)])
                                Text("ID (Z to A)")
                                    .tag([SortDescriptor(\ScenarioModel.id, order: .reverse)])
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }

                        Menu {
                            Menu {
                                Button("FOCUS SEP/24", action: {})
                            } label: {
                                Label("Polls", systemImage: "checklist")
                            }
                            Menu {
                                Button("2023", action: { loadScenarioModels() })
                            } label: {
                                Label("Elections", systemImage: "envelope")
                            }
                            Menu {
                                ForEach(userScenarios, id: \.id) { scenario in
                                    Button(scenario.id) {
                                        loadUserScenarioModel(scenario)
                                    }
                                }
                            } label: {
                                Label("Saved Scenarios", systemImage: "archivebox")
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }

                        Button(action: addScenario) {
                            Label("Add Scenario", systemImage: "plus")
                        }

                        // Button to delete all scenarios
                        Button(role: .destructive, action: deleteAllScenarios) {
                            Label("Delete All", systemImage: "trash")
                                .foregroundColor(.red)
                                .accentColor(.red)
                        }
                        .buttonStyle(RedButtonStyle())
                    }
                }
                .navigationDestination(for: ScenarioModel.self) { scenarioModel in
                    ScenarioReportView(path: $path, scenarioModel: scenarioModel)
                }
        }
    }

    func loadScenarioModels() {
        do {
            let existingScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())
            let existingIDs = Set(existingScenarios.map { $0.id })

            if let scenarios = loadScenarios() {
                for scenario in scenarios {
                    if !existingIDs.contains(scenario.id) {
                        // Convert Scenario to ScenarioModel
                        let scenarioModel = scenarioToScenarioModel(scenario)
                        modelContext.insert(scenarioModel)
                    }
                }
            }
        } catch {
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }

    func loadUserScenariosList() {
        if let scenarios = loadUserScenarios() {
            userScenarios = scenarios
        } else {
            userScenarios = []
        }
    }

    // Function to load user scenarios
    func loadUserScenarioModel(_ scenario: Scenario) {
        do {
            // Check if scenario with the same id already exists in the model context
            let existingScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())
            if existingScenarios.contains(where: { $0.id == scenario.id }) {
                // Scenario is already in model context
                print("Scenario with id \(scenario.id) already exists in model context.")
                return
            } else {
                // Convert Scenario to ScenarioModel
                let scenarioModel = scenarioToScenarioModel(scenario)
                // Insert into modelContext
                modelContext.insert(scenarioModel)
                print("Inserted scenario with id \(scenario.id) into model context.")
            }
        } catch {
            print("Error loading user scenario: \(error)")
        }
    }

    // Helper function to convert Scenario to ScenarioModel
    func scenarioToScenarioModel(_ scenario: Scenario) -> ScenarioModel {
        // Map the parties from Scenario to PartyModel instances
        let parties = scenario.parties?.map { party in
            PartyModel(
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
        
        let scenarioModel = ScenarioModel(
            id: scenario.id,
            turnoutTotal: scenario.turnoutTotal,
            turnoutIncorrect: scenario.turnoutIncorrect,
            populus: scenario.populus,
            parties: parties
        )
        
        // Optionally, calculate mandates if needed
        scenarioModel.calculateMandates()
        
        return scenarioModel
    }

    func addScenario() {
        do {
            // Fetch all existing scenarios
            let existingScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())

            // Find the highest number used in "New custom scenario X"
            let newIDNumber = (existingScenarios.compactMap { scenario -> Int? in
                // Check if the scenario ID starts with "New custom scenario "
                if scenario.id.starts(with: "New custom scenario ") {
                    // Try to extract the number after "New custom scenario "
                    let suffix = scenario.id.dropFirst("New custom scenario ".count)
                    return Int(suffix)
                }
                return nil
            }.max() ?? 0) + 1

            // Generate the new scenario ID
            let newID = "New custom scenario \(newIDNumber)"

            // Create the new scenario with default values and the generated ID
            let scenario = ScenarioModel(
                id: newID,
                turnoutTotal: 0.0,
                turnoutIncorrect: 0.0,
                populus: 4388872,
                parties: [
                    PartyModel(
                        name: "Party A",
                        votes: 0.0,
                        coalitionStatus: .alone,
                        mandaty: 0,
                        zostatok: 0,
                        inGovernment: false,
                        red: 0.567,
                        blue: 0.024,
                        green: 0.592,
                        opacity: 1.0
                    ),
                    PartyModel(
                        name: "Party B",
                        votes: 0.0,
                        coalitionStatus: .alone,
                        mandaty: 0,
                        zostatok: 0,
                        inGovernment: false,
                        red: 0.0,
                        blue: 1.0,
                        green: 0.737,
                        opacity: 1.0
                    )
                ]
            )

            // Insert the new scenario into the model context
            modelContext.insert(scenario)

        } catch {
            // Print error if fetching existing scenarios fails
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }

    func deleteAllScenarios() {
        do {
            let allScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())
            for scenario in allScenarios {
                modelContext.delete(scenario)
            }
        } catch {
            print("Failed to delete all scenarios: \(error.localizedDescription)")
        }
    }
}

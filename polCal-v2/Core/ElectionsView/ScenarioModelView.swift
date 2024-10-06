import SwiftData
import SwiftUI

struct ScenarioModelView: View {
    @Environment(\.modelContext) var modelContext
    @Query var scenarios: [ScenarioModel]

    // State variable to hold the IDs of saved scenarios
    @State private var savedScenarioIDs: Set<String> = []

    var body: some View {
        List {
            ForEach(scenarios) { scenario in
                NavigationLink(value: scenario) {
                    HStack {
                        Text("\(scenario.id)")
                        if savedScenarioIDs.contains(scenario.id) {
                            Image(systemName: "opticaldisc")
                        }
                    }
                }
            }
            .onDelete(perform: deleteScenario)
        }
        .overlay {
            if scenarios.isEmpty {
                ContentUnavailableView(label: {
                    Label("No scenarios", systemImage: "list.bullet.rectangle.portrait")
                }, description: {
                    Text("Start by creating a new one \(Image(systemName: "plus")), or load some from the archive \(Image(systemName: "archivebox")) above.")
                }, actions: {
                    Button("Create a new scenario") { addScenario() }
                        .buttonStyle(NeatButtonStyle())
                })
            }
        }
        .onAppear(perform: loadSavedScenarioIDs)
    }

    init(searchString: String = "", sortOrder: [SortDescriptor<ScenarioModel>] = []) {
        _scenarios = Query(filter: #Predicate { scenario in
            if searchString.isEmpty {
                return true
            } else {
                return scenario.id.localizedStandardContains(searchString)
            }
        }, sort: sortOrder)
    }

    func deleteScenario(at offsets: IndexSet) {
        for offset in offsets {
            let scenario = scenarios[offset]
            modelContext.delete(scenario)
        }
    }

    func loadScenarioModels() {
        do {
            let existingScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())
            let existingIDs = Set(existingScenarios.map { $0.id })

            if let scenarios = loadScenarios() {
                for scenario in scenarios {
                    if !existingIDs.contains(scenario.id) {
                        modelContext.insert(scenario)
                    }
                }
            }
        } catch {
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
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
                turnoutDistributed: 0.0,
                turnoutLeftToBeDistributed: 0.0,
                populus: 4388872,
                republikoveCislo: 0,
                populusGotIn: 0,
                populusInvalidNotTurnedIn: 0,
                populusAttended: 0,
                parties: [
                    Party(name: "Party 1", votes: 0.0, coalitionStatus: .alone, mandaty: 0, zostatok: 0, inGovernment: false, red: 0.567, blue: 0.024, green: 0.592, opacity: 1.0),
                    Party(name: "Party 2", votes: 0.0, coalitionStatus: .alone, mandaty: 0, zostatok: 0, inGovernment: false, red: 0.0, blue: 1.0, green: 0.737, opacity: 1.0)
                ]
            )

            // Insert the new scenario into the model context
            modelContext.insert(scenario)

        } catch {
            // Print error if fetching existing scenarios fails
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }

    // Function to load saved scenario IDs from savedVolby.json
    func loadSavedScenarioIDs() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return
        }
        let savedVolbyURL = documentsURL.appendingPathComponent("savedVolby.json")
        if !fileManager.fileExists(atPath: savedVolbyURL.path) {
            // savedVolby.json does not exist
            savedScenarioIDs = []
            return
        }
        do {
            let data = try Data(contentsOf: savedVolbyURL)
            let scenarios = try JSONDecoder().decode([Scenario].self, from: data)
            let ids = scenarios.map { $0.id }
            savedScenarioIDs = Set(ids)
        } catch {
            print("Failed to read savedVolby.json: \(error)")
            savedScenarioIDs = []
        }
    }
}

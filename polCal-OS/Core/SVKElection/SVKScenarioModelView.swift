import SwiftData
import SwiftUI

struct SVKScenarioModelView: View {
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
    
    func loadScenarioModels(for year: Int) {
        do {
            let existingScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())
            let existingIDs = Set(existingScenarios.map { $0.id })
            
            var scenarios: [Scenario]? = nil
            
            switch year {
            case 1998:
                scenarios = loadScenarios1998()
            case 2002:
                scenarios = loadScenarios2002()
            case 2006:
                scenarios = loadScenarios2006()
            case 2010:
                scenarios = loadScenarios2010()
            case 2012:
                scenarios = loadScenarios2012()
            case 2016:
                scenarios = loadScenarios2016()
            case 2020:
                scenarios = loadScenarios2020()
            case 2023:
                scenarios = loadScenarios2023()
            default:
                scenarios = nil
                print("No scenarios available for the year \(year).")
            }
            
            if let scenarios = scenarios {
                for scenario in scenarios {
                    if !existingIDs.contains(scenario.id) {
                        // Convert Scenario to ScenarioModel
                        let scenarioModel = scenarioToScenarioModel(scenario)
                        modelContext.insert(scenarioModel)
                    } else {
                        print("Scenario with id \(scenario.id) already exists in the model context.")
                    }
                }
            }
        } catch {
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }
    
    func addScenario() {
        do {
            let existingScenarios = try modelContext.fetch(ScenarioModel.fetchRequest())
            
            // Find the highest number used in "New custom scenario X"
            let newIDNumber = (existingScenarios.compactMap { scenario -> Int? in
                if scenario.id.starts(with: "New custom scenario ") {
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
                turnoutTotal: 70.0,
                turnoutIncorrect: 1.0,
                populus: 4_388_872,
                parties: [
                    PartyModel(
                        name: "Party 1",
                        votes: 0.0,
                        coalitionStatus: .alone,
                        mandaty: 0,
                        zostatok: 0,
                        inGovernment: false,
                        red: 0.373,
                        blue: 0.847,
                        green: 0.784,
                        opacity: 1.0
                    ),
                    PartyModel(
                        name: "Party 2",
                        votes: 0.0,
                        coalitionStatus: .alone,
                        mandaty: 0,
                        zostatok: 0,
                        inGovernment: false,
                        red: 0.922,
                        blue: 0.282,
                        green: 0.329,
                        opacity: 1.0
                    )
                ]
            )
            
            // Insert the new scenario into the model context
            modelContext.insert(scenario)
            
        } catch {
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }
    // Function to load saved scenario IDs from savedVolby.json
    // Helper function to convert Scenario to ScenarioModel
    func scenarioToScenarioModel(_ scenario: Scenario) -> ScenarioModel {
        // Map the parties from Scenario to PartyModel instances
        let parties = scenario.parties?.map { party in
            PartyModel(
                id: UUID(),  // Assign a new UUID
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
        
        // Calculate mandates
        scenarioModel.calculateMandates()
        
        return scenarioModel
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

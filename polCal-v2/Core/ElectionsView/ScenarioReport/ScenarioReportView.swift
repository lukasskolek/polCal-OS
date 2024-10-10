import SwiftUI
import SwiftData

struct ScenarioReportView: View {
    @Binding var path: NavigationPath
    @Environment(\.modelContext) var modelContext
    @Bindable var scenarioModel: ScenarioModel

    // Focus state for the ID text field
    @FocusState private var isNameFocused: Bool

    // State variables
    @State private var isComputedPropertiesSectionVisible: Bool = false
    @State private var isSaved: Bool = false
    @State private var showingDeleteConfirmation = false
    @State private var showingSaveConfirmation = false // New state variable for save confirmation

    var hasResults: Bool {
        scenarioModel.parties?.contains(where: { $0.mandaty > 0 }) == true
    }

    let populusOptions: [(value: Int, label: String)] = [
        (4_388_872, "2023"),
        (4_432_419, "2020"),
        (4_426_760, "2016"),
        (4_392_451, "2012")
    ]

    let incorrectOptions: [(value: Double, label: String)] = [
        (1.4, "1.4%"),
        (1.2, "1.2%"),
        (1.0, "1.0%"),
        (0.8, "0.8%"),
        (0.0, "0.0%")
    ]

    var body: some View {
        VStack {
            Form {
                // Section to edit the ScenarioModel ID
                Section("ID") {
                    TextField("Edit ID", text: $scenarioModel.id)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isNameFocused = false
                        }
                }

                if hasResults {
                    Section("Results") {
                        ResultsView(scenarioModel: scenarioModel)
                            .frame(minHeight: 500, alignment: .center)
                    }
                }

                // Section to manage the list of parties
                Section("Parties") {
                    if Binding($scenarioModel.parties) != nil {
                        HStack {
                            Button(action: {
                                // Fetch the highest number used in "New Party X"
                                let newPartyNumber = (scenarioModel.parties?.compactMap { party -> Int? in
                                    if party.name.starts(with: "New Party ") {
                                        // Extract the number from "New Party X"
                                        let suffix = party.name.dropFirst("New Party ".count)
                                        return Int(suffix)
                                    }
                                    return nil
                                }.max() ?? 0) + 1

                                // Generate the new party name
                                let newPartyName = "New Party \(newPartyNumber)"

                                // Action to add a new party with the generated name
                                let newParty = PartyModel(
                                    name: newPartyName,
                                    votes: 0.0,
                                    coalitionStatus: .alone,
                                    mandaty: 0,
                                    zostatok: 0,
                                    inGovernment: false,
                                    red: 0,
                                    blue: 1,
                                    green: 0.478,
                                    opacity: 1.0
                                )
                                scenarioModel.parties?.append(newParty)
                                scenarioModel.calculateMandates() // Recalculate mandates after adding a new party
                            }) {
                                Label("Add Party", systemImage: "plus")
                                    .buttonStyle(NeatButtonStyle())
                            }
                        }
                        .disabled(scenarioModel.turnoutLeftToBeDistributed < 0.01)
                        .disabled(isNameFocused)

                        // Safely unwrap optional Binding and show the list of parties
                        PartiesInScenarioReportView(scenarioModel: scenarioModel)
                    } else {
                        Text("No parties available")
                    }
                }

                // Section for Turnout with expandable details
                Section("Turnout") {
                    CustomSliderView(percenta: $scenarioModel.turnoutTotal)
                        .padding(.bottom, 5)
                        .onChange(of: scenarioModel.turnoutTotal) {
                            scenarioModel.calculateMandates()
                        }
                        .disabled(isNameFocused)
                }

                // Toggle for showing or hiding the Computed Properties section
                Section("Computed Properties") {
                    Button(action: {
                        withAnimation {
                            isComputedPropertiesSectionVisible.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                            Text(isComputedPropertiesSectionVisible ? "Show less" : "Show more")
                                .underline()
                                .foregroundColor(.blue)
                        }
                        .disabled(isNameFocused)
                    }

                    // Displaying computed properties, conditional on the toggle
                    if isComputedPropertiesSectionVisible {
                        ComputedPropertiesView(scenarioModel: scenarioModel)

                        Picker("Invalid votes & votes not turned in", selection: $scenarioModel.turnoutIncorrect) {
                            ForEach(incorrectOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                        .font(.caption)
                        .onChange(of: scenarioModel.turnoutIncorrect) {
                            scenarioModel.calculateMandates()
                        }
                        .pickerStyle(.menu)
                        .disabled(isNameFocused)

                        Picker("Amount of registered voters", selection: $scenarioModel.populus) {
                            ForEach(populusOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                        .font(.caption)
                        .onChange(of: scenarioModel.populus) {
                            scenarioModel.calculateMandates()
                        }
                        .pickerStyle(.menu)
                        .disabled(isNameFocused)
                    }
                }

                // Section for deleting the scenario if it's saved
                if isSaved {
                    Section("Storage") {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Permanently delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .toolbar {
                Button(action: {
                    saveScenario(scenarioModel)
                    isSaved = true // Update isSaved status
                    showingSaveConfirmation = true // Show confirmation alert
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Scenario Report")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: hasResults)
            .onAppear {
                isSaved = isScenarioSaved(scenarioModel)
            }
            .alert("Delete Scenario", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteScenario(scenarioModel)
                    isSaved = false // Update isSaved status
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to permanently delete this scenario from your archive?")
            }
            .alert("Scenario Saved", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The scenario has been saved successfully. You will now find it in the archive.")
            }
        }
    }

    // Function to check if the scenario is saved in savedVolby.json
    func isScenarioSaved(_ scenarioModel: ScenarioModel) -> Bool {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return false
        }
        let savedVolbyURL = documentsURL.appendingPathComponent("savedVolby.json")
        if !fileManager.fileExists(atPath: savedVolbyURL.path) {
            // savedVolby.json does not exist
            return false
        }
        do {
            let data = try Data(contentsOf: savedVolbyURL)
            let scenarios = try JSONDecoder().decode([Scenario].self, from: data)
            return scenarios.contains(where: { $0.id == scenarioModel.id })
        } catch {
            print("Failed to read savedVolby.json: \(error)")
            return false
        }
    }

    // Function to delete the scenario from savedVolby.json
    func deleteScenario(_ scenarioModel: ScenarioModel) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return
        }
        let savedVolbyURL = documentsURL.appendingPathComponent("savedVolby.json")
        if !fileManager.fileExists(atPath: savedVolbyURL.path) {
            // savedVolby.json does not exist
            return
        }
        do {
            let data = try Data(contentsOf: savedVolbyURL)
            var scenarios = try JSONDecoder().decode([Scenario].self, from: data)
            if let index = scenarios.firstIndex(where: { $0.id == scenarioModel.id }) {
                scenarios.remove(at: index)
                // Write updated scenarios back to file
                let updatedData = try JSONEncoder().encode(scenarios)
                try updatedData.write(to: savedVolbyURL)
                print("Scenario with id \(scenarioModel.id) deleted from savedVolby.json.")
            } else {
                print("Scenario with id \(scenarioModel.id) not found in savedVolby.json.")
            }
        } catch {
            print("Failed to delete scenario from savedVolby.json: \(error)")
        }
    }
}

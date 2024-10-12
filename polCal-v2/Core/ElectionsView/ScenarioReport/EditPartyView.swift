import SwiftUI

struct NamedColor: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
}

struct EditPartyView: View {
    @Binding var party: PartyModel  // Direct binding to the party model
    @Bindable var scenarioModel: ScenarioModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isNameFocused: Bool
    @State private var selectedColorIndex: Int = 0
    
    var totalGovernmentMandates: Int {
        return scenarioModel.parties?.filter { $0.inGovernment }.reduce(0) { $0 + $1.mandaty } ?? 0
    }
    
    static let customColors: [NamedColor] = [
        NamedColor(name: "Red", color: Color(red: 1.0, green: 0.0, blue: 0.0), red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Green", color: Color(red: 0.0, green: 0.5, blue: 0.0), red: 0.0, green: 0.5, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Blue", color: Color(red: 0.0, green: 0.0, blue: 1.0), red: 0.0, green: 0.0, blue: 1.0, opacity: 1.0),
        NamedColor(name: "Orange", color: Color(red: 1.0, green: 0.65, blue: 0.0), red: 1.0, green: 0.65, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Purple", color: Color(red: 0.5, green: 0.0, blue: 0.5), red: 0.5, green: 0.0, blue: 0.5, opacity: 1.0),
        NamedColor(name: "Brown", color: Color(red: 0.6, green: 0.4, blue: 0.2), red: 0.6, green: 0.4, blue: 0.2, opacity: 1.0),
        NamedColor(name: "Teal", color: Color(red: 0.0, green: 0.5, blue: 0.5), red: 0.0, green: 0.5, blue: 0.5, opacity: 1.0),
        NamedColor(name: "Navy", color: Color(red: 0.0, green: 0.0, blue: 0.5), red: 0.0, green: 0.0, blue: 0.5, opacity: 1.0),
        NamedColor(name: "Maroon", color: Color(red: 0.5, green: 0.0, blue: 0.0), red: 0.5, green: 0.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Olive", color: Color(red: 0.5, green: 0.5, blue: 0.0), red: 0.5, green: 0.5, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Turquoise", color: Color(red: 0.25, green: 0.88, blue: 0.82), red: 0.25, green: 0.88, blue: 0.82, opacity: 1.0),
        NamedColor(name: "Magenta", color: Color(red: 1.0, green: 0.0, blue: 1.0), red: 1.0, green: 0.0, blue: 1.0, opacity: 1.0),
        NamedColor(name: "Gold", color: Color(red: 0.83, green: 0.68, blue: 0.21), red: 0.83, green: 0.68, blue: 0.21, opacity: 1.0),
        NamedColor(name: "Coral", color: Color(red: 1.0, green: 0.5, blue: 0.31), red: 1.0, green: 0.5, blue: 0.31, opacity: 1.0),
        NamedColor(name: "Indigo", color: Color(red: 0.29, green: 0.0, blue: 0.51), red: 0.29, green: 0.0, blue: 0.51, opacity: 1.0),
        NamedColor(name: "Dark Cyan", color: Color(red: 0.0, green: 0.55, blue: 0.55), red: 0.0, green: 0.55, blue: 0.55, opacity: 1.0),
        NamedColor(name: "Dark Magenta", color: Color(red: 0.55, green: 0.0, blue: 0.55), red: 0.55, green: 0.0, blue: 0.55, opacity: 1.0)
    ]
    
    init(party: Binding<PartyModel>, scenarioModel: ScenarioModel) {
        self._party = party
        self.scenarioModel = scenarioModel
        // Initialize selectedColorIndex
        let index = EditPartyView.customColors.firstIndex(where: { color in
            // Compare color components with party's color components
            // Use a small tolerance
            let tolerance: Double = 0.01
            return abs(color.red - party.wrappedValue.red) < tolerance &&
                abs(color.green - party.wrappedValue.green) < tolerance &&
                abs(color.blue - party.wrappedValue.blue) < tolerance &&
                abs(color.opacity - party.wrappedValue.opacity) < tolerance
        }) ?? 0 // Default to 0 if no match
        _selectedColorIndex = State(initialValue: index)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Party Name").font(.caption2)) {
                // Text Field to edit party name
                TextField("Party Name", text: $party.name)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isNameFocused = false
                        dismiss()
                    }
            }
            
            Group {
                Section(header: HStack {
                    Text("Party Color").font(.caption2)
                    Circle()
                        .fill(party.color)
                        .frame(width: 20, height: 20)
                }) {
                    Picker("Select Color", selection: $selectedColorIndex) {
                        ForEach(0..<EditPartyView.customColors.count, id: \.self) { index in
                            HStack {
                                Text(EditPartyView.customColors[index].name)
                                    .foregroundStyle(EditPartyView.customColors[index].color)
                            }
                            .tag(index)
                        }
                    }
                    .onChange(of: selectedColorIndex) {
                        let selectedColor = EditPartyView.customColors[selectedColorIndex]
                        party.red = selectedColor.red
                        party.green = selectedColor.green
                        party.blue = selectedColor.blue
                        party.opacity = selectedColor.opacity
                    }
                }
                
                Section(header: Text("Percentage of the vote").font(.caption2)) {
                    // Compute the maximum votes the party can have
                    let totalAllocatedVotesExcludingCurrentParty = (scenarioModel.parties?.filter { $0 !== party }.reduce(0.0) { $0 + $1.votes } ?? 0.0)
                    
                    // Ensure sliderMax is at least a small positive value, like 0.01
                    let availableVotes = scenarioModel.turnoutTotal - totalAllocatedVotesExcludingCurrentParty
                    let sliderMax = max(0.01, availableVotes)
                    
                    // Compute populusAttended
                    let populusAttended = Int(Double(scenarioModel.populus) * scenarioModel.turnoutTotal / 100.0)
                    
                    VStack {
                        HStack {
                            Text("Vote: \(party.votes, specifier: "%.2f")%")
                            let votersForParty = Int((party.votes / 100.0) * Double(populusAttended))
                            Spacer()
                            Text("Voters: \(votersForParty)")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                        .padding(.horizontal)
                        HStack {
                            Text("    Mandates:  \(party.mandaty)")
                            Image(systemName: "person.fill")
                                .foregroundStyle(party.color)
                            Spacer()
                        }
                        
                        Slider(value: $party.votes, in: 0...sliderMax, step: 0.01)
                            .tint(party.color)
                            .onChange(of: party.votes) {
                                // Call calculateMandates when votes change
                                scenarioModel.calculateMandates()
                            }
                        
                        // Add the steppers below the slider
                        VStack(alignment: .leading, spacing: 5) {
                            Stepper(value: $party.votes, in: 0...sliderMax, step: 1) {
                                Text("Adjust by 1%")
                            }
                            .onChange(of: party.votes) {
                                scenarioModel.calculateMandates()
                            }
                            
                            Stepper(value: $party.votes, in: 0...sliderMax, step: 0.01) {
                                Text("Adjust by 0.01%")
                            }
                            .onChange(of: party.votes) {
                                scenarioModel.calculateMandates()
                            }
                        }
                        .padding(.top, 5)
                    }
                }
                
                Section(header: Text("Coalition status").font(.caption2)) {
                    // Picker to edit coalition status
                    Picker("Coalition Status", selection: $party.coalitionStatus) {
                        ForEach(CoalitionStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .onChange(of: party.coalitionStatus) {
                        scenarioModel.calculateMandates()
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Government").font(.caption2)) {
                    Toggle(isOn: $party.inGovernment) {
                        HStack {
                            Image(systemName: "crown.fill")
                                // Conditionally apply yellow color based on total government mandates
                                .foregroundStyle((totalGovernmentMandates > 75 && party.mandaty > 5) ? .yellow : .gray)
                            Text("Forming government")
                        }
                    }
                    .disabled(!party.gotIn)
                }
            }
            .disabled(isNameFocused)
        }
        .navigationTitle("Edit Party")
    }
}

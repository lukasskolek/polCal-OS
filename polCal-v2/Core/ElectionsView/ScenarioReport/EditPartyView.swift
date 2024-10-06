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

//some minor change here

struct EditPartyView: View {
    @Binding var party: Party  // Direct binding to the party
    @Bindable var scenarioModel: ScenarioModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isNameFocused: Bool
    
    @State private var selectedColorIndex: Int = 0
    
    var totalGovernmentMandates: Int {
        return scenarioModel.parties?.filter { $0.inGovernment }.reduce(0) { $0 + $1.mandaty } ?? 0
    }
    
    static let customColors: [NamedColor] = [
        NamedColor(name: "Blue", color: .blue, red: 0.0, green: 0.0, blue: 1.0, opacity: 1.0),
        NamedColor(name: "Red", color: .red, red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Orange", color: .orange, red: 1.0, green: 0.5, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Yellow", color: .yellow, red: 1.0, green: 1.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Green", color: .green, red: 0.0, green: 1.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Indigo", color: Color(red: 0.29, green: 0.0, blue: 0.51), red: 0.29, green: 0.0, blue: 0.51, opacity: 1.0),
        NamedColor(name: "Violet", color: Color(red: 0.93, green: 0.51, blue: 0.93), red: 0.93, green: 0.51, blue: 0.93, opacity: 1.0),
        NamedColor(name: "Pink", color: .pink, red: 1.0, green: 0.75, blue: 0.8, opacity: 1.0),
        NamedColor(name: "Brown", color: Color(red: 0.6, green: 0.4, blue: 0.2), red: 0.6, green: 0.4, blue: 0.2, opacity: 1.0),
        NamedColor(name: "Gray", color: .gray, red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0),
        NamedColor(name: "White", color: .white, red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0),
        NamedColor(name: "Cyan", color: .cyan, red: 0.0, green: 1.0, blue: 1.0, opacity: 1.0),
        NamedColor(name: "Magenta", color: .purple, red: 0.5, green: 0.0, blue: 0.5, opacity: 1.0),
        NamedColor(name: "Lime", color: Color(red: 0.75, green: 1.0, blue: 0.0), red: 0.75, green: 1.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Olive", color: Color(red: 0.5, green: 0.5, blue: 0.0), red: 0.5, green: 0.5, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Navy", color: Color(red: 0.0, green: 0.0, blue: 0.5), red: 0.0, green: 0.0, blue: 0.5, opacity: 1.0),
        NamedColor(name: "Teal", color: Color(red: 0.0, green: 0.5, blue: 0.5), red: 0.0, green: 0.5, blue: 0.5, opacity: 1.0),
        NamedColor(name: "Maroon", color: Color(red: 0.5, green: 0.0, blue: 0.0), red: 0.5, green: 0.0, blue: 0.0, opacity: 1.0),
        NamedColor(name: "Gold", color: Color(red: 1.0, green: 0.84, blue: 0.0), red: 1.0, green: 0.84, blue: 0.0, opacity: 1.0),
        
        NamedColor(name: "Turquoise", color: Color(red: 0.25, green: 0.88, blue: 0.82), red: 0.25, green: 0.88, blue: 0.82, opacity: 1.0),
        NamedColor(name: "Coral", color: Color(red: 1.0, green: 0.5, blue: 0.31), red: 1.0, green: 0.5, blue: 0.31, opacity: 1.0),
        NamedColor(name: "Beige", color: Color(red: 0.96, green: 0.96, blue: 0.86), red: 0.96, green: 0.96, blue: 0.86, opacity: 1.0),
        NamedColor(name: "Salmon", color: Color(red: 0.98, green: 0.5, blue: 0.45), red: 0.98, green: 0.5, blue: 0.45, opacity: 1.0),
        NamedColor(name: "Lavender", color: Color(red: 0.9, green: 0.9, blue: 0.98), red: 0.9, green: 0.9, blue: 0.98, opacity: 1.0),
        NamedColor(name: "Mint", color: Color(red: 0.6, green: 1.0, blue: 0.6), red: 0.6, green: 1.0, blue: 0.6, opacity: 1.0),
        NamedColor(name: "Mustard", color: Color(red: 1.0, green: 0.86, blue: 0.35), red: 1.0, green: 0.86, blue: 0.35, opacity: 1.0),
        NamedColor(name: "Khaki", color: Color(red: 0.76, green: 0.69, blue: 0.57), red: 0.76, green: 0.69, blue: 0.57, opacity: 1.0)
    ]
    
    init(party: Binding<Party>, scenarioModel: ScenarioModel) {
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
            
            ///FIX THIS SHIT COLOR CHANGING DOES NOT WORK NOW!!!!!!!!!!
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
                            .tag(index) // Make sure this line is uncommented
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
                    let sliderMax: Double = max(0.01, scenarioModel.turnoutLeftToBeDistributed + party.votes)
                    VStack {
                        HStack {
                            Text("Vote: \(party.votes, specifier: "%.2f")%")
                            let votersForParty = Int((party.votes / 100.0) * Double(scenarioModel.populusAttended))
                            Spacer()
                            Text("Voters: \(Int(votersForParty))")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                        .padding(.horizontal)
                        HStack{
                            Text("    Mandates:  \(party.mandaty)")
                            Image(systemName: "person.fill")
                                .foregroundStyle(party.color)
                            Spacer()
                        }
                        
                        Slider(value: $party.votes, in: 0...sliderMax, step: 0.01)
                            .tint(Color(red: party.red, green: party.green, blue: party.blue, opacity: party.opacity))
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
                Section(header: Text("Coalition status").font(.caption2)){
                    // Picker to edit coalition status
                    Picker("Coalition Status", selection: $party.coalitionStatus) {
                        ForEach(CoalitionStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .onChange(of: party.coalitionStatus) {
                        scenarioModel.calculateMandates()
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Government").font(.caption2)){
                    Toggle(isOn: $party.inGovernment) {
                        HStack{
                            Image(systemName: "crown.fill")
                            // Conditionally apply yellow color based on total government mandates
                                .foregroundStyle(totalGovernmentMandates > 75 ? .yellow : .gray)
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


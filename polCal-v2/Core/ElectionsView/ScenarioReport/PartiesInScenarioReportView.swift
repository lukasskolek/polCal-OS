import SwiftUI

struct PartiesInScenarioReportView: View {
    @Bindable var scenarioModel: ScenarioModel  // Bindable ScenarioModel, allowing for dynamic updates
    @State private var expandedParties: [String: Bool] = [:]
    @State private var isEditPartyPresented = false

    var totalGovernmentMandates: Int {
        return scenarioModel.parties?.filter { $0.inGovernment }.reduce(0) { $0 + $1.mandaty } ?? 0
    }
    
    // Computed property to get sorted parties binding
    var sortedPartiesBinding: [Binding<Party>] {
        if let parties = scenarioModel.parties {
            return parties.map { party in
                // Create a binding for each party
                Binding(
                    get: { party },
                    set: { newValue in
                        if let index = scenarioModel.parties?.firstIndex(where: { $0.name == party.name }) {
                            scenarioModel.parties?[index] = newValue
                        }
                    }
                )
            }
            .sorted(by: { $0.wrappedValue.votes > $1.wrappedValue.votes })
        } else {
            return []
        }
    }

    var body: some View {
        List {
            ForEach(sortedPartiesBinding, id: \.wrappedValue.name) { $party in
                let turnoutLeft = scenarioModel.turnoutLeftToBeDistributed
                let sliderMax = max(0.01, turnoutLeft + party.votes)
                
                DisclosureGroup(isExpanded: Binding(
                    get: { expandedParties[party.name] ?? false },
                    set: { expandedParties[party.name] = $0 }
                )) {
                    VStack(alignment: .leading) {
                        // Existing code for editing party votes and percentage via slider
                        VStack {
                            HStack{
                                Text("Vote: \(party.votes, specifier: "%.2f")%")
                                let votersForParty = Int((party.votes / 100.0) * Double(scenarioModel.populusAttended))
                                Spacer()
                                Text("Voters: \(votersForParty)")
                                    .foregroundColor(.gray)
                            }
                            Slider(value: Binding(
                                get: { min(party.votes, sliderMax) },  // Ensure votes stay within valid range
                                set: { newValue in
                                    party.votes = max(0.0, min(newValue, sliderMax))  // Clamp values between 0 and sliderMax
                                    scenarioModel.calculateMandates()
                                }
                            ), in: 0...sliderMax, step: 0.01)
                            .tint(party.color)
                        }
                        .padding(.bottom, 5)
                        
                        // NavigationLink to edit party details
                        NavigationLink(destination: EditPartyView(party: $party, scenarioModel: scenarioModel)) {
                            HStack{
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.blue)
                                Text("Edit party details")
                                    .underline()
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                } label: {
                    HStack{
                        Image(systemName: "circle.fill")
                            .foregroundColor(party.color)
                            .opacity(party.gotIn ? 1 : 0.4)
                        Text(party.name)
                            .font(.headline)
                            .opacity(party.gotIn ? 1 : 0.4)
                        if party.inGovernment {
                            Image(systemName: "crown.fill")
                            // Conditionally apply yellow color based on total government mandates
                                .foregroundStyle((totalGovernmentMandates > 75 && party.mandaty > 5) ? .yellow : .gray)
                        }
                        Spacer()
                        Text("\(party.mandaty)")
                            .font(.headline)
                            .opacity(party.gotIn ? 1 : 0.4)
                        Image(systemName: "person.fill")
                            .foregroundColor(party.color)
                            .opacity(party.gotIn ? 1 : 0.4)
                    }
                }
                .padding(.vertical, 5)
            }
            .onDelete(perform: deleteParty)
        }
    }
    
    // Delete party from scenarioModel's parties array
    private func deleteParty(at offsets: IndexSet) {
        if let indices = offsets.map({ index in
            scenarioModel.parties?.firstIndex(where: { $0.name == sortedPartiesBinding[index].wrappedValue.name })
        }) as? [Int] {
            for index in indices.reversed() {
                scenarioModel.parties?.remove(at: index)
            }
            scenarioModel.calculateMandates()
        }
    }
}

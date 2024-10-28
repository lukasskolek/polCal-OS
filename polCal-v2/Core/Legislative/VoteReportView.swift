import SwiftUI

struct VoteReportView: View {
    @Binding var path: NavigationPath
    @Environment(\.modelContext) var modelContext
    @Bindable var vote: Vote

    // Focus state for the ID text field
    @FocusState private var isNameFocused: Bool
    // Maintain a dictionary of expanded states for parties using their IDs
    @State private var expandedParties: [Int: Bool] = [:]

    var body: some View {
        VStack {
            // Summary at the top
            Form {
                // Section for ID & Type
                Section(header: Text("ID & Type")) {
                    TextField("Edit ID", text: $vote.id)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isNameFocused = false
                        }
                    Picker("Select type of vote", selection: $vote.typevote) {
                        Text("Standard")
                            .tag(TypeVote.standard)
                        Text("Veto")
                            .tag(TypeVote.veto)
                        Text("Constitutional")
                            .tag(TypeVote.constitutional)
                    }
                    .pickerStyle(.segmented)
                }

                // Section for Result
                Section(header: Text("Result")) {
                    HStack {
                        if vote.didPass() {
                            Text("PASSED")
                                .fontWeight(.bold)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Text("DID NOT PASS")
                                .fontWeight(.bold)
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    HStack {
                        Text("Required to pass: \(votesNeeded())")
                        Spacer()
                        Text("For votes: \(forVotes())")
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Present: \(presentVotes())")
                        Spacer()
                        Text("Against votes: \(againstVotes())")
                            .fontWeight(.semibold)
                    }
                }

                // Section for Voting
                Section(header: Text("Voting")) {
                    List {
                        // Group MPs by their legParty
                        let parties = Dictionary(grouping: vote.mps) { $0.legParty }

                        // Create an array of (legParty: legParty?, id: Int) and sort by id
                        let sortedParties = parties.keys.map { legParty -> (legParty: legParty?, id: Int) in
                            if let legParty = legParty {
                                return (legParty: legParty, id: legParty.id)
                            } else {
                                return (legParty: nil, id: Int.max) // Assign a high id for Independents to appear last
                            }
                        }.sorted(by: { $0.id < $1.id })

                        ForEach(sortedParties, id: \.id) { partyTuple in
                            let legParty = partyTuple.legParty
                            let partyId = legParty?.id ?? -1 // Use -1 for Independents
                            let partyName = legParty?.name ?? "Independent"
                            let mps = parties[legParty] ?? []

                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedParties[partyId] ?? false },
                                    set: { expandedParties[partyId] = $0 }
                                ),
                                content: {
                                        VStack{
                                            ForEach(mps) { mp in
                                                MPRowView(mp: mp)
                                        }
                                    }
                                },
                                label: {
                                    VStack{
                                        HStack {
                                            Text(partyName)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Text("\(mps.filter { $0.vote == .forVote }.count) / \(mps.count)")
                                                .font(.headline)
                                        }
                                        Slider(value: Binding<Double>(
                                            get: {
                                                Double(mps.filter { $0.vote == .forVote }.count)
                                            },
                                            set: { newValue in
                                                adjustMPVotes(mps: mps, forVotes: Int(newValue))
                                            }
                                        ), in: 0...Double(mps.count), step: 1)
                                        .tint(.blue)
                                    }
                                }
                            )
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
    }

    // Helper functions
    func votesNeeded() -> Int {
        if vote.typevote == .standard {
            let counted = vote.mps.filter { $0.vote != .notPresent }.count
            return counted <= 76 ? 39 : counted / 2 + 1
        } else if vote.typevote == .veto {
            return 76
        } else {
            return 90
        }
    }

    func againstVotes() -> Int {
        return vote.mps.filter { $0.vote == .against }.count
    }
    
    func presentVotes() -> Int {
        return vote.mps.filter { $0.vote != .notPresent }.count
    }
    
    func forVotes() -> Int {
        return vote.mps.filter { $0.vote == .forVote }.count
    }

    // Function to adjust MPs' votes based on the slider value
    func adjustMPVotes(mps: [MP], forVotes: Int) {
        let sortedMPs = mps.sorted(by: { $0.name < $1.name })
        for (index, mp) in sortedMPs.enumerated() {
            mp.vote = index < forVotes ? .forVote : .notPresent
        }
    }
}

struct MPRowView: View {
    @ObservedObject var mp: MP

    var body: some View {
        HStack {
            Text(mp.name)
            Spacer()
            Picker("", selection: $mp.vote) {
                ForEach(VotingChoice.allCases) { choice in
                    Text(choice.rawValue).tag(choice)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
        }
    }
}

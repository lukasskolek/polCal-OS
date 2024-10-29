import SwiftUI

struct VoteReportView: View {
    @Binding var path: NavigationPath
    @Environment(\.modelContext) var modelContext
    @Bindable var vote: VoteModel

    // Focus state for the ID text field
    @FocusState private var isNameFocused: Bool
    // Maintain a dictionary of expanded states for parties using their IDs
    @State private var expandedParties: [Int: Bool] = [:]
    
    // State variable to hold the IDs of saved votes
    @State private var savedVoteIDs: Set<String> = []
    @State private var showingSaveConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var isSaved: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

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
                        let sortedParties = parties.keys.map { legParty -> (legParty: legPartyModel?, id: Int) in
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
                    saveButtonTapped()
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Vote Report")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isSaved = isVoteSaved(vote)
            }
            .alert("Delete Vote", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteVote(vote)
                    isSaved = false // Update isSaved status
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to permanently delete this vote from your archive?")
            }
            .alert("Scenario Saved", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The scenario has been saved successfully. You will now find it in the archive.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func saveButtonTapped() {
        do {
            try saveVote(vote)
            isSaved = true // Update isSaved status
            showingSaveConfirmation = true // Show confirmation alert
        } catch {
            // Handle the error and inform the user
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    func isVoteSaved(_ voteModel: VoteModel) -> Bool {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return false
        }
        let savedVotesURL = documentsURL.appendingPathComponent("savedVotes.json")
        if !fileManager.fileExists(atPath: savedVotesURL.path) {
            // savedVolby.json does not exist
            return false
        }
        do {
            let data = try Data(contentsOf: savedVotesURL)
            let votes = try JSONDecoder().decode([Vote].self, from: data)
            return votes.contains(where: { $0.id == voteModel.id })
        } catch {
            print("Failed to read savedVotes.json: \(error)")
            return false
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
    func adjustMPVotes(mps: [MPModel], forVotes: Int) {
        let sortedMPs = mps.sorted(by: { $0.name < $1.name })
        for (index, mp) in sortedMPs.enumerated() {
            mp.vote = index < forVotes ? .forVote : .notPresent
        }
    }
    func loadSavedVoteIDs() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return
        }
        let savedVotesURL = documentsURL.appendingPathComponent("savedVotes.json")
        if !fileManager.fileExists(atPath: savedVotesURL.path) {
            // savedVolby.json does not exist
            savedVoteIDs = []
            return
        }
        do {
            let data = try Data(contentsOf: savedVotesURL)
            let votes = try JSONDecoder().decode([Vote].self, from: data)
            let ids = votes.map { $0.id }
            savedVoteIDs = Set(ids)
        } catch {
            print("Failed to read savedVolby.json: \(error)")
            savedVoteIDs = []
        }
    }
    
    
    
    func legPartyModelToLegParty(_ model: legPartyModel) -> legParty {
        return legParty(id: model.id, name: model.name)
    }

    func mpModelToMP(_ mpModel: MPModel) -> MP {
        let legParty = mpModel.legParty != nil ? legPartyModelToLegParty(mpModel.legParty!) : nil
        return MP(name: mpModel.name, legParty: legParty, vote: mpModel.vote)
    }

    // Helper function to convert VoteModel to Vote
    func voteModelToVote(_ model: VoteModel) -> Vote {
        // Map the MPs from VoteModel to MP structs
        let mps = model.mps.map { mpModelToMP($0) }

        let vote = Vote(
            id: model.id,
            mps: mps,
            typevote: model.typevote
        )

        return vote
    }
    
    func deleteVote(_ vote: VoteModel) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return
        }
        let savedVotesURL = documentsURL.appendingPathComponent("savedVotes.json")
        if !fileManager.fileExists(atPath: savedVotesURL.path) {
            // savedVotes.json does not exist
            return
        }
        do {
            let data = try Data(contentsOf: savedVotesURL)
            var votes = try JSONDecoder().decode([Vote].self, from: data)
            if let index = votes.firstIndex(where: { $0.id == vote.id }) {
                votes.remove(at: index)
                // Write updated scenarios back to file
                let updatedData = try JSONEncoder().encode(votes)
                try updatedData.write(to: savedVotesURL)
                print("Vote with id \(vote.id) deleted from savedVotes.json.")
            } else {
                print("Vote with id \(vote.id) not found in savedVotes.json.")
            }
        } catch {
            print("Failed to delete vote from savedVotes.json: \(error)")
        }
    }

    
}

struct MPRowView: View {
    @ObservedObject var mp: MPModel

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



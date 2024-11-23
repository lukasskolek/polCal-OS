//
//  VoteReportView.swift
//  polCal-v2
//
//  Created by Lukas on 18/11/2024.
//

import SwiftUI

struct VoteReportView: View {
    @Binding var path: NavigationPath
    @Environment(\.modelContext) var modelContext
    
    @Environment(\.displayScale) var displayScale
    @Bindable var vote: SVKVoteModel

    // Focus state for the ID text field
    @FocusState private var isNameFocused: Bool
    // Expanded states for parties
    @State private var expandedParties: [Int: Bool] = [:]
    
    @State private var renderedImage = Image(systemName: "photo")
    
    // State variables for storage and errors
    @State private var savedVoteIDs: Set<String> = []
    @State private var showingSaveConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var isSaved: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Form {
                // Pass vote directly since subviews now accept @Bindable
                IDTypeSection(vote: vote)
                ResultSection(vote: vote)
                VotingSection(vote: vote, expandedParties: $expandedParties)
                
                if isSaved {
                    StorageSection(showingDeleteConfirmation: $showingDeleteConfirmation)
                }
            }
            .toolbar {
                // Save Button
                Button(action: saveButtonTapped) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Vote Report")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { isSaved = isVoteSaved(vote) }
            .alert("Delete Vote", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteVote(vote)
                    isSaved = false
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
    
    func deleteVote(_ vote: SVKVoteModel) {
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
                var votes = try JSONDecoder().decode([SVKVote].self, from: data)
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
    
    func isVoteSaved(_ voteModel: SVKVoteModel) -> Bool {
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
                let votes = try JSONDecoder().decode([SVKVote].self, from: data)
                return votes.contains(where: { $0.id == voteModel.id })
            } catch {
                print("Failed to read savedVotes.json: \(error)")
                return false
            }
        }
}

//Inside VoteReportView
struct IDTypeSection: View {
    @Bindable var vote: SVKVoteModel
    @FocusState private var isNameFocused: Bool // Manage focus state locally

    var body: some View {
        Section(header: Text("ID & Type")) {
            TextField("Edit ID", text: $vote.id)
                .focused($isNameFocused)
                .submitLabel(.done)
                .onSubmit {
                    isNameFocused = false
                }

            Picker("Select type of vote", selection: $vote.typevote) {
                Text("Standard").tag(SVKTypeVote.standard)
                Text("Veto").tag(SVKTypeVote.veto)
                Text("Constitutional").tag(SVKTypeVote.constitutional)
            }
            .pickerStyle(.segmented)
        }
    }
}

//Inside VoteReportView
struct ResultSection: View {
    @Bindable var vote: SVKVoteModel

    var body: some View {
        Section(header: Text("Result")) {
            HStack {
                if vote.didPass() {
                    Text("PASSED").fontWeight(.bold)
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else {
                    Text("DID NOT PASS").fontWeight(.bold)
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                }
            }
            HStack {
                Text("Required to pass: \(votesNeeded())")
                Spacer()
                Text("For votes: \(forVotes())").fontWeight(.bold)
            }
            HStack {
                Text("Present: \(presentVotes())")
                Spacer()
                Text("Against votes: \(againstVotes())").fontWeight(.semibold)
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
}

//Inside VoteReportView
struct VotingSection: View {
    @Bindable var vote: SVKVoteModel
    @Binding var expandedParties: [Int: Bool]

    var body: some View {
        Section(header: Text("Voting")) {
            List {
                ForEach(sortedParties(), id: \.id) { partyTuple in
                    let legParty = partyTuple.legParty
                    let partyId = legParty?.id ?? -1 // Use -1 for Independents
                    let partyName = legParty?.name ?? "Independent"
                    let mps = parties()[legParty] ?? []

                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedParties[partyId] ?? false },
                            set: { expandedParties[partyId] = $0 }
                        ),
                        content: {
                            PartyMPsView(mps: mps)
                        },
                        label: {
                            PartyHeaderView(partyName: partyName, mps: mps)
                        }
                    )
                    .padding(.vertical, 5)
                }
            }
        }
    }

    func parties() -> [SVKlegPartyModel?: [SVKMPModel]] {
        Dictionary(grouping: vote.mps) { $0.legParty }
    }

    func sortedParties() -> [(legParty: SVKlegPartyModel?, id: Int)] {
        parties().keys.map { legParty -> (legParty: SVKlegPartyModel?, id: Int) in
            if let legParty = legParty {
                return (legParty: legParty, id: legParty.id)
            } else {
                return (legParty: nil, id: Int.max) // Independents last
            }
        }.sorted(by: { $0.id < $1.id })
    }
}

//Inside VoteReportView inside VotingSection
struct PartyHeaderView: View {
    var partyName: String
    var mps: [SVKMPModel]

    var body: some View {
        VStack {
            HStack {
                Text(partyName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(forVoteCount()) / \(mps.count)")
                    .font(.headline)
            }
            Slider(value: Binding<Double>(
                get: { Double(forVoteCount()) },
                set: { newValue in
                    adjustMPVotes(forVotes: Int(newValue))
                }
            ), in: 0...Double(mps.count), step: 1)
            .tint(.blue)
        }
    }

    func forVoteCount() -> Int {
        mps.filter { $0.vote == .forVote }.count
    }

    func adjustMPVotes(forVotes: Int) {
        let sortedMPs = mps.sorted(by: { $0.name < $1.name })
        for (index, mp) in sortedMPs.enumerated() {
            mp.vote = index < forVotes ? .forVote : .notPresent
        }
    }
}

//Inside VoteReportView inside VotingSection
struct PartyMPsView: View {
    var mps: [SVKMPModel]

    var body: some View {
        VStack {
            ForEach(mps) { mp in
                MPRowView(mp: mp)
            }
        }
    }
}

//Inside VoteReportView
struct StorageSection: View {
    @Binding var showingDeleteConfirmation: Bool

    var body: some View {
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

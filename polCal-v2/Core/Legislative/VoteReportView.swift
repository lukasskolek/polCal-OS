import SwiftUI

struct VoteReportView: View {
    @Binding var path: NavigationPath
    @Environment(\.modelContext) var modelContext
    
    @Environment(\.displayScale) var displayScale
    @Bindable var vote: VoteModel

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
                // Share Button using ShareLink
                ShareLink(item: render(vote: vote), preview: SharePreview(Text("Vote summary"))) {
                    Label("Share", systemImage: "square.and.arrow.up")
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
    
    @MainActor
    func render(vote: VoteModel) -> Image {
        let renderer = ImageRenderer(content: ActivityView(vote: vote))
        
        // Set the correct display scale for this device
        renderer.scale = displayScale

        // Return the rendered image if available, otherwise a placeholder image
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "photo") // Placeholder if rendering fails
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
}

struct IDTypeSection: View {
    @Bindable var vote: VoteModel
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
                Text("Standard").tag(TypeVote.standard)
                Text("Veto").tag(TypeVote.veto)
                Text("Constitutional").tag(TypeVote.constitutional)
            } 
            .pickerStyle(.segmented)
        }
    }
}

struct ResultSection: View {
    @Bindable var vote: VoteModel

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

struct VotingSection: View {
    @Bindable var vote: VoteModel
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

    func parties() -> [legPartyModel?: [MPModel]] {
        Dictionary(grouping: vote.mps) { $0.legParty }
    }

    func sortedParties() -> [(legParty: legPartyModel?, id: Int)] {
        parties().keys.map { legParty -> (legParty: legPartyModel?, id: Int) in
            if let legParty = legParty {
                return (legParty: legParty, id: legParty.id)
            } else {
                return (legParty: nil, id: Int.max) // Independents last
            }
        }.sorted(by: { $0.id < $1.id })
    }
}


struct PartyHeaderView: View {
    var partyName: String
    var mps: [MPModel]

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

struct PartyMPsView: View {
    var mps: [MPModel]

    var body: some View {
        VStack {
            ForEach(mps) { mp in
                MPRowView(mp: mp)
            }
        }
    }
}

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


struct VotingSummaryView: View {
    var vote: VoteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(sortedParties(), id: \.id) { partyTuple in
                PartyVotesRow(legParty: partyTuple.legParty, mps: parties()[partyTuple.legParty] ?? [])
            }
            Spacer()
            HStack{
                VotingSummaryLegendView()
                Spacer()
                VoteBarChartView(vote: vote)
            }
        }
        .padding()
        .frame(width: 170, height: 170)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    func parties() -> [legPartyModel?: [MPModel]] {
        Dictionary(grouping: vote.mps) { $0.legParty }
    }

    func sortedParties() -> [(legParty: legPartyModel?, id: Int)] {
        parties().keys.map { legParty -> (legParty: legPartyModel?, id: Int) in
            if let legParty = legParty {
                return (legParty: legParty, id: legParty.id)
            } else {
                return (legParty: nil, id: Int.max) // Independents last
            }
        }.sorted(by: { $0.id < $1.id })
    }
}

struct PartyVotesRow: View {
    var legParty: legPartyModel?
    var mps: [MPModel]

    var body: some View {
        let partyName = legParty?.name ?? "Independent"
        let forVotesCount = mps.filter { $0.vote == .forVote }.count
        let agaVotesCount = mps.filter { $0.vote == .against }.count
        let dnvVotesCount = mps.filter { $0.vote == .didNotVote }.count
        let npVotesCount = mps.filter { $0.vote == .notPresent }.count
        let rfVotesCount = mps.filter { $0.vote == .refusedToVote }.count

        HStack(spacing: 1) {
            Text(partyName)
                .font(.system(size: 6, weight: .bold))
                .lineLimit(1)
                .padding(.trailing, 4)
            Text("\(mps.count)")
                .font(.system(size: 6))
                .foregroundStyle(.gray)
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 6, height: 6)
                .foregroundStyle(.gray)
            
            Spacer()

            HStack(spacing: 5) {
                CountText(count: forVotesCount, color: .green)
                CountText(count: agaVotesCount, color: .red)
                CountText(count: dnvVotesCount, color: .mint, opacity: 0.75)
                CountText(count: npVotesCount, color: .purple, opacity: 0.75)
                CountText(count: rfVotesCount, color: .cyan, opacity: 0.75)
            }
        }
    }
}

struct CountText: View {
    var count: Int
    var color: Color
    var opacity: Double = 1.0

    var body: some View {
        Text("\(count)")
            .font(.system(size: 6, weight: .bold))
            .foregroundStyle(color)
            .opacity(opacity)
    }
}

struct VotingSummaryLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            LegendRow(color: .green, label: "For")
            LegendRow(color: .red, label: "Against")
            LegendRow(color: .mint, label: "Did not vote", opacity: 0.75)
            LegendRow(color: .purple, label: "Not present", opacity: 0.75)
            LegendRow(color: .cyan, label: "Refused to vote", opacity: 0.75)
        }
        .padding(1)
    }
}

struct LegendRow: View {
    var color: Color
    var label: String
    var opacity: Double = 1.0

    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(color)
                .opacity(opacity)
                .frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: 5))
        }
    }
}

import Charts

struct VoteBarChartView: View {
    var vote: VoteModel

    var body: some View {
        Chart {
            // Single BarMark for each voting type, showing aggregated count across all parties

            BarMark(x: .value("Vote Type", "For"), y: .value("Count", forVotesCount()))
                .foregroundStyle(.green)
                .annotation(position: .bottom) { Text("\(forVotesCount())")
                        .foregroundStyle(.green)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Against"), y: .value("Count", againstVotesCount()))
                .foregroundStyle(.red)
                .annotation(position: .bottom) { Text("\(againstVotesCount())")
                        .foregroundStyle(.red)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Did Not Vote"), y: .value("Count", didNotVoteCount()))
                .foregroundStyle(.mint)
                .opacity(0.75)
                .annotation(position: .bottom) { Text("\(didNotVoteCount())")
                        .foregroundStyle(.mint)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Not Present"), y: .value("Count", notPresentCount()))
                .foregroundStyle(.purple)
                .opacity(0.75)
                .annotation(position: .bottom) { Text("\(notPresentCount())")
                        .foregroundStyle(.purple)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Refused to Vote"), y: .value("Count", refusedToVoteCount()))
                .foregroundStyle(.cyan)
                .opacity(0.75)
                .annotation(position: .bottom) { Text("\(refusedToVoteCount())")
                        .foregroundStyle(.cyan)
                        .font(.system(size: 4))
                }
        }
        .frame(width: 60, height: 50, alignment: .trailing)
        .background(Color(.secondarySystemBackground))
        .chartXAxis(.hidden) // Hide x-axis
        .chartYAxis(.hidden)
    }
    
    // Helper functions to count each type of vote
    private func forVotesCount() -> Int {
        vote.mps.filter { $0.vote == .forVote }.count
    }
    
    private func againstVotesCount() -> Int {
        vote.mps.filter { $0.vote == .against }.count
    }
    
    private func didNotVoteCount() -> Int {
        vote.mps.filter { $0.vote == .didNotVote }.count
    }
    
    private func notPresentCount() -> Int {
        vote.mps.filter { $0.vote == .notPresent }.count
    }
    
    private func refusedToVoteCount() -> Int {
        vote.mps.filter { $0.vote == .refusedToVote }.count
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

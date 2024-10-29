//
//  LegModelView.swift
//  polCal-v2
//
//  Created by Lukas on 27/10/2024.
//

import SwiftUI
import SwiftData

struct LegModelView: View {
    @Environment(\.modelContext) var modelContext
    @Query var votes: [VoteModel]
    
    @State private var savedVoteIDs: Set<String> = []
    
    var body: some View {
        List {
            ForEach(votes) { vote in
                NavigationLink(value: vote) {
                    HStack {
                        Text("\(vote.id)")
                        if savedVoteIDs.contains(vote.id) {
                            Image(systemName: "opticaldisc")
                        }
                    }
                }
            }
            .onDelete(perform: deleteVote)
        }
        .overlay {
            if votes.isEmpty {
                ContentUnavailableView(label: {
                    Label("No votes", systemImage: "list.bullet.rectangle.portrait")
                }, description: {
                    Text("Start by creating a new one \(Image(systemName: "plus")), or load some from the archive \(Image(systemName: "archivebox")) above.")
                }, actions: {
                    Button("Create a new vote") { addVote() }
                        .buttonStyle(NeatButtonStyle())
                })
            }
        }
        .onAppear(perform: loadSavedVoteIDs)
    }
    init(searchString: String = "", sortOrder: [SortDescriptor<VoteModel>] = []) {
        _votes = Query(filter: #Predicate { vote in
            if searchString.isEmpty {
                return true
            } else {
                return vote.id.localizedStandardContains(searchString)
            }
        }, sort: sortOrder)
    }
    
    func addVote(){
        do {
            let existingVotes = try modelContext.fetch(VoteModel.fetchRequest())
            
            // Find the highest number used in "New custom scenario X"
            let newIDNumber = (existingVotes.compactMap { vote -> Int? in
                if vote.id.starts(with: "New custom vote ") {
                    let suffix = vote.id.dropFirst("New custom vote ".count)
                    return Int(suffix)
                }
                return nil
            }.max() ?? 0) + 1
            
            // Generate the new scenario ID
            let newID = "New custom vote \(newIDNumber)"
            
            // Create the new scenario with default values and the generated ID
            let vote = VoteModel(
                id: newID,
                mps: currentMPs,
                typevote: TypeVote.standard
            )
            
            // Insert the new scenario into the model context
            modelContext.insert(vote)
            
        } catch {
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }
    func deleteVote(at offsets: IndexSet) {
        for offset in offsets {
            let vote = votes[offset]
            modelContext.delete(vote)
        }
    }
    func loadSavedVoteIDs() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access the documents directory.")
            return
        }
        let savedVoteURL = documentsURL.appendingPathComponent("savedVote.json")
        if !fileManager.fileExists(atPath: savedVoteURL.path) {
            // savedVolby.json does not exist
            savedVoteIDs = []
            return
        }
        do {
            let data = try Data(contentsOf: savedVoteURL)
            let votes = try JSONDecoder().decode([Vote].self, from: data)
            let ids = votes.map { $0.id }
            savedVoteIDs = Set(ids)
        } catch {
            print("Failed to read savedVote.json: \(error)")
            savedVoteIDs = []
        }
    }
    
}

#Preview {
    LegModelView()
}

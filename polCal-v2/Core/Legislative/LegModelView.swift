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
    @Query var votes: [Vote]
    
    var body: some View {
        List {
            ForEach(votes) { vote in
                NavigationLink(value: vote) {
                        Text("\(vote.id)")
                }
            }
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
        .onAppear(perform: {})
    }
    func addVote(){
        do {
            let existingVotes = try modelContext.fetch(Vote.fetchRequest())
            
            // Find the highest number used in "New custom scenario X"
            let newIDNumber = (existingVotes.compactMap { vote -> Int? in
                if vote.id.starts(with: "New custom vote ") {
                    let suffix = vote.id.dropFirst("New custom vote ".count)
                    return Int(suffix)
                }
                return nil
            }.max() ?? 0) + 1
            
            // Generate the new scenario ID
            let newID = "New custom scenario \(newIDNumber)"
            
            // Create the new scenario with default values and the generated ID
            let vote = Vote(
                id: newID,
                mps: currentMPs
            )
            
            // Insert the new scenario into the model context
            modelContext.insert(vote)
            
        } catch {
            print("Failed to fetch existing scenarios: \(error.localizedDescription)")
        }
    }
    
}

#Preview {
    LegModelView()
}

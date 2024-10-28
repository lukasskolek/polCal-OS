//
//  LegislativeView.swift
//  polCal-v2
//
//  Created by Lukas on 24/10/2024.
//

import SwiftUI
import SwiftData

struct LegislativeView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Binding var selectedTab: Int
    
    @Binding var path: NavigationPath
    
   // var parliaments = ["2020","2023", "current"]
    @State var selectedParlSetup: String = "current"
    
    
    var body: some View {
        NavigationStack {
            LegModelView()
                .navigationTitle("Browse votes")
                .toolbar {
                    if selectedTab == 1 {

                        Menu {
//                            ForEach(userVotes, id: \.id) { vote in
//                                Button(vote.id) {
//                                    loadUserVote(vote)
//                                }
//                            }
                            
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        Button(action: addVote) {
                            Label("Add Scenario", systemImage: "plus")
                        }
                        // Button to delete all scenarios
                        Button(role: .destructive, action: deleteAllVotes) {
                            Label("Delete All", systemImage: "trash")
                                .foregroundColor(.red)
                                .accentColor(.red)
                        }
                        .buttonStyle(RedButtonStyle())
                        
                        
                    }
                }
                .navigationDestination(for: Vote.self) { vote in
                    VoteReportView(path: $path, vote: vote)
                }
        }
    }
    func addVote() {
        do {
            let existingVotes = try modelContext.fetch(Vote.fetchRequest())
            
            // Find the highest number used in "New custom vote X"
            let newIDNumber = (existingVotes.compactMap { vote -> Int? in
                if vote.id.starts(with: "New custom vote ") {
                    let suffix = vote.id.dropFirst("New custom vote ".count)
                    return Int(suffix)
                }
                return nil
            }.max() ?? 0) + 1
            
            // Generate the new scenario ID
            let newID = "New custom vote \(newIDNumber)"
            
            // Create new instances of MPs for the new vote
            let newMPs = currentMPs.map { oldMP -> MP in
                // Create a new MP instance with the same properties
                let newMP = MP(name: oldMP.name)
                newMP.legParty = oldMP.legParty
                // Set other properties if needed
                return newMP
            }
            
            // Create the new vote with the new MP instances
            let vote = Vote(
                id: newID,
                mps: newMPs,
                typevote: TypeVote.standard
            )
            
            // Insert the new vote into the model context
            modelContext.insert(vote)
            
        } catch {
            print("Failed to fetch existing votes: \(error.localizedDescription)")
        }
    }
    
    func deleteAllVotes() {
        do {
            let allVotes = try modelContext.fetch(Vote.fetchRequest())
            for vote in allVotes {
                modelContext.delete(vote)
            }
        } catch {
            print("Failed to delete all votes: \(error.localizedDescription)")
        }
    }
}

//#Preview {
//    NavigationStack{
//        LegislativeView(selectedTab: .constant(1))
//    }
//}



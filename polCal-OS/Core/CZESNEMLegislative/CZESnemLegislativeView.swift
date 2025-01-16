//
//  CZESnemLegislativeView.swift
//  polCal-v2
//
//  Created by Lukas on 13/01/2025.
//

import SwiftUI

struct CZESnemLegislativeView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Binding var selectedTab: Int
    @State private var sortOrder: [SortDescriptor<SVKVoteModel>] = [SortDescriptor(\SVKVoteModel.id)]
    @Binding var path: NavigationPath
    @Binding var legislativeViewType: LegislativeViewType
    
    @State private var userVotes: [SVKVote] = []
    
    // var parliaments = ["2020","2023", "current"]
    @State var selectedParlSetup: String = "current"
    
    
    var body: some View {
        NavigationStack {
            CZESnemLegModelView(sortOrder: sortOrder)
                .onAppear {
                    loadUserVotesList()
                }
                .navigationTitle("Browse CZE votes")
                .toolbar {
                    if selectedTab == 1 {
                        Menu {
                            Button(action: {
                                legislativeViewType = .svk // Switch to Slovakia
                            }) {
                                Label("🇸🇰 Slovakia", systemImage: legislativeViewType == .svk ? "checkmark" : "")
                            }
                            Button(action: {
                                legislativeViewType = .czesnem // Switch to Czechia
                            }) {
                                Label("🇨🇿 Czechia", systemImage: legislativeViewType == .czesnem ? "checkmark" : "")
                            }
                        } label: {
                            Label("Countries", systemImage: "globe.europe.africa")
                        }
                        
                        if !userVotes.isEmpty {
                            Menu {
                                ForEach(userVotes, id: \.id) { vote in
                                    Button(vote.id) {
                                        loadUserVoteModel(vote)
                                    }
                                }
                            } label: {
                                Label("Saved Votes", systemImage: "archivebox")
                            }
                        }
                        Button(action: addVote) {
                            Label("Add Vote", systemImage: "plus")
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
                .navigationDestination(for: SVKVoteModel.self) { vote in
                    VoteReportView(path: $path, vote: vote)
                }
        }
    }
    
    func loadUserVoteModel(_ vote: SVKVote) {
        do {
            // Check if scenario with the same id already exists in the model context
            let existingVotes = try modelContext.fetch(SVKVoteModel.fetchRequest())
            if existingVotes.contains(where: { $0.id == vote.id }) {
                // Scenario is already in model context
                print("Scenario with id \(vote.id) already exists in model context.")
                return
            } else {
                // Convert Scenario to ScenarioModel
                let voteModel = voteToVoteModel(vote)
                // Insert into modelContext
                modelContext.insert(voteModel)
                print("Inserted vote with id \(vote.id) into model context.")
            }
        } catch {
            print("Error loading user vote: \(error)")
        }
    }
    
    func addVote() {
        do {
            let existingVotes = try modelContext.fetch(SVKVoteModel.fetchRequest())
            
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
            let newMPs = SVKcurrentMPs.map { oldMP -> SVKMPModel in
                // Create a new MP instance with the same properties
                let newMP = SVKMPModel(name: oldMP.name)
                newMP.legParty = oldMP.legParty
                // Set other properties if needed
                return newMP
            }
            
            // Create the new vote with the new MP instances
            let vote = SVKVoteModel(
                id: newID,
                mps: newMPs,
                typevote: SVKTypeVote.standard
            )
            
            // Insert the new vote into the model context
            modelContext.insert(vote)
            
        } catch {
            print("Failed to fetch existing votes: \(error.localizedDescription)")
        }
    }
    
    func loadUserVotesList() {
        if let votes = loadUserVotes() {
            userVotes = votes
        } else {
            userVotes = []
        }
    }
    
    func voteToVoteModel(_ vote: SVKVote) -> SVKVoteModel {
        // Create a mapping from legParty IDs to legPartyModel instances to avoid duplicates
        var legPartyModelsById = [Int: SVKlegPartyModel]()
        
        // Create an array to hold MPModel instances
        var mpModels = [SVKMPModel]()
        
        // Iterate over each MP in the vote
        for mp in vote.mps {
            // Initialize legPartyModelInstance as nil
            var legPartyModelInstance: SVKlegPartyModel? = nil
            
            // Check if the MP has a legParty
            if let legParty = mp.legParty {
                // Check if we've already created a legPartyModel for this party
                if let existingLegPartyModel = legPartyModelsById[legParty.id] {
                    // Use the existing legPartyModel
                    legPartyModelInstance = existingLegPartyModel
                } else {
                    // Create a new legPartyModel
                    let newLegPartyModel = SVKlegPartyModel(id: legParty.id, name: legParty.name)
                    legPartyModelsById[legParty.id] = newLegPartyModel
                    legPartyModelInstance = newLegPartyModel
                }
            }
            
            // Create a new MPModel
            let mpModel = SVKMPModel(name: mp.name, legParty: legPartyModelInstance)
            mpModel.vote = mp.vote  // Set the MP's vote
            
            // Append the MPModel to the array
            mpModels.append(mpModel)
        }
        
        // Create a new VoteModel with the converted MPs
        let voteModel = SVKVoteModel(id: vote.id, mps: mpModels, typevote: vote.typevote)
        
        return voteModel
    }
    
    //    func legPartyModelToLegParty(_ model: legPartyModel) -> legParty {
    //        return legParty(id: model.id, name: model.name)
    //    }
    //
    //    func mpModelToMP(_ mpModel: MPModel) -> MP {
    //        let legParty = mpModel.legParty != nil ? legPartyModelToLegParty(mpModel.legParty!) : nil
    //        return MP(name: mpModel.name, legParty: legParty, vote: mpModel.vote)
    //    }
    //
    //    // Helper function to convert VoteModel to Vote
    //    func voteModelToVote(_ model: VoteModel) -> Vote {
    //        // Map the MPs from VoteModel to MP structs
    //        let mps = model.mps.map { mpModelToMP($0) }
    //
    //        let vote = Vote(
    //            id: model.id,
    //            mps: mps,
    //            typevote: model.typevote
    //        )
    //
    //        return vote
    //    }
    
    func deleteAllVotes() {
        do {
            let allVotes = try modelContext.fetch(SVKVoteModel.fetchRequest())
            for vote in allVotes {
                modelContext.delete(vote)
            }
        } catch {
            print("Failed to delete all votes: \(error.localizedDescription)")
        }
    }
}

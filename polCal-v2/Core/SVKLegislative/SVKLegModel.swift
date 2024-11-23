//
//  LegModel.swift
//  polCal-v2
//
//  Created by Lukas on 24/10/2024.
//

import Foundation
import SwiftData

// Define the voting choices as a Codable enum for persistence
enum SVKVotingChoice: String, Codable, CaseIterable, Identifiable {
    case forVote = "For"
    case against = "Against"
    case didNotVote = "Did Not Vote"
    case refusedToVote = "Refused To Vote"
    case notPresent = "Not Present"
    
    var id: String { self.rawValue }
}

enum SVKPartyVotingChoice: String, Codable, CaseIterable, Identifiable {
    
    case mixed = "Mixed"
    case forVote = "For"
    case against = "Against"
    case didNotVote = "Did Not Vote"
    case refusedToVote = "Refused To Vote"
    case notPresent = "Not Present"
    
    var id: String { self.rawValue }
}

enum SVKTypeVote: String, Codable, CaseIterable, Identifiable {
    
    case standard = "standard"
    case veto = "veto"
    case constitutional = "constitutional"
    
    var id: String { self.rawValue }
}

struct SVKVote: Codable, Equatable {
    var id: String
    var mps: [SVKMP]
    var typevote: SVKTypeVote
}

struct SVKMP: Codable, Equatable {
    var name: String
    var legParty: SVKlegParty?
    var vote: SVKVotingChoice
}

struct SVKlegParty: Codable, Equatable {
    var id: Int
    var name: String
}

@Model
class SVKMPModel: ObservableObject, Identifiable {
    var name: String
    var legParty: SVKlegPartyModel?
    var vote: SVKVotingChoice

    init(name: String, legParty: SVKlegPartyModel? = nil) {
        self.name = name
        self.legParty = legParty
        self.vote = .notPresent // Default state
        legParty?.members.append(self)
    }
}

@Model
class SVKlegPartyModel: ObservableObject {
    var id: Int
    var name: String
    var members: [SVKMPModel]

    init(id:Int, name: String, members: [SVKMPModel] = []) {
        self.id = id
        self.name = name
        self.members = members
        // Set the party reference for each member
        for member in members {
            member.legParty = self
        }
    }
}

@Model
final class SVKVoteModel: ObservableObject, Identifiable{
    var id: String
    
    @Relationship(deleteRule: .cascade)
    var mps: [SVKMPModel]
    var typevote: SVKTypeVote

    init(id: String, mps: [SVKMPModel], typevote: SVKTypeVote) {
        self.id = id
        self.mps = mps
        self.typevote = typevote
    }

    // Update the voting choice for a specific MP
    func setVote(for mp: SVKMPModel, choice: SVKVotingChoice) {
        if let index = mps.firstIndex(where: { $0.name == mp.name }) {
            mps[index].vote = choice
        }
    }

    // Update the voting choice for all MPs in a party
    func setVote(for legParty: SVKlegPartyModel, choice: SVKVotingChoice) {
        for mp in mps where mp.legParty?.name == legParty.name {
            mp.vote = choice
        }
    }

    // Determine if the vote has passed
    func didPass() -> Bool {
        // Exclude MPs who are not present
        let presentMPs = mps.filter { $0.vote != .notPresent }
        let totalPresent = presentMPs.count
        let forVotes = presentMPs.filter { $0.vote == .forVote }.count

        if self.typevote == .standard {
            if totalPresent >= 39 {
                return forVotes > totalPresent / 2
            } else {
                return false
            }
        } else if self.typevote == .veto {
            return forVotes >= 76
        } else {
            return forVotes >= 90
        }
    }
}

extension SVKVoteModel {
    static func fetchRequest() -> FetchDescriptor<SVKVoteModel> {
        FetchDescriptor<SVKVoteModel>()
    }
}

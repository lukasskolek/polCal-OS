//
//  LegModel.swift
//  polCal-v2
//
//  Created by Lukas on 24/10/2024.
//

import Foundation
import SwiftData

// Define the voting choices as a Codable enum for persistence
enum VotingChoice: String, Codable, CaseIterable, Identifiable {
    case forVote = "For"
    case against = "Against"
    case didNotVote = "Did Not Vote"
    case refusedToVote = "Refused To Vote"
    case notPresent = "Not Present"
    
    var id: String { self.rawValue }
}

enum PartyVotingChoice: String, Codable, CaseIterable, Identifiable {
    
    case mixed = "Mixed"
    case forVote = "For"
    case against = "Against"
    case didNotVote = "Did Not Vote"
    case refusedToVote = "Refused To Vote"
    case notPresent = "Not Present"
    
    var id: String { self.rawValue }
}

enum TypeVote: String, Codable, CaseIterable, Identifiable {
    
    case standard = "standard"
    case veto = "veto"
    case constitutional = "constitutional"
    
    var id: String { self.rawValue }
}

@Model
class MP: ObservableObject, Identifiable {
    var name: String
    var legParty: legParty?
    var vote: VotingChoice

    init(name: String, legParty: legParty? = nil) {
        self.name = name
        self.legParty = legParty
        self.vote = .notPresent // Default state
        legParty?.members.append(self)
    }
}

@Model
class legParty: ObservableObject {
    var id: Int
    var name: String
    var members: [MP]

    init(id:Int, name: String, members: [MP] = []) {
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
final class Vote: Identifiable{
    var id: String
    var mps: [MP]
    var typevote: TypeVote

    init(id: String, mps: [MP], typevote: TypeVote) {
        self.id = id
        self.mps = mps
        self.typevote = typevote
    }

    // Update the voting choice for a specific MP
    func setVote(for mp: MP, choice: VotingChoice) {
        if let index = mps.firstIndex(where: { $0.name == mp.name }) {
            mps[index].vote = choice
        }
    }

    // Update the voting choice for all MPs in a party
    func setVote(for legParty: legParty, choice: VotingChoice) {
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

extension Vote {
    static func fetchRequest() -> FetchDescriptor<Vote> {
        FetchDescriptor<Vote>()
    }
}

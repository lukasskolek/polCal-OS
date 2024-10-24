//
//  LegModel.swift
//  polCal-v2
//
//  Created by Lukas on 24/10/2024.
//

import Foundation
import SwiftData

// Define the voting choices as a Codable enum for persistence
enum VotingChoice: String, Codable {
    case forVote = "For"
    case against = "Against"
    case didNotVote = "Did Not Vote"
    case refusedToVote = "Refused To Vote"
    case notPresent = "Not Present"
}

@Model
class MP {
    var name: String
    var legParty: legParty?
    var vote: VotingChoice

    init(name: String, legParty: legParty? = nil) {
        self.name = name
        self.legParty = legParty
        self.vote = .notPresent // Default state
    }
}

@Model
class legParty {
    var name: String
    var members: [MP]

    init(name: String, members: [MP] = []) {
        self.name = name
        self.members = members
        // Set the party reference for each member
        for member in members {
            member.legParty = self
        }
    }
}

@Model
class Vote {
    var mps: [MP]

    init(mps: [MP]) {
        self.mps = mps
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

        // Check if 'For' votes are more than half of present MPs
        return forVotes > totalPresent / 2
    }
}

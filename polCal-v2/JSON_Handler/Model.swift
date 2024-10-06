//
//  Model.swift
//  polCal
//
//  Created by Lukas on 29/08/2024.
//

import SwiftUI
import SwiftData
import Foundation

struct Scenario: Codable {
    var id: String
    var turnoutTotal: Double
    var turnoutIncorrect: Double
    
    var turnoutDistributed: Double
    var turnoutLeftToBeDistributed: Double
    
    var populus: Int
    
    var republikoveCislo: Int
    var populusGotIn: Int
    var populusInvalidNotTurnedIn: Int
    var populusAttended: Int
    var parties: [Party]?
}

enum CoalitionStatus: String, CaseIterable, Identifiable, Codable {
    case alone = "Alone"
    case smallCoal = "Small Coalition"
    case bigCoal = "Big Coalition"
    
    var id: String { self.rawValue }
}

struct Party: Codable, Equatable {
    var name: String
    var votes: Double
    var coalitionStatus: CoalitionStatus
    
    var gotIn: Bool {
        switch coalitionStatus {
        case .alone:
            return votes >= 5.0
        case .smallCoal:
            return votes >= 7.0
        case .bigCoal:
            return votes >= 10.0
        }
    }
    
    var mandaty: Int
    var zostatok: Int
    
    var inGovernment: Bool
    
    
    var red: Double
    var blue: Double
    var green: Double
    var opacity: Double
    var color: Color {
            get { Color(red: red, green: green, blue: blue, opacity: opacity) }
            set {
                if let components = newValue.cgColor?.components {
                    red = components[0]
                    green = components[1]
                    blue = components[2]
                    opacity = components[3]
                }
            }
        }
}

@Model
class ScenarioModel {
    var id: String
    var turnoutTotal: Double
    
    //toto treba este poriesit do podrobna, lebo nie je jasne ci sa jedna o percento zo vsetkych volicov alebo o percento v ramci volieb
    var turnoutIncorrect: Double
    
    var turnoutDistributed: Double {
        // Sum the votes of the parties, then add turnoutIncorrect once
        let totalVotes = parties?.reduce(0) { $0 + $1.votes } ?? 0.0
        return totalVotes + turnoutIncorrect
    }
    
    
    var turnoutLeftToBeDistributed: Double {
        return 100 - turnoutDistributed
    }
    // Computed property for gotInTurnout
    var gotInTurnout: Double {
        return parties?.filter { $0.gotIn }  // Only count the parties that "got in"
            .reduce(0) { $0 + $1.votes } ?? 0.0 // Sum the votes of the parties that "got in", return 0.0 if parties is nil
    }
    
    var populus: Int
    
    var republikoveCislo: Int {
        return populusGotIn / 151
    }
    
    var populusGotIn: Int {
        return Int((Double(populus) * (turnoutTotal/100)) * (gotInTurnout/100))
    }
    var populusInvalidNotTurnedIn: Int {
        return Int(((Double(populus) * (turnoutTotal/100)) * (turnoutIncorrect/100)))
    }
                   
    var populusAttended: Int {
        return Int(Double(populus) * (turnoutTotal/100))
    }
    
    @Relationship(deleteRule: .cascade)
    var parties: [Party]?
    
    init(id: String, turnoutTotal: Double, turnoutIncorrect: Double, turnoutDistributed: Double, turnoutLeftToBeDistributed: Double, populus: Int, republikoveCislo: Int, populusGotIn: Int, populusInvalidNotTurnedIn: Int, populusAttended: Int, parties: [Party]? = nil) {
        self.id = id
        self.turnoutTotal = turnoutTotal
        self.turnoutIncorrect = turnoutIncorrect
        self.populus = populus
        self.parties = parties
    }
    
}

extension ScenarioModel {
    static func fetchRequest() -> FetchDescriptor<ScenarioModel> {
        // Create a basic fetch descriptor to retrieve all ScenarioModel instances
        return FetchDescriptor<ScenarioModel>(
            sortBy: [SortDescriptor(\ScenarioModel.id)]
        )
    }
    
    func calculateMandates() {
        guard var parties = parties else {
            print("No parties available")
            return
        }

        // Check if turnoutTotal is greater than 0.00
        if self.turnoutTotal <= 0.00 {
            // Set mandaty and zostatok of all parties to 0
            for index in parties.indices {
                parties[index].mandaty = 0
                parties[index].zostatok = 0
            }
            self.parties = parties
            return
        }

        // Step 1: Filter parties that got in
        let partiesGotInIndices = parties.indices.filter { parties[$0].gotIn }
        
        // Handle special case: if only one party got in
        if partiesGotInIndices.count == 1 {
            // If only one party got in, assign all 150 mandates to it
            for index in parties.indices {
                parties[index].mandaty = parties[index].gotIn ? 150 : 0
                parties[index].zostatok = 0
            }
            self.parties = parties
            return
        }

        // Step 2: Calculate total votes and republikoveCislo (quota)
        let totalAbsoluteVotesGotIn = partiesGotInIndices.reduce(0.0) { total, index in
            total + Double(populus) * (turnoutTotal / 100) * (parties[index].votes / 100.0)
        }
        let republikoveCislo = totalAbsoluteVotesGotIn / 150.0

        // Handle edge case when republikoveCislo is zero
        if republikoveCislo == 0 {
            print("RepublikoveCislo is zero")
            for index in parties.indices {
                parties[index].mandaty = 0
                parties[index].zostatok = 0
            }
            self.parties = parties
            return
        }

        // Step 3: Calculate initial mandates and remainders
                var totalMandaty = 0
                for index in parties.indices {
                    if parties[index].gotIn {
                        let absoluteVotes = Double(populus) * (turnoutTotal / 100) * (parties[index].votes / 100.0)
                        let exactMandates = Int(absoluteVotes / republikoveCislo)
                        parties[index].mandaty = Int(exactMandates)
                        parties[index].zostatok = exactMandates - parties[index].mandaty
                        totalMandaty += parties[index].mandaty
                    } else {
                        parties[index].mandaty = 0
                        parties[index].zostatok = 0
                    }
                }

        // Step 4: Allocate remaining mandates based on remainders
        let remainingMandates = 150 - totalMandaty

        if remainingMandates > 0 {
            // Get parties with their indices and remainders
            let partiesWithRemainders = parties.enumerated().filter { $0.element.gotIn }
            
            // Sort parties by their remainders in descending order
            let sortedParties = partiesWithRemainders.sorted {
                $0.element.zostatok > $1.element.zostatok
            }
            
            // Allocate remaining mandates
            for i in 0..<remainingMandates {
                let partyIndex = sortedParties[i % sortedParties.count].offset
                parties[partyIndex].mandaty += 1
            }
        }

        // Step 5: Update the parties
        self.parties = parties
    }
}



import SwiftUI
import SwiftData
import Foundation

// MARK: - Data Structures

struct Scenario: Codable, Equatable {
    var id: String
    var turnoutTotal: Double
    var turnoutIncorrect: Double
    var populus: Int
    var parties: [Party]?
}

struct Party: Codable, Equatable {
    var name: String
    var votes: Double
    var coalitionStatus: CoalitionStatus
    var mandaty: Int
    var zostatok: Int
    var inGovernment: Bool
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
}

enum CoalitionStatus: String, CaseIterable, Identifiable, Codable {
    case alone = "Alone"
    case smallCoal = "Small Coalition"
    case bigCoal = "Big Coalition"
    
    var id: String { self.rawValue }
}

// MARK: - PartyModel Class

@Model
final class PartyModel: Identifiable {
    var id: UUID
    var name: String
    var votes: Double
    var coalitionStatus: CoalitionStatus
    var mandaty: Int
    var zostatok: Int
    var inGovernment: Bool
    var red: Double
    var blue: Double
    var green: Double
    var opacity: Double

    // Computed property for color
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }

    // Computed property for gotIn
    var gotIn: Bool {
        let threshold: Double
        switch coalitionStatus {
        case .alone:
            threshold = 5.0
        case .smallCoal:
            threshold = 7.0
        case .bigCoal:
            threshold = 10.0
        }
        return votes >= threshold
    }

    init(id: UUID = UUID(), name: String, votes: Double, coalitionStatus: CoalitionStatus, mandaty: Int = 0, zostatok: Int = 0, inGovernment: Bool, red: Double, blue: Double, green: Double, opacity: Double) {
        self.id = id
        self.name = name
        self.votes = votes
        self.coalitionStatus = coalitionStatus
        self.mandaty = mandaty
        self.zostatok = zostatok
        self.inGovernment = inGovernment
        self.red = red
        self.blue = blue
        self.green = green
        self.opacity = opacity
    }
}

// MARK: - ScenarioModel Class

@Model
final class ScenarioModel: Identifiable {
    var id: String
    var turnoutTotal: Double
    var turnoutIncorrect: Double
    var populus: Int

    @Relationship(deleteRule: .cascade)
    var parties: [PartyModel]?

    // Computed properties
    var turnoutDistributed: Double {
        let totalVotes = parties?.reduce(0) { $0 + $1.votes } ?? 0.0
        return totalVotes + turnoutIncorrect
    }

    var turnoutLeftToBeDistributed: Double {
        return 100 - turnoutDistributed
    }

    var gotInTurnout: Double {
        return parties?.filter { $0.gotIn }
            .reduce(0) { $0 + $1.votes } ?? 0.0
    }

    var populusGotIn: Int {
        guard let parties = parties else {
            return 0
        }
        let partiesGotIn = parties.filter { $0.gotIn }
        if partiesGotIn.isEmpty {
            return 0
        }

        // Compute adjusted population (number of valid votes)
        let turnoutFraction = turnoutTotal / 100.0
        let validVoteFraction = 1 - (turnoutIncorrect / 100.0)
        let adjustedPopulation = Double(populus) * turnoutFraction * validVoteFraction

        // Compute total votes for parties that got in
        let totalVotesGotIn = partiesGotIn.reduce(0.0) { total, party in
            let partyVoteFraction = party.votes / 100.0
            let partyVotesAbsolute = adjustedPopulation * partyVoteFraction
            return total + partyVotesAbsolute
        }

        return Int(totalVotesGotIn)
    }

    var populusInvalidNotTurnedIn: Int {
        return Int((Double(populus) * (turnoutTotal / 100.0)) * (turnoutIncorrect / 100.0))
    }

    var populusAttended: Int {
        return Int(Double(populus) * (turnoutTotal / 100.0))
    }
    
    // Computed property for republikoveCislo (Electoral Quota)
    var republikoveCislo: Int {
        guard let parties = parties else {
            return 0
        }
        let partiesGotIn = parties.filter { $0.gotIn }
        if partiesGotIn.isEmpty {
            return 0
        }

        
        let electoralQuota = Int(Double(populusGotIn) / 150.0)
        return electoralQuota
    }

    init(id: String, turnoutTotal: Double, turnoutIncorrect: Double, populus: Int, parties: [PartyModel]? = nil) {
        self.id = id
        self.turnoutTotal = turnoutTotal
        self.turnoutIncorrect = turnoutIncorrect
        self.populus = populus
        self.parties = parties
    }
}

// MARK: - ScenarioModel Extension

extension ScenarioModel {
    static func fetchRequest(predicate: Predicate<ScenarioModel>? = nil, sortDescriptors: [SortDescriptor<ScenarioModel>] = []) -> FetchDescriptor<ScenarioModel> {
        FetchDescriptor<ScenarioModel>(predicate: predicate, sortBy: sortDescriptors)
    }

    func calculateMandates() {
        guard let parties = parties else {
            print("No parties available")
            return
        }

//         Reset mandates and residuals
        for index in parties.indices {
            parties[index].mandaty = 0
            parties[index].zostatok = 0
        }

        if self.turnoutTotal <= 0.0 {
            print("Turnout is zero or negative")
            self.parties = parties
            return
        }

        // Step 1: Filter parties that got in
        let partiesGotInIndices = parties.indices.filter { parties[$0].gotIn }

        if partiesGotInIndices.isEmpty {
            print("No parties passed the threshold")
            self.parties = parties
            return
        }

        if partiesGotInIndices.count == 1 {
            // If only one party got in, it gets all the seats
            for index in parties.indices {
                if parties[index].gotIn {
                    parties[index].mandaty = 150
                } else {
                    parties[index].mandaty = 0
                }
                parties[index].zostatok = 0
            }
            self.parties = parties
            return
        }

        // Step 2: Calculate electoral quota (republikoveCislo)
        let electoralQuota = self.republikoveCislo

        // Handle edge case when electoralQuota is zero
        if electoralQuota <= 0 {
            print("Electoral quota is zero")
            self.parties = parties
            return
        }

        // Step 3: Calculate initial mandates and remainders
        var totalMandatesAssigned = 0
        for index in parties.indices {
            if parties[index].gotIn {
                let partyVotesAbsolute = Double(populus) * ((turnoutTotal / 100.0) * (1-(turnoutIncorrect/100))) * (parties[index].votes / 100.0)
                let exactMandates = partyVotesAbsolute / Double(electoralQuota)
                let initialMandates = Int(exactMandates)
                let residual = Int(partyVotesAbsolute) % Int(electoralQuota)
                parties[index].mandaty = initialMandates
                parties[index].zostatok = residual
                totalMandatesAssigned += initialMandates
            } else {
                parties[index].mandaty = 0
                parties[index].zostatok = 0
            }
        }

        // Step 4: Allocate remaining mandates based on remainders
        let remainingMandates = 150 - totalMandatesAssigned

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

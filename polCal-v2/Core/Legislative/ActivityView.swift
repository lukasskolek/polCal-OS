import SwiftUI

struct ActivityView: View {
    
    var vote: VoteModel

    var body: some View {
        VStack(spacing: 20) {
            // ID & Type Section
            VStack(alignment: .leading, spacing: 5) {
                Text("ID & Type")
                    .font(.headline)
                Text("ID: \(vote.id)")
                Text("Type: \(vote.typevote.rawValue.capitalized)")
            }
            .padding()
            
            // Result Section
            VStack(alignment: .leading, spacing: 5) {
                Text("Result")
                    .font(.headline)
                HStack {
                    if vote.didPass() {
                        Text("PASSED")
                            .fontWeight(.bold)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Text("DID NOT PASS")
                            .fontWeight(.bold)
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                HStack {
                    Text("Required to pass: \(votesNeeded())")
                    Spacer()
                    Text("For votes: \(forVotes())")
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Present: \(presentVotes())")
                    Spacer()
                    Text("Against votes: \(againstVotes())")
                        .fontWeight(.semibold)
                }
            }
            .padding()
            
            // Voting Summary Section
            VStack(alignment: .leading, spacing: 5) {
                Text("Voting Summary")
                    .font(.headline)
                VotingSummaryView(vote: vote)
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
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

    func votingSummaryView() -> some View {
        // Group MPs by their legParty
        let parties = Dictionary(grouping: vote.mps) { $0.legParty }
        // Sort parties by ID
        let sortedParties = parties.keys.compactMap { $0 }.sorted(by: { $0.id < $1.id })

        return VStack(alignment: .leading, spacing: 5) {
            ForEach(sortedParties, id: \.id) { legParty in
                let partyName = legParty.name
                let mps = parties[legParty] ?? []
                HStack {
                    Text(partyName)
                        .font(.subheadline)
                    Spacer()
                    Text("\(mps.filter { $0.vote == .forVote }.count) / \(mps.count)")
                        .font(.subheadline)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

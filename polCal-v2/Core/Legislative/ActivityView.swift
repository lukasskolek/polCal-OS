import SwiftUI

struct ActivityView: View {
    
    @State var vote: VoteModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("FML why is this so shitty.")
                .foregroundStyle(.black)
            
            // Voting Summary Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Voting Summary")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)
                
                VotingSummaryView(vote: vote)
                    .padding(.top, 5)
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(10)
            
        }
        .background(Color(.white))
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
}

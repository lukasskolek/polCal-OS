//
//  SubViews.swift
//  polCal-v2
//
//  Created by Lukas on 18/11/2024.
//

import SwiftUI
import Charts

struct MPRowView: View {
    @ObservedObject var mp: SVKMPModel

    var body: some View {
        HStack {
            Text(mp.name)
            Spacer()
            Picker("", selection: $mp.vote) {
                ForEach(SVKVotingChoice.allCases) { choice in
                    Text(choice.rawValue).tag(choice)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
        }
    }
}

struct PartyVotesRow: View {
    var legParty: SVKlegPartyModel?
    var mps: [SVKMPModel]

    var body: some View {
        let partyName = legParty?.name ?? "Independent"
        let forVotesCount = mps.filter { $0.vote == .forVote }.count
        let agaVotesCount = mps.filter { $0.vote == .against }.count
        let dnvVotesCount = mps.filter { $0.vote == .didNotVote }.count
        let npVotesCount = mps.filter { $0.vote == .notPresent }.count
        let rfVotesCount = mps.filter { $0.vote == .refusedToVote }.count

        HStack(spacing: 1) {
            Text(partyName)
                .font(.system(size: 6, weight: .bold))
                .lineLimit(1)
                .padding(.trailing, 4)
            Text("\(mps.count)")
                .font(.system(size: 6))
                .foregroundStyle(.gray)
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 6, height: 6)
                .foregroundStyle(.gray)
            
            Spacer()

            HStack(spacing: 5) {
                CountText(count: forVotesCount, color: .green)
                CountText(count: agaVotesCount, color: .red)
                CountText(count: dnvVotesCount, color: .mint, opacity: 0.75)
                CountText(count: npVotesCount, color: .purple, opacity: 0.75)
                CountText(count: rfVotesCount, color: .cyan, opacity: 0.75)
            }
        }
    }
}

struct CountText: View {
    var count: Int
    var color: Color
    var opacity: Double = 1.0

    var body: some View {
        Text("\(count)")
            .font(.system(size: 6, weight: .bold))
            .foregroundStyle(color)
            .opacity(opacity)
    }
}

struct LegendRow: View {
    var color: Color
    var label: String
    var opacity: Double = 1.0

    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(color)
                .opacity(opacity)
                .frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: 5))
        }
    }
}

struct VotingSummaryLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            LegendRow(color: .green, label: "For")
            LegendRow(color: .red, label: "Against")
            LegendRow(color: .mint, label: "Did not vote", opacity: 0.75)
            LegendRow(color: .purple, label: "Not present", opacity: 0.75)
            LegendRow(color: .cyan, label: "Refused to vote", opacity: 0.75)
        }
        .padding(1)
    }
}

struct VoteBarChartView: View {
    var vote: SVKVoteModel

    var body: some View {
        Chart {
            // Single BarMark for each voting type, showing aggregated count across all parties

            BarMark(x: .value("Vote Type", "For"), y: .value("Count", forVotesCount()))
                .foregroundStyle(.green)
                .annotation(position: .bottom) { Text("\(forVotesCount())")
                        .foregroundStyle(.green)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Against"), y: .value("Count", againstVotesCount()))
                .foregroundStyle(.red)
                .annotation(position: .bottom) { Text("\(againstVotesCount())")
                        .foregroundStyle(.red)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Did Not Vote"), y: .value("Count", didNotVoteCount()))
                .foregroundStyle(.mint)
                .opacity(0.75)
                .annotation(position: .bottom) { Text("\(didNotVoteCount())")
                        .foregroundStyle(.mint)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Not Present"), y: .value("Count", notPresentCount()))
                .foregroundStyle(.purple)
                .opacity(0.75)
                .annotation(position: .bottom) { Text("\(notPresentCount())")
                        .foregroundStyle(.purple)
                        .font(.system(size: 4))
                }
            
            BarMark(x: .value("Vote Type", "Refused to Vote"), y: .value("Count", refusedToVoteCount()))
                .foregroundStyle(.cyan)
                .opacity(0.75)
                .annotation(position: .bottom) { Text("\(refusedToVoteCount())")
                        .foregroundStyle(.cyan)
                        .font(.system(size: 4))
                }
        }
        .frame(width: 60, height: 50, alignment: .trailing)
        .background(Color(.secondarySystemBackground))
        .chartXAxis(.hidden) // Hide x-axis
        .chartYAxis(.hidden)
    }
    
    // Helper functions to count each type of vote
    private func forVotesCount() -> Int {
        vote.mps.filter { $0.vote == .forVote }.count
    }
    
    private func againstVotesCount() -> Int {
        vote.mps.filter { $0.vote == .against }.count
    }
    
    private func didNotVoteCount() -> Int {
        vote.mps.filter { $0.vote == .didNotVote }.count
    }
    
    private func notPresentCount() -> Int {
        vote.mps.filter { $0.vote == .notPresent }.count
    }
    
    private func refusedToVoteCount() -> Int {
        vote.mps.filter { $0.vote == .refusedToVote }.count
    }
}

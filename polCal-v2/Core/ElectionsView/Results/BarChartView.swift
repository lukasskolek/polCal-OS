import SwiftUI
import Charts

struct BarChartView: View {
    @Bindable var scenarioModel: ScenarioModel  // Bindable ScenarioModel for dynamic updates
    @State private var selectedParty: PartyModel?
    @State private var selectedName: String?
    
    // To help determine whether the crown next to inGovernment parties is gold or gray
    var totalGovernmentMandates: Int {
        return scenarioModel.parties?.filter { $0.inGovernment }.reduce(0) { $0 + $1.mandaty } ?? 0
    }
    
    // To determine whether ruleMark at 7% is needed
    var hasSmallCoalition: Bool {
        return scenarioModel.parties?.contains { $0.coalitionStatus == .smallCoal } ?? false
    }
    
    // To determine whether ruleMark at 10% is needed
    var hasBigCoalition: Bool {
        return scenarioModel.parties?.contains { $0.coalitionStatus == .bigCoal } ?? false
    }
    
    var body: some View {
        VStack {
            Chart {
                // Sort parties by votes in descending order before rendering them
                ForEach(scenarioModel.parties?.sorted(by: { $0.votes > $1.votes }) ?? []) { party in
                    // Bar for Votes
                    BarMark(
                        x: .value("Party", party.name),
                        y: .value("Votes", party.votes)
                    )
                    .foregroundStyle(
                        selectedParty?.id == party.id ?
                        party.color :
                        party.color.opacity(0.5)
                    )
                }
                
                // Threshold Lines
                RuleMark(y: .value("Threshold", 5.0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.gray)
                    .zIndex(-1.0)
                    .annotation(position: .trailing) {
                        Text("5%")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                if hasSmallCoalition {
                    RuleMark(y: .value("Small Coalition Threshold", 7.0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color.gray)
                        .zIndex(-1.0)
                        .annotation(position: .trailing) {
                            Text("7%")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                }
                if hasBigCoalition {
                    RuleMark(y: .value("Big Coalition Threshold", 10.0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color.gray)
                        .zIndex(-1.0)
                        .annotation(position: .trailing) {
                            Text("10%")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                }
                
                // Highlight the selected bar (optional)
                if let selectedParty = selectedParty {
                    RuleMark(x: .value("Selected", selectedParty.name))
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .offset(yStart: -10)
                        .zIndex(-1.0)
                        .annotation(
                            position: .top, spacing: 0, overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled)
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                if selectedParty.inGovernment {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .foregroundStyle(totalGovernmentMandates > 75 ? .yellow : .gray)
                                        Text("\(selectedParty.name)")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                    }
                                } else {
                                    Text("\(selectedParty.name)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .opacity(selectedParty.gotIn ? 1 : 0.4)
                                }
                                Text("Votes: \(selectedParty.votes, specifier: "%.2f")%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .opacity(selectedParty.gotIn ? 1 : 0.4)
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .opacity(selectedParty.gotIn ? 1 : 0.4)
                                    Text("\(selectedParty.mandaty)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .opacity(selectedParty.gotIn ? 1 : 0.4)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.2)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(radius: 4)
                        }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 300)
            .chartXSelection(value: $selectedName)
            .onChange(of: selectedName) { oldValue, newValue in
                if let newValue {
                    getSelectedParty(name: newValue)
                } else {
                    selectedParty = nil
                }
            }
        }
    }
    
    private func getSelectedParty(name: String) {
        selectedParty = scenarioModel.parties?.first { $0.name == name }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock PartyModel data with more parties
        let mockParties = [
            PartyModel(
                name: "OLANO a priatelia",
                votes: 20.0,
                coalitionStatus: .alone,
                mandaty: 70,
                zostatok: 0,
                inGovernment: true,
                red: 0.567,
                blue: 0.024,
                green: 0.592,
                opacity: 1.0
            ),
            PartyModel(
                name: "Party D",
                votes: 7.0,
                coalitionStatus: .smallCoal,
                mandaty: 5,
                zostatok: 0,
                inGovernment: false,
                red: 0.567,
                blue: 0.24,
                green: 0.920,
                opacity: 1.0
            ),
            PartyModel(
                name: "Party B",
                votes: 3.0,
                coalitionStatus: .smallCoal,
                mandaty: 0,
                zostatok: 0,
                inGovernment: false,
                red: 0.567,
                blue: 0.24,
                green: 0.920,
                opacity: 1.0
            ),
            PartyModel(
                name: "Party C",
                votes: 8.0,
                coalitionStatus: .smallCoal,
                mandaty: 25,
                zostatok: 0,
                inGovernment: true,
                red: 0.17,
                blue: 0.024,
                green: 0.11,
                opacity: 1.0
            )
        ]
        
        let mockScenarioModel = ScenarioModel(
            id: "Scenario 1",
            turnoutTotal: 70.0,
            turnoutIncorrect: 1.2,
            populus: 4_388_872,
            parties: mockParties
        )
        
        // Calculate mandates if necessary
        mockScenarioModel.calculateMandates()
        
        return BarChartView(scenarioModel: mockScenarioModel)
            .frame(width: 400)
            .previewDisplayName("Votes & Mandates Bar Chart with Multiple Parties")
    }
}

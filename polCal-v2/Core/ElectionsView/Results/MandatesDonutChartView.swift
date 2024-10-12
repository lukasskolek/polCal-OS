import SwiftUI
import Charts

struct MandateDonutChartView: View {
    @Bindable var scenarioModel: ScenarioModel  // Bindable ScenarioModel for dynamic updates
    @State private var selectedCount: Int?
    @State private var selectedParty: PartyModel?

    var totalGovernmentMandates: Int {
        return scenarioModel.parties?.filter { $0.inGovernment }.reduce(0) { $0 + $1.mandaty } ?? 0
    }

    var body: some View {
        let parties = scenarioModel.parties?.sorted(by: { $0.mandaty > $1.mandaty }) ?? []
        let partiesWithMandates = parties.filter { $0.mandaty > 0 }

        VStack {
            if partiesWithMandates.count >= 2 {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(totalGovernmentMandates > 75 ? .yellow : .gray)
                    Text("Total coalition mandates: \(totalGovernmentMandates)")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background Bar
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 15)
                            .foregroundColor(Color.gray.opacity(0.3))

                        // Filled Bar
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: geometry.size.width * CGFloat(totalGovernmentMandates) / 150.0, height: 15)
                            .foregroundStyle(totalGovernmentMandates > 75 ? .yellow : .gray)
                            .animation(.easeInOut(duration: 0.5), value: totalGovernmentMandates)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
            }

            Chart {
                // Iterate over parties to create sectors
                ForEach(parties) { party in
                    SectorMark(
                        angle: .value("Mandaty", party.mandaty),
                        innerRadius: .ratio(0.618),
                        outerRadius: selectedParty?.id == party.id ? 160 : 130,
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(party.color)
                }
            }
            .onChange(of: selectedCount) { oldValue, newValue in
                if let newValue {
                    withAnimation {
                        getSelectedParty(value: newValue)
                    }
                }
            }
            .chartAngleSelection(value: $selectedCount)
            .chartBackground { _ in
                if let selectedParty {
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(selectedParty.color)
                            Text("\(selectedParty.name)")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                        if selectedParty.inGovernment {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(totalGovernmentMandates > 75 ? .yellow : .gray)
                                Text("\(selectedParty.mandaty)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                            }
                        } else {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("\(selectedParty.mandaty)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                } else {
                    Image(systemName: "hand.draw.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(width: 75, height: 75)
                        .symbolEffect(.pulse.byLayer, isActive: true)
                }
            }
            .frame(height: 300)
        }
        .onChange(of: scenarioModel.parties) { oldParties, newParties in
            if let selectedParty = selectedParty, let newParties = newParties {
                if !newParties.contains(where: { $0.id == selectedParty.id }) {
                    self.selectedParty = nil
                }
            } else {
                self.selectedParty = nil
            }
        }
        .onChange(of: selectedCount) { oldValue, newValue in
            if let newValue {
                withAnimation {
                    getSelectedParty(value: newValue)
                }
            }
        }
    }

    private func getSelectedParty(value: Int) {
        var cumulativeTotal = 0
        let parties = scenarioModel.parties?.sorted(by: { $0.mandaty > $1.mandaty }) ?? []
        for party in parties {
            cumulativeTotal += party.mandaty
            if value <= cumulativeTotal {
                selectedParty = party
                break
            }
        }
    }
}

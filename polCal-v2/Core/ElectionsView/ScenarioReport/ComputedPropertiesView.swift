import SwiftUI

struct ComputedPropertiesView: View {
    @Bindable var scenarioModel: ScenarioModel  // This allows SwiftUI to track changes in scenarioModel

    var body: some View {
        VStack(alignment: .leading) {
            // Turnout of qualified parties
            Text("Turnout of qualified parties: \(scenarioModel.gotInTurnout, format: .number.precision(.fractionLength(2)))%")
                .font(.caption)

            // Qualified votes already distributed
            HStack(spacing: 0) {
                Text("Qualified votes already distributed: ")
                    .font(.caption)
                Text("\(scenarioModel.turnoutDistributed, format: .number.precision(.fractionLength(2)))%")
                    .font(.caption)
                    .foregroundColor(scenarioModel.turnoutDistributed > 100.0 ? .red : .primary)
                    .fontWeight(scenarioModel.turnoutDistributed > 100.0 ? .bold : .regular)
            }

            // Qualified votes left to be distributed
            HStack(spacing: 0) {
                Text("Qualified votes left to be distributed: ")
                    .font(.caption)
                Text("\(scenarioModel.turnoutLeftToBeDistributed, format: .number.precision(.fractionLength(2)))%")
                    .font(.caption)
                    .foregroundColor(scenarioModel.turnoutLeftToBeDistributed < 0.0 ? .red : .primary)
                    .fontWeight(scenarioModel.turnoutLeftToBeDistributed < 0.0 ? .bold : .regular)
            }

            // Republic Vote Number
            Text("Republic Vote Number: \(Int(scenarioModel.republikoveCislo))")
                .font(.caption)

            // Voters of qualified parties
            Text("Voters of qualified parties: \(scenarioModel.populusGotIn)")
                .font(.caption)

            // Voters with uncast & incorrect votes
            Text("Voters with uncast & incorrect votes: \(scenarioModel.populusInvalidNotTurnedIn)")
                .font(.caption)

            // Voters who attended
            Text("Voters who attended: \(scenarioModel.populusAttended)")
                .font(.caption)
        }
    }
}

import SwiftUI

struct ComputedPropertiesView: View {
    @Bindable var scenarioModel: ScenarioModel  // This allows SwiftUI to track changes in scenarioModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("""
            Turnout of qualified parties: \(String(format: "%.2f", scenarioModel.gotInTurnout))% 
            Qualified votes already distributed: \(String(format: "%.2f", scenarioModel.turnoutDistributed))%
            Qualified votes left to be distributed: \(String(format: "%.2f", scenarioModel.turnoutLeftToBeDistributed))%
            Republic Vote Number: \(scenarioModel.republikoveCislo)
            Voters of qualified parties: \(scenarioModel.populusGotIn)
            Voters with uncast & incorrect votes: \(scenarioModel.populusInvalidNotTurnedIn)
            Voters who attended: \(scenarioModel.populusAttended)
            """)
            .font(.caption)
        }
    }
}

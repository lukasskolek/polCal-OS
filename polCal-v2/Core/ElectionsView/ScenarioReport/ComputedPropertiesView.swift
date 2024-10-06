import SwiftUI

struct ComputedPropertiesView: View {
    @Bindable var scenarioModel: ScenarioModel  // This allows SwiftUI to track changes in scenarioModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Turnout of qualified parties: \(scenarioModel.gotInTurnout, specifier: "%.2f")% \nQualified votes already distributed: \(scenarioModel.turnoutDistributed, specifier: "%.2f")%\nQualified votes left to be distributed: \(scenarioModel.turnoutLeftToBeDistributed, specifier: "%.2f")%\nRepublic Vote Number: \(scenarioModel.republikoveCislo)\nVoters of qualified parties: \(scenarioModel.populusGotIn)\nVoters with uncast & incorrect votes: \(scenarioModel.populusInvalidNotTurnedIn)\nVoters who attended: \(scenarioModel.populusAttended)")
                .font(.caption)
        }
    }
}

import SwiftUI

struct ResultsView: View {
    @Bindable var scenarioModel: ScenarioModel  // Bindable ScenarioModel for dynamic updates
    
    var body: some View {
        TabView {
            // First tab with BarChartView
            BarChartView(scenarioModel: scenarioModel)
                .tabItem {
                    Label("Votes", systemImage: "chart.bar")
                }
            
            // Second tab with MandateDonutChartView
            MandateDonutChartView(scenarioModel: scenarioModel)
                .tabItem {
                    Label("Mandates", systemImage: "chart.pie")
                }
            
            // Include the ParliamentView if desired
            /*
            ParliamentView(scenarioModel: scenarioModel)
                .padding(.bottom, 50)
                .padding(.horizontal, 20)
                .tabItem {
                    Label("Parliament", systemImage: "building.columns")
                }
            */
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .onAppear {
            // Ensure mandates are calculated when the view appears
            scenarioModel.calculateMandates()
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock PartyModel data
        let mockParties = [
            PartyModel(
                name: "Party A",
                votes: 20.0,
                coalitionStatus: .alone,
                mandaty: 0, // Initialize with 0 mandates
                zostatok: 0,
                inGovernment: false,
                red: 0.567,
                blue: 0.024,
                green: 0.592,
                opacity: 1.0
            ),
            PartyModel(
                name: "Party B",
                votes: 35.0,
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
                votes: 15.0,
                coalitionStatus: .bigCoal,
                mandaty: 0,
                zostatok: 0,
                inGovernment: false,
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
        
        // Calculate mandates
        mockScenarioModel.calculateMandates()
        
        return ResultsView(scenarioModel: mockScenarioModel)
    }
}

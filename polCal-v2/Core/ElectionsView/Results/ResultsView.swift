//
//  ResultsView.swift
//  polCal
//
//  Created by Lukas on 14/09/2024.
//

import SwiftUI

struct ResultsView: View {
    @Bindable var scenarioModel: ScenarioModel  // Bindable ScenarioModel for dynamic updates
    
    var body: some View {
        
        TabView {
            // First tab with BarChartView
            BarChartView(scenarioModel: scenarioModel)
            
            MandateDonutChartView(scenarioModel: scenarioModel)
////             Second tab with ParliamentView
//            ParliamentView(scenarioModel: scenarioModel)
//                .padding(.bottom, 50)
//                .padding(.horizontal, 20)
                
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Party data
        let mockParties = [
            Party(name: "Party A", votes: 20.0, coalitionStatus: .alone, mandaty: 50, zostatok: 0, inGovernment: false, red: 0.567, blue: 0.024, green: 0.592, opacity: 1.0),
            Party(name: "Party B", votes: 35.0, coalitionStatus: .smallCoal, mandaty: 70, zostatok: 0, inGovernment: false, red: 0.567, blue: 0.24, green: 0.920, opacity: 1.0),
            Party(name: "Party C", votes: 15.0, coalitionStatus: .bigCoal, mandaty: 30, zostatok: 0, inGovernment: false, red: 0.17, blue: 0.024, green: 0.11, opacity: 1.0)
        ]
        
        let mockScenarioModel = ScenarioModel(
            id: "Scenario 1",
            turnoutTotal: 70.0,
            turnoutIncorrect: 1.2,
            turnoutDistributed: 50.0,
            turnoutLeftToBeDistributed: 50.0,
            populus: 4388872,
            republikoveCislo: 150,
            populusGotIn: 3000000,
            populusInvalidNotTurnedIn: 100000,
            populusAttended: 4000000,
            parties: mockParties
        )
        
        return ResultsView(scenarioModel: mockScenarioModel)
    }
}

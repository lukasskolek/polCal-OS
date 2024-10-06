//
//  StackedBarChartView.swift
//  polCal
//
//  Created by Lukas on 31/08/2024.
//

//imported from an older project need to fix

//import SwiftUI
//import SwiftData
//
//struct StackedBarChart: View {
//    @Environment(\.modelContext) var modelContext
//    @EnvironmentObject var sliderHelper: SliderHelper
//    
//    var rawValue1: Double
//    var value1: Double {
//        min(rawValue1, 100) // Ensure value1 does not exceed 100
//    }
//    
//    //@EnvironmentObject var partyData: PartyData
//    @Query(sort: [
//        SortDescriptor(\Party.hlasyPercento, order: .reverse)]) var parties: [Party]
//    
//    var value2: Double {
//            let v2 = 100 - value1
//            sliderHelper.valForSlider = v2 // Update the sliderHelper value
//            return v2
//        }
//    let totalWidth: Double = 250
//
//    var body: some View {
//        
//        
//        HStack(spacing: 0) {
//            Rectangle()
//                .fill(parties.reduce(0) { total, party in
//                    total + party.hlasyPercento
//                } > 100 ? Color.gray : Color.blue)
//                .frame(width: calculateWidth(for: value1), height: 9)
//
//            Rectangle()
//                .fill(Color.gray.opacity(0.4))
//                .frame(width: calculateWidth(for: value2), height: 9)
//        }
//        .cornerRadius(4.5)
//        .frame(width: totalWidth, height: 20)
//        // Fixed total width for the bar
//    }
//
//    private func calculateWidth(for value: Double) -> CGFloat {
//        (CGFloat(value) / 100) * totalWidth
//    }
//}
//
//
//
//struct StackedBarChartView_Preview: PreviewProvider {
//    static var previews: some View {
//        StackedBarChart(rawValue1: 0)
//    }
//}

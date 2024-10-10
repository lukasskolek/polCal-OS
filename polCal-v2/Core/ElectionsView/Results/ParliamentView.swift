import SwiftUI

struct Dot: Identifiable {
    let id = UUID()
    let index: Int
    var color: Color
}

struct ParliamentView: View {
    @Bindable var scenarioModel: ScenarioModel  // Bindable ScenarioModel for dynamic updates
    @State var dots: [Dot] = []
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height
            let dotSize: CGFloat = 9.5
            let radiusStep = dotSize + 4.0
            
            ZStack {
                ForEach(dots) { dot in
                    let (x, y) = position(for: dot.index, centerX: centerX, centerY: centerY, radiusStep: radiusStep, dotSize: dotSize)
                    Circle()
                        .fill(dot.color)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(maxWidth: 160, minHeight: 160, alignment: .center)
        .onAppear {
            initializeDots()
        }
        .onChange(of: scenarioModel.parties) { _ in
            initializeDots()
        }
    }
    
    // Initialize dots and color them based on party mandates
    func initializeDots() {
        let rows = [14, 16, 19, 21, 24, 26, 30]
        var dotsArray: [Dot] = []
        
        // Create initial dots array
        for i in 0..<150 {
            dotsArray.append(Dot(index: i, color: .gray))
        }
        
        // Reorder dots for semicircular layout
        var reorderedDots: [Dot] = []
        for i in 0..<rows.max()! {
            for j in 0..<rows.count {
                let index = rows.prefix(j).reduce(0, +) + i
                if index < 150 && i < rows[j] {
                    reorderedDots.append(dotsArray[index])
                }
            }
        }
        
        dots = reorderedDots
        
        // Color dots according to party mandates
        var mandateIndex = 0
        for party in scenarioModel.parties ?? [] {
            for _ in 0..<party.mandaty {
                if mandateIndex < dots.count {
                    dots[mandateIndex].color = party.color
                    mandateIndex += 1
                }
            }
        }
    }
    
    // Position calculation for dots in semicircular layout
    func position(for index: Int, centerX: CGFloat, centerY: CGFloat, radiusStep: CGFloat, dotSize: CGFloat) -> (CGFloat, CGFloat) {
        let rows = [14, 16, 19, 21, 24, 26, 30]
        var cumulativeIndex = 0
        
        for (row, count) in rows.enumerated() {
            if index < cumulativeIndex + count {
                let angleStep = .pi / CGFloat(count - 1)
                let radius = radiusStep * CGFloat(row + 5)
                let angle = angleStep * CGFloat(index - cumulativeIndex) - .pi / 2
                
                // Apply 90 degrees counterclockwise rotation to the position
                let x = centerX - radius * sin(angle)
                let y = centerY - radius * cos(angle)
                
                return (x, y)
            }
            cumulativeIndex += count
        }
        
        return (centerX, centerY)
    }
}

struct ParliamentView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock PartyModel data
        let mockParties = [
            PartyModel(
                name: "Party A",
                votes: 20.0,
                coalitionStatus: .alone,
                mandaty: 50,
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
                mandaty: 70,
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
                mandaty: 30,
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
        // Calculate mandates if needed
        mockScenarioModel.calculateMandates()
        
        return ParliamentView(scenarioModel: mockScenarioModel)
            .frame(width: 400, height: 300)
            .previewDisplayName("Parliament View")
    }
}

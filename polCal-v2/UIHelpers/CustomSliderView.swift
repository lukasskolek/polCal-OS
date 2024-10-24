import SwiftUI

struct CustomSliderView: View {
    @Binding var percenta: Double // Slider's value should be a @State or a @Binding variable
    
    var range: ClosedRange<Double> = 0.0...100.0
    var step: Double = 0.01
    
    // Customization parameters
    var sliderTintColor: Color = .blue
    var buttonColor: Color = .blue
    var textColor: Color = .white
    var buttonSize: CGFloat = 44 // Added a fixed size for both buttons
    
    var body: some View {
        VStack(spacing: 10) { // Reduced spacing between elements

                Text("\(percenta, specifier: "%.2f")%")
                    .font(.system(size: 24, weight: .bold, design: .rounded)) // Custom font with rounded design
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.customRed, .customBlue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) // Gradient color
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 2, y: 2) // Subtle shadow for depth
                
                // Decrement button
//                Button(action: {
//                    decrementValue()
//                }) {
//                    Image(systemName: "minus")
//                        .font(.system(size: 20, weight: .bold)) // Consistent font size and weight
//                        .foregroundStyle(
//                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        ) // Gradient color
//                        .frame(width: buttonSize, height: buttonSize)
//                        .background(
//                            Circle()
//                                .fill(Color.white.opacity(0.99)) // Semi-transparent background for contrast
//                                .shadow(color: .gray.opacity(0.6), radius: 5, x: 3, y: 3) // Shadow to lift the button
//                        )
//                }
                
                // Slider
                    Slider(value: $percenta, in: range, step: step)
                        .accentColor(.customBlue)
                // Increment button
//                Button(action: {
//                    incrementValue()
//                }) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 20, weight: .bold)) // Consistent font size and weight
//                        .foregroundStyle(
//                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        ) // Gradient color
//                        .frame(width: buttonSize, height: buttonSize)
//                        .background(
//                            Circle()
//                                .fill(Color.white.opacity(0.99)) // Semi-transparent background for contrast
//                                .shadow(color: .gray.opacity(0.6), radius: 5, x: 3, y: 3) // Shadow to lift the button
//                        )
//                }
            }
            .padding(.horizontal) // Reduced padding to keep the text closer to the slider

    }
    
    // Functions to increment and decrement the value
    private func incrementValue() {
        if percenta < range.upperBound {
            percenta += step
            percenta = min(percenta, range.upperBound)
        }
    }
    
    private func decrementValue() {
        if percenta > range.lowerBound {
            percenta -= step
            percenta = max(percenta, range.lowerBound)
        }
    }
}

#Preview {
    CustomSliderView(percenta: .constant(40.0))
}

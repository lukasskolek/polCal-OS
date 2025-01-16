import SwiftUI

struct GoogleSignInSpecialButton: View {
    
    // A closure that defines the action to perform when the button is tapped
    var action: () -> Void
    
    // Detect the current color scheme (light or dark mode)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image("Google") // Make sure you have this image in your assets
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Sign in with Google")
                    .font(.custom("Roboto-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 31/255, green: 31/255, blue: 31/255))
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(colorScheme == .dark ? Color.gray : Color(red: 116/255, green: 119/255, blue: 117/255), lineWidth: 1)
            )
        }
    }
}

struct GoogleSignInSpecialButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GoogleSignInSpecialButton(action: {
                print("Google Sign-In button tapped")
            })
            .previewLayout(.sizeThatFits)
            .padding()
            .environment(\.colorScheme, .light) // Light mode
            
            GoogleSignInSpecialButton(action: {
                print("Google Sign-In button tapped")
            })
            .previewLayout(.sizeThatFits)
            .padding()
            .environment(\.colorScheme, .dark) // Dark mode
        }
    }
}

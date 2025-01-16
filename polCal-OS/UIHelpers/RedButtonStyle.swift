//
//  RedButtonStyle.swift
//  polCal
//
//  Created by Lukas on 31/08/2024.
//

import SwiftUI

struct RedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.red)// Add a smooth animation
    }
}

#Preview {
    Button("Red Button") {
        print("Button pressed")
    }
    .buttonStyle(RedButtonStyle())
}

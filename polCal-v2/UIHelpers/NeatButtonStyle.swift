//
//  NeatButton.swift
//  polCal
//
//  Created by Lukas on 31/08/2024.
//

import SwiftUI

import SwiftUI

struct NeatButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold)) // Consistent font size and weight
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.05)) // Partially translucent background
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .gray.opacity(0.3), radius: 4, x: 2, y: 2) // Subtle shadow for depth
    }
}

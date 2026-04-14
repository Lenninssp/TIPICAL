//
//  ThemePickerView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-04-13.
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss

    let colors: [String] = [
        "#1C1C1E",
        "#000000",
        "#2C2C54",
        "#0F2027",
        "#3A1C71",
        "#1D976C",
        "#FF512F",
        "#DD2476"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Background")
                .font(.title2)
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(colors, id: \.self) { color in
                    Button {
                        ThemeStore.shared.saveColor(color)
                        dismiss()
                    } label: {
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

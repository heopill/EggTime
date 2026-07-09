//
//  TimerControlButton.swift
//  EggTimer
//

import SwiftUI

struct TimerControlButton: View {
    let iconName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(iconName)
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(title)
                    .fontStyle(.title14)
            }
            .frame(width: 80, height: 80)
            .foregroundColor(Color(hex: "555555"))
            .background(
                Circle()
                    .fill(Color("Button"))
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "555555"), lineWidth: 2)
                    )
            )
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        TimerControlButton(iconName: "Play", title: "시작") {}
        TimerControlButton(iconName: "Pause", title: "일시정지") {}
        TimerControlButton(iconName: "Restart", title: "재시작") {}
    }
}

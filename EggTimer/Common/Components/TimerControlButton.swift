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
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(title)
                    .fontStyle(.title14)
            }
            .frame(width: 80, height: 80)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("BrandPrimary"))
                    .shadow(color: Color(hex: "555555").opacity(0.25), radius: 4, x: 0, y: 8)
            )
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        TimerControlButton(iconName: "Play", title: "시작") {}
        TimerControlButton(iconName: "Pause", title: "일시정지") {}
        TimerControlButton(iconName: "Play", title: "재시작") {}
        TimerControlButton(iconName: "Restart", title: "초기화") {}
    }
}

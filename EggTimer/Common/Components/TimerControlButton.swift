//
//  TimerControlButton.swift
//  EggTimer
//

import SwiftUI
import UIKit

struct TimerControlButton: View {
    let iconName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            // 탭 시 가벼운 햅틱을 준다 (시작/일시정지/재시작/초기화)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(iconName)
                    .renderingMode(.template)
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

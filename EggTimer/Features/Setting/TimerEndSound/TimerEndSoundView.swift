//
//  TimerEndSoundView.swift
//  EggTimer
//

import SwiftUI

struct TimerEndSoundView: View {
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "Timer End Sound", table: "Setting"))
                .fontStyle(.title20)
                .foregroundColor(Color("TextNormal"))
        }
    }
}

#Preview {
    TimerEndSoundView()
}

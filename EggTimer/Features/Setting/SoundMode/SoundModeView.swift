//
//  SoundModeView.swift
//  EggTimer
//

import SwiftUI

struct SoundModeView: View {
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "Sound Mode", table: "Setting"))
                .fontStyle(.title20)
                .foregroundColor(Color("TextNormal"))
        }
    }
}

#Preview {
    SoundModeView()
}

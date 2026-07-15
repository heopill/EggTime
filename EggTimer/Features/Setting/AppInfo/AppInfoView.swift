//
//  AppInfoView.swift
//  EggTimer
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "App Info", table: "Setting"))
                .fontStyle(.title20)
                .foregroundColor(Color("TextNormal"))
        }
    }
}

#Preview {
    AppInfoView()
}

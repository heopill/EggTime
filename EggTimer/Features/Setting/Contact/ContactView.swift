//
//  ContactView.swift
//  EggTimer
//

import SwiftUI

struct ContactView: View {
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "Contact Us", table: "Setting"))
                .fontStyle(.title20)
                .foregroundColor(Color("TextNormal"))
        }
    }
}

#Preview {
    ContactView()
}

//
//  PrivacyPolicyView.swift
//  EggTimer
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "Privacy Policy", table: "Setting"))
                .fontStyle(.title20)
                .foregroundColor(Color("TextNormal"))
        }
    }
}

#Preview {
    PrivacyPolicyView()
}

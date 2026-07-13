//
//  SettingView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "Settings Screen", table: "Setting"))
        }
    }
}

#Preview {
    SettingView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

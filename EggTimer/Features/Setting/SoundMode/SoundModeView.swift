//
//  SoundModeView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct SoundModeView: View {
    @Bindable var store: StoreOf<SettingFeature>

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                AppBarView(
                    title: String(localized: "Sound Mode", table: "Setting"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: { store.send(.backTapped) }
                )

                SettingRadioOptionView(
                    options: SoundMode.allCases,
                    title: { $0.title },
                    selected: store.soundMode,
                    onSelect: { store.send(.soundModeSelected($0)) }
                )
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SoundModeView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

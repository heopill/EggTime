//
//  TimerEndSoundView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct TimerEndSoundView: View {
    @Bindable var store: StoreOf<SettingFeature>

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                AppBarView(
                    title: String(localized: "Timer End Sound", table: "Setting"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: { store.send(.backTapped) }
                )

                // 종료음이 많아 목록을 스크롤할 수 있게 감싼다
                ScrollView {
                    VStack(spacing: 16) {
                        SettingRadioOptionView(
                            options: TimerEndSound.allCases,
                            title: { $0.title },
                            selected: store.timerEndSound,
                            onSelect: { sound in
                                store.send(.timerEndSoundSelected(sound))
                                // 선택한 종료음을 바로 들려준다 (미리듣기)
                                CompletionSoundPlayer.shared.play(sound)
                            }
                        )

                        SettingInfoView(
                            messages: [String(localized: "Timer End Sound Info", table: "Setting")]
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TimerEndSoundView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

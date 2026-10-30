//
//  AppLanguageView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct AppLanguageView: View {
    @Bindable var store: StoreOf<SettingFeature>

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                AppBarView(
                    title: String(localized: "appLanguage", table: "Setting"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: { store.send(.backTapped) }
                )

                SettingRadioOptionView(
                    options: AppLanguage.allCases,
                    title: { $0.title },
                    selected: store.appLanguage,
                    onSelect: { store.send(.appLanguageSelected($0)) }
                )
                .padding(.horizontal, 20)

                SettingInfoView(
                    messages: [
                        String(localized: "appLanguageInfoRestart", table: "Setting"),
                        String(localized: "appLanguageInfoSystem", table: "Setting")
                    ]
                )
                .padding(.horizontal, 20)

                Spacer()

                // 화면 맨 아래에 배너 광고를 둔다
                BannerAdView(adUnit: .setting)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AppLanguageView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

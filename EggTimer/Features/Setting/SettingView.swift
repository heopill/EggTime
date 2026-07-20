//
//  SettingView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>

    var body: some View {
        NavigationStack(path: $store.path) {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    AppBarView(title: String(localized: "Settings", table: "Setting"))

                    VStack(spacing: 16) {
                        soundSection
                        appSection
                        contactSection
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SettingFeature.Route.self) { route in
                // 세부 화면에서는 탭바를 숨긴다
                destination(route)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }

    // 경로에 따라 이동할 하위 화면
    @ViewBuilder
    private func destination(_ route: SettingFeature.Route) -> some View {
        switch route {
        case .soundMode:
            SoundModeView()

        case .timerEndSound:
            TimerEndSoundView()

        case .appInfo:
            AppInfoView()

        case .privacyPolicy:
            PrivacyPolicyView()

        case .contact:
            ContactView()
        }
    }

    // 사운드 설정 섹션
    private var soundSection: some View {
        section(
            title: String(localized: "Sound Settings", table: "Setting"),
            items: [
                SettingOptionItem(iconName: "Sound", title: String(localized: "Sound Mode", table: "Setting")) {
                    store.send(.soundModeTapped)
                },
                SettingOptionItem(iconName: "Music", title: String(localized: "Timer End Sound", table: "Setting")) {
                    store.send(.timerEndSoundTapped)
                }
            ]
        )
    }

    // 앱 섹션
    private var appSection: some View {
        section(
            title: String(localized: "App", table: "Setting"),
            items: [
                SettingOptionItem(iconName: "Info", title: String(localized: "App Info", table: "Setting")) {
                    store.send(.appInfoTapped)
                },
                SettingOptionItem(iconName: "Key", title: String(localized: "Privacy Policy", table: "Setting")) {
                    store.send(.privacyPolicyTapped)
                }
            ]
        )
    }

    // 문의 섹션
    private var contactSection: some View {
        section(
            title: String(localized: "Contact", table: "Setting"),
            items: [
                SettingOptionItem(iconName: "Question", title: String(localized: "Contact Us", table: "Setting")) {
                    store.send(.contactTapped)
                }
            ]
        )
    }

    // 섹션 타이틀 + 카드(SettingOptionView)로 구성된 한 섹션
    private func section(title: String, items: [SettingOptionItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .fontStyle(.title16)
                .foregroundColor(Color("TextNormal"))
                .frame(maxWidth: .infinity, alignment: .leading)

            SettingOptionView(items: items)
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

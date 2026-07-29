//
//  AppInfoView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct AppInfoView: View {
    @Bindable var store: StoreOf<SettingFeature>
    @Environment(\.openURL) private var openURL

    // 현재 앱 버전
    private var currentVersion: String {
        return AppInfo.currentVersion
    }

    // 앱스토어 최신 버전 (조회 전/미배포면 nil)
    private var latestVersion: String? {
        return store.appStoreLookup?.version
    }

    // 업데이트 가능 여부 (현재 버전 < 앱스토어 버전일 때만 true)
    private var isUpdateAvailable: Bool {
        guard let latest = latestVersion else {
            return false
        }

        return SettingVersionView.compareVersion(currentVersion, latest) == .orderedAscending
    }

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                AppBarView(
                    title: String(localized: "App Info", table: "Setting"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: { store.send(.backTapped) }
                )

                // 최신 버전을 아직 모르면 현재 버전과 같게 표시한다
                SettingVersionView(
                    currentVersion: currentVersion,
                    latestVersion: latestVersion ?? currentVersion
                )
                .padding(.horizontal, 20)

                Spacer()

                // 업데이트 가능하면 활성화되어 앱스토어로 이동, 최신이면 비활성화
                SettingButtonView(
                    title: isUpdateAvailable
                        ? String(localized: "Update", table: "Setting")
                        : String(localized: "You're up to date", table: "Setting"),
                    isEnabled: isUpdateAvailable,
                    action: openAppStore
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            // 진입 시 앱스토어 최신 버전을 조회한다
            store.send(.appStoreVersionRequested)
        }
    }

    // 앱스토어의 이 앱 페이지로 이동한다
    private func openAppStore() {
        guard let url = store.appStoreLookup?.url else {
            return
        }

        openURL(url)
    }
}

#Preview {
    AppInfoView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

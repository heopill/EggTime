//
//  NotificationView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct NotificationView: View {
    @Bindable var store: StoreOf<SettingFeature>
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    // 설정 앱 이동을 확인하는 알럿 표시 여부
    @State private var isSettingsAlertPresented = false

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                AppBarView(
                    title: String(localized: "Notifications", table: "Setting"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: { store.send(.backTapped) }
                )

                // 알림 켜기(true) / 알림 끄기(false) 라디오. 실제 변경은 시스템 설정에서만 가능하다
                SettingRadioOptionView(
                    options: [true, false],
                    title: { $0
                        ? String(localized: "Notifications On", table: "Setting")
                        : String(localized: "Notifications Off", table: "Setting")
                    },
                    selected: store.isNotificationAuthorized,
                    onSelect: { _ in isSettingsAlertPresented = true }
                )
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if isSettingsAlertPresented {
                CustomAlertView(
                    title: String(localized: "Change notification setting", table: "Setting"),
                    message: String(localized: "Notifications can be turned on or off in iOS Settings.", table: "Setting"),
                    confirmTitle: String(localized: "Open Settings", table: "Setting"),
                    cancelTitle: String(localized: "Cancel", table: "Setting"),
                    confirmAction: {
                        isSettingsAlertPresented = false
                        openSystemSettings()
                    },
                    cancelAction: { isSettingsAlertPresented = false }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSettingsAlertPresented)
        .task {
            // 진입 시 현재 권한 상태를 읽어 기본값으로 반영한다
            store.send(.notificationStatusRequested)
        }
        .onChange(of: scenePhase) { _, newPhase in
            // 설정 앱에서 권한을 바꾸고 돌아오면 상태를 다시 읽어 갱신한다
            if newPhase == .active {
                store.send(.notificationStatusRequested)
            }
        }
    }

    // iOS 설정 앱에서 이 앱의 알림 설정 페이지를 바로 연다
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(url)
    }
}

#Preview {
    NotificationView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

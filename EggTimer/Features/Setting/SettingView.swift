//
//  SettingView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture
import MessageUI

struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>
    // 문의 메일 작성 시트 표시 여부
    @State private var isMailPresented = false
    // 메일을 보낼 수 없을 때 안내 알럿 표시 여부
    @State private var isMailUnavailableAlertPresented = false
    // 문의 정보 복사 완료 토스트 표시 여부
    @State private var isCopiedToastPresented = false

    var body: some View {
        NavigationStack(path: $store.path) {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    AppBarView(title: String(localized: "Settings", table: "Setting"))

                    VStack(spacing: 16) {
                        personalSection
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
            .task {
                store.send(.onAppear)
            }
        }
        // 문의하기: 기기/앱 정보가 자동 입력된 메일 작성 창을 띄운다
        .sheet(isPresented: $isMailPresented) {
            MailComposeView(
                recipient: SupportInfo.recipient,
                subject: SupportInfo.subject,
                body: SupportInfo.body,
                onFinish: { isMailPresented = false }
            )
            .ignoresSafeArea()
        }
        // 메일을 보낼 수 없을 때 안내 알럿
        .overlay {
            if isMailUnavailableAlertPresented {
                CustomAlertView(
                    title: String(localized: "Can't send mail", table: "Setting"),
                    message: String(
                        format: String(localized: "Mail app is not set up. Please contact us at %@.", table: "Setting"),
                        SupportInfo.recipient
                    ),
                    confirmTitle: String(localized: "Copy info", table: "Setting"),
                    cancelTitle: String(localized: "Confirm", table: "Setting"),
                    confirmAction: {
                        UIPasteboard.general.string = SupportInfo.clipboardText
                        isMailUnavailableAlertPresented = false
                        isCopiedToastPresented = true
                    },
                    cancelAction: { isMailUnavailableAlertPresented = false }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isMailUnavailableAlertPresented)
        // 정보 복사 완료 토스트 (하단, 잠시 후 자동으로 사라짐)
        .overlay(alignment: .bottom) {
            if isCopiedToastPresented {
                ToastMessageView(message: String(localized: "Info copied", table: "Setting"))
                    .padding(.bottom, 24)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCopiedToastPresented)
        .task(id: isCopiedToastPresented) {
            guard isCopiedToastPresented else { return }
            try? await Task.sleep(for: .seconds(2))
            isCopiedToastPresented = false
        }
    }

    // 문의하기 탭: 메일 사용 가능하면 작성 창을, 아니면 안내 알럿을 띄운다
    private func handleContactTap() {
        if MFMailComposeViewController.canSendMail() {
            isMailPresented = true
        } else {
            isMailUnavailableAlertPresented = true
        }
    }

    // 경로에 따라 이동할 하위 화면
    @ViewBuilder
    private func destination(_ route: SettingFeature.Route) -> some View {
        switch route {
        case .notification:
            NotificationView(store: store)

        case .soundMode:
            SoundModeView(store: store)

        case .timerEndSound:
            TimerEndSoundView(store: store)

        case .appInfo:
            AppInfoView()

        case .privacyPolicy:
            PrivacyPolicyView()
        }
    }

    // 개인 설정 섹션
    private var personalSection: some View {
        section(
            title: String(localized: "Personal Settings", table: "Setting"),
            items: [
                SettingOptionItem(iconName: "Bell", title: String(localized: "Notifications", table: "Setting")) {
                    store.send(.notificationTapped)
                },
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
                    handleContactTap()
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

//
//  PrivacyPolicyView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct PrivacyPolicyView: View {
    @Bindable var store: StoreOf<SettingFeature>

    // 번들에 포함된 개인정보처리방침 HTML 파일
    private var htmlURL: URL? {
        return Bundle.main.url(forResource: "privacy_policy", withExtension: "html")
    }

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AppBarView(
                    title: String(localized: "Privacy Policy", table: "Setting"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: { store.send(.backTapped) }
                )

                if let htmlURL {
                    WebView(fileURL: htmlURL)
                } else {
                    Spacer()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PrivacyPolicyView(
        store: Store(initialState: SettingFeature.State()) {
            SettingFeature()
        }
    )
}

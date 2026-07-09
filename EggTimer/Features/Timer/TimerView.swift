//
//  TimerView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    @Bindable var store: StoreOf<TimerFeature>

    var body: some View {
        TabView(selection: $store.selectedTab) {
            ZStack {
                Color(hex: "FDFFC7")
                    .ignoresSafeArea()

                Text("타이머 화면")
            }
            .tabItem {
                Label("타이머", image: "Timer")
            }
            .tag(TimerFeature.Tab.timer)

            HistoryView(store: store.scope(state: \.history, action: \.history))
                .tabItem {
                    Label("기록", image: "History")
                }
                .tag(TimerFeature.Tab.history)

            SettingView(store: store.scope(state: \.setting, action: \.setting))
                .tabItem {
                    Label("설정", image: "Setting")
                }
                .tag(TimerFeature.Tab.setting)
        }
        .tint(Color(hex: "FF6F00"))
    }
}

#Preview {
    TimerView(
        store: Store(initialState: TimerFeature.State()) {
            TimerFeature()
        }
    )
}

// 기록 부분에서 삶은 달걀의 수를 사용자에게 입력받는 화면이 필요할 거 같음

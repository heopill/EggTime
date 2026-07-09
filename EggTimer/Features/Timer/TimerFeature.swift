//
//  TimerFeature.swift
//  EggTimer
//

import ComposableArchitecture

@Reducer
struct TimerFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .timer
        var history = HistoryFeature.State()
        var setting = SettingFeature.State()
    }

    nonisolated enum Tab: Equatable, Sendable {
        case timer
        case history
        case setting
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case history(HistoryFeature.Action)
        case setting(SettingFeature.Action)
    }

    // 하위 리듀서(BindingReducer, Scope)를 조합하므로 반환 타입은 some Reducer<State, Action>를 사용한다
    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.history, action: \.history) {
            HistoryFeature()
        }
        Scope(state: \.setting, action: \.setting) {
            SettingFeature()
        }
    }
}

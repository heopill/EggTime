//
//  HistoryFeature.swift
//  EggTimer
//

import ComposableArchitecture

@Reducer
struct HistoryFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action {}

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

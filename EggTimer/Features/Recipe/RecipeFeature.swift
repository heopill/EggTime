//
//  RecipeFeature.swift
//  EggTimer
//

import ComposableArchitecture

@Reducer
struct RecipeFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action {}

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

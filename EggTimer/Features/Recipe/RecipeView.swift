//
//  RecipeView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct RecipeView: View {
    @Bindable var store: StoreOf<RecipeFeature>

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            Text(String(localized: "Recipe Screen", table: "Recipe"))
        }
    }
}

#Preview {
    RecipeView(
        store: Store(initialState: RecipeFeature.State()) {
            RecipeFeature()
        }
    )
}

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

            Text("레시피 화면")
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

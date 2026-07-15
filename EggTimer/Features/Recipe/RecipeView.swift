//
//  RecipeView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct RecipeView: View {
    @Bindable var store: StoreOf<RecipeFeature>

    // 레시피 그리드 2열 구성
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        NavigationStack(path: $store.path) {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    AppBarView(title: String(localized: "Recipe", table: "Recipe"))

                    RecipeCategoryView(selected: store.selectedCategory) { category in
                        store.send(.categorySelected(category))
                    }
                    .padding(.horizontal, 20)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(store.filteredRecipes) { recipe in
                                RecipeOptionView(
                                    imageName: recipe.imageName,
                                    title: recipe.title,
                                    description: recipe.description,
                                    recipeLabel: recipe.recipeLabel,
                                    isBookmarked: recipe.isBookmarked,
                                    onBookmarkTap: { store.send(.bookmarkTapped(recipe.id)) },
                                    onTap: { store.send(.recipeTapped(recipe.id)) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationDestination(for: Recipe.ID.self) { id in
                if let recipe = store.recipes[id: id] {
                    RecipeDetailView(
                        recipe: recipe,
                        onBack: { store.send(.backTapped) },
                        onBookmarkTap: { store.send(.bookmarkTapped(id)) }
                    )
                }
            }
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

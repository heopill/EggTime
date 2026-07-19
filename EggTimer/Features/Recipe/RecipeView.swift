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
            .task {
                store.send(.onAppear)
            }
        }
        // 레시피 목록 · 상세 화면 모두에서 하단 안전영역 20pt 위에 토스트를 띄운다
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                ToastMessageView(message: message)
                    .padding(.bottom, 20)
                    // 나타날 때는 빠르게, 사라질 때는 천천히 페이드 아웃한다
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeIn(duration: 0.2)),
                        removal: .opacity.animation(.easeOut(duration: 0.8))
                    ))
            }
        }
        .animation(.default, value: store.toastMessage)
    }
}

#Preview {
    RecipeView(
        store: Store(initialState: RecipeFeature.State()) {
            RecipeFeature()
        }
    )
}

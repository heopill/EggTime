//
//  RecipeFeature.swift
//  EggTimer
//

import ComposableArchitecture

@Reducer
struct RecipeFeature {
    @ObservableState
    struct State: Equatable {
        var recipes: IdentifiedArrayOf<Recipe> = IdentifiedArray(uniqueElements: Recipe.all)
        var selectedCategory: RecipeCategory = .all
        // 레시피 상세로 밀어 넣은 화면 경로 (선택된 레시피 id)
        var path: [Recipe.ID] = []

        // 선택된 카테고리에 맞게 필터링된 레시피 목록
        var filteredRecipes: [Recipe] {
            guard selectedCategory != .all else {
                return Array(recipes)
            }

            return recipes.filter { $0.category == selectedCategory }
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case categorySelected(RecipeCategory)
        case bookmarkTapped(Recipe.ID)
        case recipeTapped(Recipe.ID)
        case backTapped
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .categorySelected(category):
                state.selectedCategory = category

                return .none

            case let .bookmarkTapped(id):
                state.recipes[id: id]?.isBookmarked.toggle()

                return .none

            case let .recipeTapped(id):
                state.path.append(id)

                return .none

            case .backTapped:
                _ = state.path.popLast()

                return .none

            case .binding:
                return .none
            }
        }
    }
}

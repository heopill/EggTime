//
//  RecipeFeature.swift
//  EggTimer
//

import Foundation
import ComposableArchitecture

@Reducer
struct RecipeFeature {
    @ObservableState
    struct State: Equatable {
        var recipes: IdentifiedArrayOf<Recipe> = IdentifiedArray(uniqueElements: Recipe.all)
        var selectedCategory: RecipeCategory = .all
        // 레시피 상세로 밀어 넣은 화면 경로 (선택된 레시피 id)
        var path: [Recipe.ID] = []
        // 표시 중인 토스트 문구 (없으면 nil)
        var toastMessage: String?

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
        case onAppear
        case categorySelected(RecipeCategory)
        case bookmarkTapped(Recipe.ID)
        case recipeTapped(Recipe.ID)
        case backTapped
        case toastDismissed
    }

    @Dependency(\.bookmarks) var bookmarks
    @Dependency(\.continuousClock) var clock

    nonisolated private enum CancelID {
        case toast
    }

    // 토스트가 화면에 머무는 시간
    private static let toastDuration: Duration = .seconds(2)

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                // 저장된 북마크를 불러와 반영한다
                let savedIDs = bookmarks.load()
                for id in savedIDs {
                    state.recipes[id: id]?.isBookmarked = true
                }

                return .none

            case let .categorySelected(category):
                state.selectedCategory = category

                return .none

            case let .bookmarkTapped(id):
                state.recipes[id: id]?.isBookmarked.toggle()
                // 저장 여부에 맞는 토스트 문구를 띄운다
                let isBookmarked = state.recipes[id: id]?.isBookmarked ?? false
                state.toastMessage = isBookmarked
                    ? String(localized: "Recipe saved", table: "Recipe")
                    : String(localized: "Save cancelled", table: "Recipe")

                // 현재 북마크된 id 전체를 UserDefaults에 저장한다
                let bookmarkedIDs = Set(state.recipes.filter(\.isBookmarked).map(\.id))

                return .merge(
                    .run { [bookmarks] _ in
                        bookmarks.save(bookmarkedIDs)
                    },
                    // 연속으로 누르면 이전 타이머를 취소하고 노출 시간을 다시 센다
                    .run { [clock] send in
                        try await clock.sleep(for: Self.toastDuration)
                        await send(.toastDismissed)
                    }
                    .cancellable(id: CancelID.toast, cancelInFlight: true)
                )

            case .toastDismissed:
                state.toastMessage = nil

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

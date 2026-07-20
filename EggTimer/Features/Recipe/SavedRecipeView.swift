//
//  SavedRecipeView.swift
//  EggTimer
//

import SwiftUI

// 북마크로 저장한 레시피들을 모아 보여주는 화면
struct SavedRecipeView: View {
    // 저장된 레시피 목록 (비어 있으면 안내 문구를 표시한다)
    let recipes: [Recipe]
    // 뒤로가기 버튼 탭 동작
    var onBack: () -> Void = {}
    // 북마크 버튼 탭 동작
    var onBookmarkTap: (Recipe.ID) -> Void = { _ in }
    // 카드 탭 동작 (레시피 상세로 이동)
    var onRecipeTap: (Recipe.ID) -> Void = { _ in }

    // 레시피 그리드 2열 구성 (레시피 목록 화면과 동일)
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AppBarView(
                    title: String(localized: "Saved Recipes", table: "Recipe"),
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: onBack
                )

                if recipes.isEmpty {
                    Spacer()
                } else {
                    recipeGrid
                }
            }
        }
        // 저장된 레시피가 없을 때는 화면 중앙에 안내 문구를 표시한다
        .overlay {
            if recipes.isEmpty {
                Text(String(localized: "No saved recipes", table: "Recipe"))
                    .fontStyle(.body16)
                    .foregroundColor(Color("TextNormal"))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    // 저장된 레시피 카드 그리드
    private var recipeGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(recipes) { recipe in
                    RecipeOptionView(
                        imageName: recipe.imageName,
                        title: recipe.title,
                        description: recipe.description,
                        recipeLabel: recipe.recipeLabel,
                        isBookmarked: recipe.isBookmarked,
                        onBookmarkTap: { onBookmarkTap(recipe.id) },
                        onTap: { onRecipeTap(recipe.id) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
}

#Preview("저장된 레시피 있음") {
    SavedRecipeView(recipes: [.preview])
}

#Preview("저장된 레시피 없음") {
    SavedRecipeView(recipes: [])
}

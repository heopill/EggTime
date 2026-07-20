//
//  RecipeDetailView.swift
//  EggTimer
//

import SwiftUI

struct RecipeDetailView: View {
    // 표시할 레시피 데이터
    let recipe: Recipe
    // 뒤로가기 버튼 탭 동작
    var onBack: () -> Void = {}
    // 북마크 버튼 탭 동작
    var onBookmarkTap: () -> Void = {}

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Image(recipe.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: 340)
                        .clipped()

                    content
                }
            }
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .top) {
                AppBarView(
                    leadingIcon: "ChevronLeft",
                    onLeadingTap: onBack,
                    trailingIcon: recipe.isBookmarked ? "BookmarkSelected" : "BookmarkDefault",
                    onTrailingTap: onBookmarkTap,
                    // 사진 위에 올라가므로 아이콘 뒤에 반투명 배경을 둔다
                    iconStyle: .overlay
                )
            }
        }
        .background(Color("Button"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
    }

    // 이미지 아래의 상세 내용 (제목 + 정보 + 접이식 섹션)
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .fontStyle(.title24)
                    .foregroundColor(Color("TextStrong"))

                HStack(spacing: 8) {
                    RecipeInfoView(iconName: "Stopwatch", text: "\(recipe.cookTime)분 조리")
                    RecipeInfoView(iconName: "Fire", text: recipe.difficulty.label)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)

            VStack(spacing: 0) {
                RecipeSectionView(title: "설명") {
                    Text(recipe.description)
                        .fontStyle(.body16)
                        .foregroundColor(Color("TextNormal"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                RecipeSectionView(title: "재료") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(recipe.ingredients, id: \.self) { item in
                            listRow(marker: "•", text: item)
                        }
                    }
                }

                RecipeSectionView(title: "조리법") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            listRow(marker: "\(index + 1).", text: step)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
        .background(alignment: .top) {
            // 카드 상단 가장자리에만 그림자를 드리운다 (나머지는 카드가 덮어 가림)
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(Color.white)
                .frame(height: 60)
                .shadow(color: Color("TextStrong").opacity(0.25), radius: 20, x: 4, y: -4)
        }
        .padding(.top, -24)
    }

    // 재료(불릿) / 조리법(번호) 목록의 한 줄
    private func listRow(marker: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(marker)
                .frame(width: 16, alignment: .leading)

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fontStyle(.body16)
        .foregroundColor(Color("TextNormal"))
    }
}

#Preview {
    RecipeDetailView(recipe: .preview)
}

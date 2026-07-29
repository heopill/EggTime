//
//  RecipeOptionView.swift
//  EggTimer
//

import SwiftUI

struct RecipeOptionView: View {
    // 레시피 대표 이미지 에셋 이름
    let imageName: String
    // 레시피 이름
    let title: String
    // 레시피 간단 설명글
    let description: String
    // 레시피 분류 라벨
    let recipeLabel: String
    // 북마크 선택 여부
    let isBookmarked: Bool
    // 북마크 버튼 탭 동작
    var onBookmarkTap: () -> Void = {}
    // 카드 탭 동작 (레시피 상세로 이동)
    var onTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 115)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    bookmarkButton
                        .padding(16)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .fontStyle(.title16)
                    .foregroundColor(Color("TextStrong"))

                Text(description)
                    .fontStyle(.body12)
                    .foregroundColor(Color("TextNormal"))
                    .lineLimit(2, reservesSpace: true)
                    .truncationMode(.tail)

                Text(recipeLabel)
                    .fontStyle(.title12)
                    .foregroundColor(Color("BrandPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color( "TextNormal").opacity(0.08), radius: 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    // 이미지 우측 상단의 북마크 토글 버튼
    private var bookmarkButton: some View {
        Button(action: onBookmarkTap) {
            Image(isBookmarked ? "BookmarkSelected" : "BookmarkDefault")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("Background"))
                .frame(width: 24, height: 24)
                .padding(6)
                .background(Color("TextStrong").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecipeOptionView(
        imageName: "EggSalad",
        title: "달걀 샐러드",
        description: "간편하면서도 영양 가득, 다이어트부터 든든한 식사까지 어울리는 레시피",
        recipeLabel: "삶은 달걀 레시피",
        isBookmarked: true
    )
    .frame(width: 158)
    .padding()
}

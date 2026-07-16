//
//  RecipeCategoryView.swift
//  EggTimer
//

import SwiftUI

// 레시피 필터링에 사용하는 카테고리 (전체 보기 + 요리 분류)
enum RecipeCategory: CaseIterable, Identifiable, Hashable {
    case all, boiled, fried, scrambled, omelette

    var id: Self { self }

    // 카테고리 표시 이름
    var title: String {
        switch self {
        case .all: return String(localized: "All", table: "Recipe")
        case .boiled: return String(localized: "Boiled Egg", table: "Common")
        case .fried: return String(localized: "Fried Egg", table: "Common")
        case .scrambled: return String(localized: "Scrambled Eggs", table: "Common")
        case .omelette: return String(localized: "Omelette", table: "Common")
        }
    }
}

struct RecipeCategoryView: View {
    // 표시할 카테고리 목록
    var categories: [RecipeCategory] = RecipeCategory.allCases
    // 현재 선택된 카테고리
    let selected: RecipeCategory
    // 카테고리 선택 시 동작
    var onSelect: (RecipeCategory) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    chip(category)
                }
            }
        }
    }

    // 카테고리 한 개를 나타내는 칩 버튼
    private func chip(_ category: RecipeCategory) -> some View {
        let isSelected = category == selected

        return Button {
            onSelect(category)
        } label: {
            Text(category.title)
                .fontStyle(.title16)
                .foregroundColor(isSelected ? Color("Button") : Color("TextNormal"))
                .lineLimit(1)
                .padding(10)
                .background(isSelected ? Color("BrandPrimary") : Color("Button"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecipeCategoryView(selected: .all)
        .padding()
}

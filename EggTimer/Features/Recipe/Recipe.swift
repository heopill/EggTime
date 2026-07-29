//
//  Recipe.swift
//  EggTimer
//

import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    // 조리 시간(분)
    let cookTime: Int
    // 요리 난이도
    let difficulty: Difficulty
    let description: String
    // 재료 목록
    let ingredients: [String]
    // 조리법 단계
    let steps: [String]
    var isBookmarked: Bool = false

    // 이미지 에셋 이름은 id와 동일하게 맞춰져 있다
    var imageName: String { id }

    // isBookmarked는 JSON에 없으므로 디코딩 대상에서 제외한다
    enum CodingKeys: String, CodingKey {
        case id, title, cookTime, difficulty, description, ingredients, steps
    }
}

// 요리 난이도
enum Difficulty: String, Codable, Equatable {
    case easy, medium, hard

    // 난이도 표시 라벨
    var label: String {
        switch self {
        case .easy: return String(localized: "Easy", table: "Recipe")
        case .medium: return String(localized: "Medium", table: "Recipe")
        case .hard: return String(localized: "Hard", table: "Recipe")
        }
    }
}

extension Recipe {
    // 번들의 Recipes.json에서 레시피 목록을 로드한다
    static let all: [Recipe] = {
        guard let url = Bundle.main.url(forResource: "Recipes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let recipes = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }

        return recipes
    }()

    // 필터링에 사용하는 카테고리 (요리별 대표 조리법 기준 — 필요 시 조정)
    var category: RecipeCategory {
        switch id {
        case "EggSalad", "Eggzaro", "SoyMarinatedEgg", "TunaEggPoke", "EggCurry", "EggPorkBraised":
            return .boiled

        case "NattoSoyEggRice", "EggYakisoba", "EggTofuBraised", "EggBagel", "AvocadoEggSandwich", "EggInHell":
            return .fried

        case "EggToast", "SalmonEggToast", "ShrimpEggFriedRice", "CheeseCornEggFriedRice", "ScrambledBurger", "ScrambledCroissant":
            return .scrambled

        case "HamTomatoOmelette", "CurryTornadoOmelette", "OmeletteRice":
            return .omelette

        default:
            return .boiled
        }
    }

    // 카드에 표시하는 분류 라벨
    var recipeLabel: String {
        "\(category.title) \(String(localized: "Recipe", table: "Recipe"))"
    }
}

extension Recipe {
    // 프리뷰용 샘플
    static let preview = Recipe(
        id: "EggSalad",
        title: "계란 샐러드",
        cookTime: 15,
        difficulty: .easy,
        description: "부드럽게 삶은 계란과 고소한 마요네즈가 어우러진 계란 샐러드는 간단하면서도 든든한 한 끼 또는 간식으로 즐기기 좋은 메뉴입니다.",
        ingredients: ["계란 4개", "마요네즈 3큰술", "소금 약간", "후추 약간"],
        steps: ["계란을 삶아 껍질을 벗깁니다.", "볼에 넣고 으깹니다.", "마요네즈와 섞어 완성합니다."]
    )
}

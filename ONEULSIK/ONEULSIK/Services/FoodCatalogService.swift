import Foundation

struct FoodCatalogService {
    let foods: [FoodCatalogItem]

    init(foods: [FoodCatalogItem] = FoodCatalogService.defaultFoods) {
        self.foods = foods
    }

    func search(query: String) -> [FoodCatalogItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return foods }
        return foods.filter { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }
    }

    private static let defaultFoods: [FoodCatalogItem] = [
        food("white-rice", "흰쌀밥", "공기", 210, 336, 73.5, 6.1, 0.6),
        food("brown-rice", "현미밥", "공기", 210, 321, 68.9, 7.1, 2.2),
        food("mixed-grain-rice", "잡곡밥", "공기", 210, 315, 66.0, 8.0, 2.5),
        food("chicken-breast", "닭가슴살", "팩", 100, 165, 0, 31.0, 3.6),
        food("fried-egg", "계란프라이", "개", 50, 90, 0.4, 6.3, 7.0),
        food("boiled-egg", "삶은 계란", "개", 50, 78, 0.6, 6.3, 5.3),
        food("kimchi-stew", "김치찌개", "그릇", 300, 180, 11.0, 14.0, 9.0),
        food("soybean-stew", "된장찌개", "그릇", 300, 170, 14.0, 13.0, 7.0),
        food("seaweed-soup", "미역국", "그릇", 300, 85, 6.0, 7.0, 4.0),
        food("bulgogi", "소불고기", "접시", 150, 290, 18.0, 27.0, 12.0),
        food("bibimbap", "비빔밥", "그릇", 450, 560, 88.0, 20.0, 14.0),
        food("kimbap", "김밥", "줄", 250, 410, 68.0, 13.0, 10.0),
        food("ramyeon", "라면", "봉지", 120, 500, 79.0, 10.0, 16.0),
        food("banana", "바나나", "개", 100, 89, 22.8, 1.1, 0.3),
        food("apple", "사과", "개", 200, 104, 27.6, 0.5, 0.3),
        food("milk", "우유", "컵", 200, 130, 10.0, 6.0, 7.0),
        food("greek-yogurt", "그릭요거트", "컵", 100, 97, 3.9, 9.0, 5.0),
        food("sweet-potato", "고구마", "개", 150, 193, 45.0, 2.4, 0.3)
    ]

    private static func food(
        _ id: String,
        _ name: String,
        _ unit: String,
        _ grams: Double,
        _ calories: Double,
        _ carbohydrates: Double,
        _ protein: Double,
        _ fat: Double
    ) -> FoodCatalogItem {
        FoodCatalogItem(
            id: id,
            name: name,
            servingUnit: unit,
            servingGrams: grams,
            nutrition: NutritionValues(
                calories: calories,
                carbohydrateGrams: carbohydrates,
                proteinGrams: protein,
                fatGrams: fat
            )
        )
    }
}

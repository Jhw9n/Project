import Foundation

struct FoodCatalogItem: Identifiable, Hashable {
    let id: String
    let name: String
    let servingUnit: String
    let servingGrams: Double
    let nutrition: NutritionValues

    func nutrition(for servingCount: Double) -> NutritionValues {
        nutrition * servingCount
    }

    func servingDescription(for servingCount: Double) -> String {
        let count = servingCount.formatted(
            .number.precision(.fractionLength(servingCount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1))
        )
        let grams = (servingGrams * servingCount).formatted(
            .number.precision(.fractionLength(0))
        )
        return "\(count)\(servingUnit) (\(grams)g)"
    }
}

import Foundation
import SwiftData

@Model
final class MealRecord {
    var kakaoUserID: Int64
    var recordedAt: Date
    var calories: Double
    var carbohydrateGrams: Double
    var proteinGrams: Double
    var fatGrams: Double

    init(
        kakaoUserID: Int64,
        recordedAt: Date,
        calories: Double,
        carbohydrateGrams: Double,
        proteinGrams: Double,
        fatGrams: Double
    ) {
        self.kakaoUserID = kakaoUserID
        self.recordedAt = recordedAt
        self.calories = calories
        self.carbohydrateGrams = carbohydrateGrams
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
    }
}

struct NutritionValues: Equatable {
    var calories: Double
    var carbohydrateGrams: Double
    var proteinGrams: Double
    var fatGrams: Double

    static let zero = NutritionValues(
        calories: 0,
        carbohydrateGrams: 0,
        proteinGrams: 0,
        fatGrams: 0
    )

    static func + (lhs: NutritionValues, rhs: NutritionValues) -> NutritionValues {
        NutritionValues(
            calories: lhs.calories + rhs.calories,
            carbohydrateGrams: lhs.carbohydrateGrams + rhs.carbohydrateGrams,
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            fatGrams: lhs.fatGrams + rhs.fatGrams
        )
    }
}

extension MealRecord {
    var nutritionValues: NutritionValues {
        NutritionValues(
            calories: calories,
            carbohydrateGrams: carbohydrateGrams,
            proteinGrams: proteinGrams,
            fatGrams: fatGrams
        )
    }
}

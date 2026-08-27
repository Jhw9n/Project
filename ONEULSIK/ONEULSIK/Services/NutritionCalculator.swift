import Foundation

struct NutritionRecommendation: Equatable {
    let calories: Double
    let carbohydrateGrams: Double
    let proteinGrams: Double
    let fatGrams: Double

    static let fallback = NutritionRecommendation(
        calories: 2_000,
        carbohydrateGrams: 275,
        proteinGrams: 88,
        fatGrams: 61
    )
}

enum NutritionCalculator {
    private static let carbohydrateEnergyRatio = 0.55
    private static let proteinEnergyRatio = 0.175
    private static let fatEnergyRatio = 0.275

    static func recommendation(
        for profile: UserProfile,
        calendar: Calendar = .current,
        now: Date = .now
    ) -> NutritionRecommendation? {
        guard
            let genderRawValue = profile.genderRawValue,
            let gender = Gender(rawValue: genderRawValue),
            let birthDate = profile.birthDate,
            let heightCM = profile.heightCM,
            let weightTenthsKG = profile.weightTenthsKG,
            let activityRawValue = profile.activityLevelRawValue,
            let activityLevel = ActivityLevel(rawValue: activityRawValue)
        else {
            return nil
        }

        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        guard age >= 3 else {
            return nil
        }

        let weightKG = Double(weightTenthsKG) / 10
        let energy = age >= 19 ? adultEnergyRequirement(
            gender: gender,
            activityLevel: activityLevel,
            age: Double(age),
            heightCM: Double(heightCM),
            weightKG: weightKG
        ) : youthEnergyRequirement(
            gender: gender,
            activityLevel: activityLevel,
            age: age,
            heightCM: Double(heightCM),
            weightKG: weightKG
        )
        let roundedEnergy = (energy / 10).rounded() * 10

        return NutritionRecommendation(
            calories: roundedEnergy,
            carbohydrateGrams: roundedEnergy * carbohydrateEnergyRatio / 4,
            proteinGrams: roundedEnergy * proteinEnergyRatio / 4,
            fatGrams: roundedEnergy * fatEnergyRatio / 9
        )
    }

    private static func adultEnergyRequirement(
        gender: Gender,
        activityLevel: ActivityLevel,
        age: Double,
        heightCM: Double,
        weightKG: Double
    ) -> Double {
        let coefficients = adultCoefficients(for: gender, activityLevel: activityLevel)

        return coefficients.intercept
            + coefficients.age * age
            + coefficients.height * heightCM
            + coefficients.weight * weightKG
    }

    private static func youthEnergyRequirement(
        gender: Gender,
        activityLevel: ActivityLevel,
        age: Int,
        heightCM: Double,
        weightKG: Double
    ) -> Double {
        let coefficients = youthCoefficients(for: gender, activityLevel: activityLevel)

        return coefficients.intercept
            + coefficients.age * Double(age)
            + coefficients.height * heightCM
            + coefficients.weight * weightKG
            + growthEnergy(for: gender, age: age)
    }

    private static func adultCoefficients(
        for gender: Gender,
        activityLevel: ActivityLevel
    ) -> (intercept: Double, age: Double, height: Double, weight: Double) {
        switch (gender, activityLevel) {
        case (.male, .low):
            (753.07, -10.83, 6.50, 14.10)
        case (.male, .moderate):
            (581.47, -10.83, 8.30, 14.94)
        case (.male, .active):
            (1_004.82, -10.83, 6.52, 15.91)
        case (.female, .low):
            (584.90, -7.01, 5.72, 11.71)
        case (.female, .moderate):
            (575.77, -7.01, 6.60, 12.14)
        case (.female, .active):
            (710.25, -7.01, 6.54, 12.34)
        }
    }

    private static func youthCoefficients(
        for gender: Gender,
        activityLevel: ActivityLevel
    ) -> (intercept: Double, age: Double, height: Double, weight: Double) {
        switch (gender, activityLevel) {
        case (.male, .low):
            (-447.51, 3.68, 13.01, 13.15)
        case (.male, .moderate):
            (19.12, 3.68, 8.62, 20.28)
        case (.male, .active):
            (-388.19, 3.68, 12.66, 20.46)
        case (.female, .low):
            (55.59, -22.25, 8.43, 17.07)
        case (.female, .moderate):
            (-297.54, -22.25, 12.77, 14.73)
        case (.female, .active):
            (-189.55, -22.25, 11.74, 18.34)
        }
    }

    private static func growthEnergy(for gender: Gender, age: Int) -> Double {
        switch (gender, age) {
        case (.male, 3):
            20
        case (.male, 4...8), (.female, 3...8):
            15
        case (.male, 9...13):
            25
        case (.female, 9...13):
            30
        case (_, 14...18):
            20
        default:
            0
        }
    }
}

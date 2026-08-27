import Foundation
import Observation

struct DailyCaloriePoint: Identifiable {
    let date: Date
    let calories: Double
    let isBeforeSignup: Bool

    var id: Date { date }
}

@Observable
final class HomeViewModel {
    let profile: UserProfile
    private let mealRecordStore: MealRecordStore
    private let calendar: Calendar

    private(set) var recommendation: NutritionRecommendation
    private(set) var todayNutrition = NutritionValues.zero
    private(set) var dailyCaloriePoints: [DailyCaloriePoint] = []

    init(
        profile: UserProfile,
        mealRecordStore: MealRecordStore,
        calendar: Calendar = .current
    ) {
        self.profile = profile
        self.mealRecordStore = mealRecordStore
        self.calendar = calendar
        recommendation = NutritionCalculator.recommendation(
            for: profile,
            calendar: calendar
        ) ?? .fallback
        reload()
    }

    var calorieProgress: Double {
        progress(consumed: todayNutrition.calories, recommended: recommendation.calories)
    }

    var feedbackMessage: String {
        HealthFeedbackProvider.message(
            consumed: todayNutrition,
            recommended: recommendation
        )
    }

    var yAxisMaximum: Double {
        let highestValue = max(
            recommendation.calories,
            dailyCaloriePoints.map(\.calories).max() ?? 0
        )
        return max(1_000, ceil(highestValue * 1.2 / 500) * 500)
    }

    var yAxisStride: Double {
        yAxisMaximum <= 4_000 ? 500 : 1_000
    }

    var initialChartDate: Date {
        dailyCaloriePoints.suffix(7).first?.date ?? calendar.startOfDay(for: .now)
    }

    func reload(now: Date = .now) {
        recommendation = NutritionCalculator.recommendation(
            for: profile,
            calendar: calendar,
            now: now
        ) ?? .fallback

        let today = calendar.startOfDay(for: now)
        let firstDate = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        let endDate = calendar.date(byAdding: .day, value: 1, to: today) ?? now
        let records = (try? mealRecordStore.records(
            for: profile.kakaoUserID,
            from: firstDate,
            to: endDate
        )) ?? []

        todayNutrition = totalNutrition(
            records.filter { calendar.isDate($0.recordedAt, inSameDayAs: today) }
        )

        let signupDate = calendar.startOfDay(for: profile.createdAt)
        dailyCaloriePoints = (0..<28).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDate) else {
                return nil
            }
            let calories = records
                .filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
                .reduce(0) { $0 + $1.calories }

            return DailyCaloriePoint(
                date: date,
                calories: calories,
                isBeforeSignup: date < signupDate
            )
        }
    }

    func progress(consumed: Double, recommended: Double) -> Double {
        guard recommended > 0 else { return 0 }
        return min(max(consumed / recommended, 0), 1)
    }

    private func totalNutrition(_ records: [MealRecord]) -> NutritionValues {
        records.reduce(.zero) { $0 + $1.nutritionValues }
    }
}

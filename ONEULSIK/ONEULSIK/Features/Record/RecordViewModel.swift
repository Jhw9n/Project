import Foundation
import Observation

@Observable
final class RecordViewModel {
    let profile: UserProfile

    private(set) var selectedDate: Date
    private(set) var records: [MealRecord] = []
    private(set) var recommendation: NutritionRecommendation

    private let mealRecordStore: MealRecordStore
    private var calendar: Calendar

    init(
        profile: UserProfile,
        mealRecordStore: MealRecordStore,
        selectedDate: Date = .now
    ) {
        self.profile = profile
        self.mealRecordStore = mealRecordStore
        self.selectedDate = selectedDate

        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 1
        self.calendar = calendar

        recommendation = NutritionCalculator.recommendation(
            for: profile,
            calendar: calendar
        ) ?? .fallback
        reload()
    }

    var weekDates: [Date] {
        guard let startDate = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else {
            return [selectedDate]
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
    }

    var monthTitle: String {
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        return "\(year)년 \(month)월"
    }

    var totalNutrition: NutritionValues {
        records.reduce(.zero) { $0 + $1.nutritionValues }
    }

    var calorieProgress: Double {
        progress(consumed: totalNutrition.calories, recommended: recommendation.calories)
    }

    func select(date: Date) {
        selectedDate = date
        reload()
    }

    func moveMonth(by value: Int) {
        guard let date = calendar.date(byAdding: .month, value: value, to: selectedDate) else { return }
        selectedDate = date
        reload()
    }

    func reload() {
        recommendation = NutritionCalculator.recommendation(
            for: profile,
            calendar: calendar
        ) ?? .fallback

        let startDate = calendar.startOfDay(for: selectedDate)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? selectedDate
        records = (try? mealRecordStore.records(
            for: profile.kakaoUserID,
            from: startDate,
            to: endDate
        )) ?? []
    }

    func records(for mealType: MealType) -> [MealRecord] {
        records.filter { $0.mealType == mealType }
    }

    func nutrition(for mealType: MealType) -> NutritionValues {
        records(for: mealType).reduce(.zero) { $0 + $1.nutritionValues }
    }

    func targetCalories(for mealType: MealType) -> Double {
        let ratio: Double = switch mealType {
        case .breakfast: 0.25
        case .lunch, .dinner: 0.3
        case .snack: 0.15
        }
        return recommendation.calories * ratio
    }

    func progress(consumed: Double, recommended: Double) -> Double {
        guard recommended > 0 else { return 0 }
        return min(max(consumed / recommended, 0), 1)
    }

    func delete(_ record: MealRecord) {
        try? mealRecordStore.delete(record)
        reload()
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func weekday(for date: Date) -> String {
        date.formatted(
            Date.FormatStyle()
                .weekday(.narrow)
                .locale(Locale(identifier: "ko_KR"))
        )
    }

    func day(for date: Date) -> String {
        date.formatted(.dateTime.day())
    }

    func dateText(_ date: Date) -> String {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(month)월 \(day)일"
    }
}

import Foundation

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: Self { self }

    var title: String {
        switch self {
        case .breakfast: "아침"
        case .lunch: "점심"
        case .dinner: "저녁"
        case .snack: "간식"
        }
    }

    var iconAssetName: String {
        switch self {
        case .breakfast: "mealBreakfast"
        case .lunch: "mealLunch"
        case .dinner: "mealDinner"
        case .snack: "mealSnack"
        }
    }

    var iconSize: CGSize {
        switch self {
        case .breakfast: CGSize(width: 23, height: 23)
        case .lunch: CGSize(width: 20, height: 20)
        case .dinner: CGSize(width: 26, height: 22)
        case .snack: CGSize(width: 24, height: 24)
        }
    }
}

import Foundation

enum ActivityLevel: String, CaseIterable, Identifiable {
    case low
    case moderate
    case active

    var id: Self { self }

    var title: String {
        switch self {
        case .low:
            "낮음"
        case .moderate:
            "보통"
        case .active:
            "활발"
        }
    }

    var description: String {
        switch self {
        case .low:
            "주로 앉아서 생활하며 규칙적인 운동이 거의 없어요"
        case .moderate:
            "주 3~5회 가벼운 운동이나 활동을 해요"
        case .active:
            "주 5회 이상 강도 높은 운동이나 활동을 해요"
        }
    }
}

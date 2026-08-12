import Foundation

enum Gender: String, CaseIterable, Identifiable {
    case male
    case female

    var id: Self { self }

    var title: String {
        switch self {
        case .male:
            "남자"
        case .female:
            "여자"
        }
    }

    var imageName: String {
        switch self {
        case .male:
            "onboardingMan"
        case .female:
            "onboardingWoman"
        }
    }
}

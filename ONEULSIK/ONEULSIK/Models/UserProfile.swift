import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var kakaoUserID: Int64
    var nickname: String
    var genderRawValue: String?
    var birthDate: Date?
    var heightCM: Int?
    var weightTenthsKG: Int?
    var activityLevelRawValue: String?
    var hasCompletedOnboarding: Bool
    var createdAt: Date

    init(
        kakaoUserID: Int64,
        nickname: String,
        genderRawValue: String? = nil,
        birthDate: Date? = nil,
        heightCM: Int? = nil,
        weightTenthsKG: Int? = nil,
        activityLevelRawValue: String? = nil,
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = .now
    ) {
        self.kakaoUserID = kakaoUserID
        self.nickname = nickname
        self.genderRawValue = genderRawValue
        self.birthDate = birthDate
        self.heightCM = heightCM
        self.weightTenthsKG = weightTenthsKG
        self.activityLevelRawValue = activityLevelRawValue
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
    }
}

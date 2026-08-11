import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var kakaoUserID: Int64
    var nickname: String
    var hasCompletedOnboarding: Bool
    var createdAt: Date

    init(
        kakaoUserID: Int64,
        nickname: String,
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = .now
    ) {
        self.kakaoUserID = kakaoUserID
        self.nickname = nickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
    }
}

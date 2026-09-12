import Foundation
import SwiftData

@Model
final class WeightRecord {
    var kakaoUserID: Int64
    var recordedAt: Date
    var weightTenthsKG: Int

    init(
        kakaoUserID: Int64,
        recordedAt: Date = .now,
        weightTenthsKG: Int
    ) {
        self.kakaoUserID = kakaoUserID
        self.recordedAt = recordedAt
        self.weightTenthsKG = weightTenthsKG
    }
}

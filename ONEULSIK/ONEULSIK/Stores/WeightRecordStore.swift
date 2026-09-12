import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class WeightRecordStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func records(for kakaoUserID: Int64) throws -> [WeightRecord] {
        let predicate = #Predicate<WeightRecord> { record in
            record.kakaoUserID == kakaoUserID
        }
        let descriptor = FetchDescriptor<WeightRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.recordedAt)]
        )

        return try modelContext.fetch(descriptor)
    }

    func ensureInitialRecord(for profile: UserProfile) throws {
        guard let weightTenthsKG = profile.weightTenthsKG,
              try records(for: profile.kakaoUserID).isEmpty else {
            return
        }

        modelContext.insert(
            WeightRecord(
                kakaoUserID: profile.kakaoUserID,
                recordedAt: profile.createdAt,
                weightTenthsKG: weightTenthsKG
            )
        )
        try modelContext.save()
    }
}

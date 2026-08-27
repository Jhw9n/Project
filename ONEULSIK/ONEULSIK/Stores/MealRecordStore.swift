import Foundation
import Observation
import SwiftData

@Observable
final class MealRecordStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func records(
        for kakaoUserID: Int64,
        from startDate: Date,
        to endDate: Date
    ) throws -> [MealRecord] {
        let predicate = #Predicate<MealRecord> { record in
            record.kakaoUserID == kakaoUserID
                && record.recordedAt >= startDate
                && record.recordedAt < endDate
        }
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.recordedAt)]
        )

        return try modelContext.fetch(descriptor)
    }

    func insert(_ record: MealRecord) throws {
        modelContext.insert(record)
        try modelContext.save()
    }

    static var preview: MealRecordStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: UserProfile.self,
            MealRecord.self,
            configurations: configuration
        )
        return MealRecordStore(modelContext: container.mainContext)
    }
}

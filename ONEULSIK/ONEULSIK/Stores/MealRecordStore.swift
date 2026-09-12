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

    func insert(
        food: FoodCatalogItem,
        servingCount: Double,
        mealType: MealType,
        recordedAt: Date,
        kakaoUserID: Int64
    ) throws {
        let nutrition = food.nutrition(for: servingCount)
        let record = MealRecord(
            kakaoUserID: kakaoUserID,
            recordedAt: recordedAt,
            mealTypeRawValue: mealType.rawValue,
            foodID: food.id,
            foodName: food.name,
            servingUnit: food.servingUnit,
            servingGrams: food.servingGrams,
            servingCount: servingCount,
            calories: nutrition.calories,
            carbohydrateGrams: nutrition.carbohydrateGrams,
            proteinGrams: nutrition.proteinGrams,
            fatGrams: nutrition.fatGrams
        )
        try insert(record)
    }

    func delete(_ record: MealRecord) throws {
        modelContext.delete(record)
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

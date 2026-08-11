import Observation
import SwiftData

@MainActor
@Observable
final class OnboardingStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveGender(_ gender: Gender, for profile: UserProfile) throws {
        profile.genderRawValue = gender.rawValue
        try modelContext.save()
    }
}

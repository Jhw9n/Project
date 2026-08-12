import Observation

@MainActor
@Observable
final class HeightOnboardingViewModel {
    var selectedHeight: Int

    let heightRange = 100...220

    private let profile: UserProfile
    private let onboardingStore: OnboardingStore

    init(profile: UserProfile, onboardingStore: OnboardingStore) {
        self.profile = profile
        self.onboardingStore = onboardingStore
        self.selectedHeight = profile.heightCM ?? 180
    }

    func saveSelection() throws {
        try onboardingStore.saveHeight(selectedHeight, for: profile)
    }
}

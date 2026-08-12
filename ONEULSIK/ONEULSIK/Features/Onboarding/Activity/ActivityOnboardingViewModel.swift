import Observation

@MainActor
@Observable
final class ActivityOnboardingViewModel {
    private(set) var selectedLevel: ActivityLevel?

    var isNextEnabled: Bool {
        selectedLevel != nil
    }

    var selectedDescription: String? {
        selectedLevel?.description
    }

    private let profile: UserProfile
    private let onboardingStore: OnboardingStore

    init(profile: UserProfile, onboardingStore: OnboardingStore) {
        self.profile = profile
        self.onboardingStore = onboardingStore
        self.selectedLevel = profile.activityLevelRawValue.flatMap(
            ActivityLevel.init(rawValue:)
        )
    }

    func select(_ level: ActivityLevel) {
        selectedLevel = level
    }

    func completeOnboarding() throws {
        guard let selectedLevel else { return }
        try onboardingStore.completeOnboarding(
            with: selectedLevel,
            for: profile
        )
    }
}

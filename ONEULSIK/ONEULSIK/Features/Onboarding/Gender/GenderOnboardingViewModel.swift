import Observation

@MainActor
@Observable
final class GenderOnboardingViewModel {
    private(set) var selectedGender: Gender?

    var isNextEnabled: Bool {
        selectedGender != nil
    }

    private let profile: UserProfile
    private let onboardingStore: OnboardingStore

    init(profile: UserProfile, onboardingStore: OnboardingStore) {
        self.profile = profile
        self.onboardingStore = onboardingStore
        self.selectedGender = profile.genderRawValue.flatMap(Gender.init(rawValue:))
    }

    func select(_ gender: Gender) {
        selectedGender = gender
    }

    func saveSelection() throws {
        guard let selectedGender else { return }
        try onboardingStore.saveGender(selectedGender, for: profile)
    }
}

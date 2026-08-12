import Foundation
import Observation

@MainActor
@Observable
final class WeightOnboardingViewModel {
    var selectedWeight: Int

    let weightRange = 300...2000

    var formattedWeight: String {
        if selectedWeight.isMultiple(of: 10) {
            return "\(selectedWeight / 10)"
        }

        return String(format: "%.1f", Double(selectedWeight) / 10)
    }

    private let profile: UserProfile
    private let onboardingStore: OnboardingStore

    init(profile: UserProfile, onboardingStore: OnboardingStore) {
        self.profile = profile
        self.onboardingStore = onboardingStore
        self.selectedWeight = profile.weightTenthsKG ?? 700
    }

    func saveSelection() throws {
        try onboardingStore.saveWeight(selectedWeight, for: profile)
    }
}

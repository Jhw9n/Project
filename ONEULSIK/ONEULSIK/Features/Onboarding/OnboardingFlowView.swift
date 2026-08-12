import SwiftUI

struct OnboardingFlowView: View {
    enum Step {
        case gender
        case birthday
    }

    @State private var step: Step

    let profile: UserProfile
    let onboardingStore: OnboardingStore
    let onExit: () -> Void

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        onExit: @escaping () -> Void
    ) {
        self.profile = profile
        self.onboardingStore = onboardingStore
        self.onExit = onExit
        _step = State(initialValue: profile.genderRawValue == nil ? .gender : .birthday)
    }

    var body: some View {
        switch step {
        case .gender:
            GenderOnboardingView(
                profile: profile,
                onboardingStore: onboardingStore,
                onBack: onExit
            ) {
                step = .birthday
            }

        case .birthday:
            BirthdayOnboardingView(
                profile: profile,
                onboardingStore: onboardingStore
            ) {
                step = .gender
            } onNext: {
            }
        }
    }
}

import SwiftUI

struct OnboardingFlowView: View {
    enum Step {
        case gender
        case birthday
        case height
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
        let initialStep: Step
        if profile.genderRawValue == nil {
            initialStep = .gender
        } else if profile.birthDate == nil {
            initialStep = .birthday
        } else {
            initialStep = .height
        }
        _step = State(initialValue: initialStep)
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
                step = .height
            }

        case .height:
            HeightOnboardingView(
                profile: profile,
                onboardingStore: onboardingStore
            ) {
                step = .birthday
            } onNext: {
            }
        }
    }
}

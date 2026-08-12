import SwiftData
import SwiftUI

struct ActivityOnboardingView: View {
    @State private var viewModel: ActivityOnboardingViewModel

    let onBack: () -> Void

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        onBack: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: ActivityOnboardingViewModel(
                profile: profile,
                onboardingStore: onboardingStore
            )
        )
        self.onBack = onBack
    }

    var body: some View {
        OnboardingScaffold(
            title: "당신의 활동 수준을 알려주세요!",
            contentTopPadding: 184,
            isNextEnabled: viewModel.isNextEnabled,
            onBack: onBack
        ) {
            do {
                try viewModel.completeOnboarding()
            } catch {
                return
            }
        } content: {
            activitySelection
        }
    }

    private var activitySelection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(ActivityLevel.allCases) { level in
                    activityButton(for: level)
                }
            }

            if let description = viewModel.selectedDescription {
                Text(description)
                    .font(.pretendardSemiBold(12))
                    .foregroundStyle(Color("green03"))
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedLevel)
    }

    private func activityButton(for level: ActivityLevel) -> some View {
        let isSelected = viewModel.selectedLevel == level

        return Button {
            viewModel.select(level)
        } label: {
            Text(level.title)
                .font(.pretendardBold(18))
                .foregroundStyle(Color("gray01"))
                .frame(width: 96, height: 96)
                .background(isSelected ? Color("green03") : Color("gray02"))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(level.description)
    }
}

#Preview("활동 수준 온보딩") {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self,
        configurations: configuration
    )
    let profile = UserProfile(
        kakaoUserID: 1,
        nickname: "오늘식",
        genderRawValue: Gender.male.rawValue,
        birthDate: .now,
        heightCM: 180,
        weightTenthsKG: 700
    )

    container.mainContext.insert(profile)

    return ActivityOnboardingView(
        profile: profile,
        onboardingStore: OnboardingStore(modelContext: container.mainContext),
        onBack: {}
    )
    .modelContainer(container)
}

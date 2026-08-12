import SwiftData
import SwiftUI

struct BirthdayOnboardingView: View {
    @State private var viewModel: BirthdayOnboardingViewModel

    let onBack: () -> Void
    let onNext: () -> Void

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: BirthdayOnboardingViewModel(
                profile: profile,
                onboardingStore: onboardingStore
            )
        )
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        OnboardingScaffold(
            title: "당신의 생년월일을 알려주세요!",
            contentTopPadding: 104,
            isNextEnabled: true,
            onBack: onBack
        ) {
            do {
                try viewModel.saveSelection()
                onNext()
            } catch {
                return
            }
        } content: {
            birthdayPicker
        }
    }

    private var birthdayPicker: some View {
        ZStack(alignment: .leading) {
            DatePicker(
                "생년월일",
                selection: $viewModel.selectedDate,
                in: viewModel.dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .frame(maxWidth: .infinity)
            .frame(height: 216)
            .clipped()

            Image(systemName: "play.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color("green03"))
                .padding(.leading,60)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 286)
    }
}

#Preview("생년월일 온보딩") {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self,
        configurations: configuration
    )
    let profile = UserProfile(
        kakaoUserID: 1,
        nickname: "오늘식",
        genderRawValue: Gender.male.rawValue
    )

    container.mainContext.insert(profile)

    return BirthdayOnboardingView(
        profile: profile,
        onboardingStore: OnboardingStore(modelContext: container.mainContext),
        onBack: {},
        onNext: {}
    )
    .modelContainer(container)
}

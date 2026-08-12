import SwiftData
import SwiftUI

struct WeightOnboardingView: View {
    @State private var viewModel: WeightOnboardingViewModel

    let onBack: () -> Void
    let onNext: () -> Void

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: WeightOnboardingViewModel(
                profile: profile,
                onboardingStore: onboardingStore
            )
        )
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        OnboardingScaffold(
            title: "당신의 몸무게를 알려주세요!",
            contentTopPadding: 0,
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
            weightPicker
        }
    }

    private var weightPicker: some View {
        GeometryReader { proxy in
            ZStack {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(viewModel.formattedWeight)
                        .font(.pretendardSemiBold(48))

                    Text("kg")
                        .font(.pretendardMedium(24))
                }
                .foregroundStyle(Color("black01"))
                .position(x: proxy.size.width / 2, y: proxy.size.height * 0.4)

                RadialRulerPicker(
                    selection: $viewModel.selectedWeight,
                    range: viewModel.weightRange
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

#Preview("몸무게 온보딩") {
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
        heightCM: 180
    )

    container.mainContext.insert(profile)

    return WeightOnboardingView(
        profile: profile,
        onboardingStore: OnboardingStore(modelContext: container.mainContext),
        onBack: {},
        onNext: {}
    )
    .modelContainer(container)
}

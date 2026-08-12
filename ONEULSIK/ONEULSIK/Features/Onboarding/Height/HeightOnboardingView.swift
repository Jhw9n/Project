import SwiftData
import SwiftUI

struct HeightOnboardingView: View {
    @State private var viewModel: HeightOnboardingViewModel

    let onBack: () -> Void
    let onNext: () -> Void

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: HeightOnboardingViewModel(
                profile: profile,
                onboardingStore: onboardingStore
            )
        )
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        OnboardingScaffold(
            title: "당신의 키를 알려주세요!",
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
            heightPicker
        }
    }

    private var heightPicker: some View {
        GeometryReader { proxy in
            ZStack {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(viewModel.selectedHeight)")
                        .font(.pretendardSemiBold(48))

                    Text("cm")
                        .font(.pretendardMedium(24))
                }
                .foregroundStyle(Color("black01"))
                .offset(y: -42)

                VerticalRulerPicker(
                    selection: $viewModel.selectedHeight,
                    range: viewModel.heightRange
                )
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .offset(y: -42)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

#Preview("키 온보딩") {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self,
        configurations: configuration
    )
    let profile = UserProfile(
        kakaoUserID: 1,
        nickname: "오늘식",
        genderRawValue: Gender.male.rawValue,
        birthDate: .now
    )

    container.mainContext.insert(profile)

    return HeightOnboardingView(
        profile: profile,
        onboardingStore: OnboardingStore(modelContext: container.mainContext),
        onBack: {},
        onNext: {}
    )
    .modelContainer(container)
}

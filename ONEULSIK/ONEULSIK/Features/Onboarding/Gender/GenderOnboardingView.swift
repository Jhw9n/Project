import SwiftUI
import SwiftData

struct GenderOnboardingView: View {
    @State private var viewModel: GenderOnboardingViewModel

    let onBack: () -> Void
    let onNext: () -> Void

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: GenderOnboardingViewModel(
                profile: profile,
                onboardingStore: onboardingStore
            )
        )
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Text("당신의 성별을 알려주세요!")
                .font(.pretendardSemiBold(18))
                .foregroundStyle(Color("black01"))
                .padding(.top, 40)

            genderSelection
                .padding(.top, 140)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("gray01").ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OnboardingBottomButton(
                title: "다음",
                isEnabled: viewModel.isNextEnabled
            ) {
                do {
                    try viewModel.saveSelection()
                    onNext()
                } catch {
                    return
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .background(Color("gray01"))
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color("black01"))
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("로그인 화면으로 돌아가기")

            Spacer()
        }
        .frame(height: 56)
    }

    private var genderSelection: some View {
        HStack(spacing: 0) {
            genderButton(for: .male)

            Rectangle()
                .fill(Color("gray02"))
                .frame(width: 1, height: 158)

            genderButton(for: .female)
        }
        .frame(height: 158)
    }

    private func genderButton(for gender: Gender) -> some View {
        let isSelected = viewModel.selectedGender == gender
        let foregroundColor = isSelected ? Color("green03") : Color("gray02")

        return Button {
            viewModel.select(gender)
        } label: {
            VStack(spacing: 12) {
                Image(gender.imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text(gender.title)
                    .font(.pretendardBold(14))
            }
            .foregroundStyle(foregroundColor)
            .frame(width: 134, height: 158, alignment: .top)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("성별 온보딩") {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self,
        configurations: configuration
    )
    let profile = UserProfile(
        kakaoUserID: 1,
        nickname: "오늘식"
    )

    container.mainContext.insert(profile)

    return GenderOnboardingView(
        profile: profile,
        onboardingStore: OnboardingStore(modelContext: container.mainContext),
        onBack: {},
        onNext: {}
    )
    .modelContainer(container)
}

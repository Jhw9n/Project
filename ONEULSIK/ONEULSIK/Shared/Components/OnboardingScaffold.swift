import SwiftUI

struct OnboardingScaffold<Content: View>: View {
    let title: String
    let contentTopPadding: CGFloat
    let isNextEnabled: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            header

            Text(title)
                .font(.pretendardSemiBold(18))
                .foregroundStyle(Color("black01"))
                .padding(.top, 40)

            content()
                .padding(.top, contentTopPadding)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("gray01").ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OnboardingBottomButton(
                title: "다음",
                isEnabled: isNextEnabled,
                action: onNext
            )
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
            .accessibilityLabel("이전 화면으로 돌아가기")

            Spacer()
        }
        .frame(height: 56)
    }
}

import SwiftUI

struct OnboardingBottomButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.pretendardSemiBold(16))
                .foregroundStyle(Color("gray01"))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? Color("green03") : Color("gray04"))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

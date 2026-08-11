import SwiftUI

struct KakaoLoginView: View {
    let isLoading: Bool
    let errorMessage: String?
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("오늘식")
                    .font(.pretendardExtraBold(32))

                Text("오늘의 식사를 가볍게 기록해 보세요")
                    .font(.pretendardRegular(16))
                    .foregroundStyle(Color("gray09"))
            }

            Spacer()

            if let errorMessage {
                Text(errorMessage)
                    .font(.pretendardRegular(14))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: onLogin) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(Color("black01"))
                    }

                    Text("카카오로 시작하기")
                        .font(.pretendardSemiBold(16))
                        .foregroundStyle(Color("black01"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color("yellow03"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(Color("white01"))
    }
}

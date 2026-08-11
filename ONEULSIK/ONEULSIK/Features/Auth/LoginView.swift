import SwiftUI

struct KakaoLoginView: View {
    let onLogin: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color("green03")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    brand

                    Spacer(minLength: 32)

                    kakaoLoginButton
                }
                .padding(.top, proxy.size.height * 0.389)
                .padding(.bottom, proxy.size.height * 0.214)

            }
        }
        .preferredColorScheme(.light)
    }

    private var brand: some View {
        VStack(spacing: 24) {
            Image("oneulsikLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 50)

            Text("오늘의 식사를 더 건강하게")
                .font(.pretendardSemiBold(18))
                .foregroundStyle(.white)
                .lineSpacing(7)
        }
    }

    private var kakaoLoginButton: some View {
        Button(action: onLogin) {
            ZStack {
                Circle()
                    .fill(Color(red: 254 / 255, green: 229 / 255, blue: 0))

                Image("kakaoTalkIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
            .frame(width: 68, height: 68)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("카카오로 로그인")
    }
}

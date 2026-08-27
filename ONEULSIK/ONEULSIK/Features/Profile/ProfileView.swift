import SwiftUI

struct ProfileView: View {
    let profile: UserProfile
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("\(profile.nickname)님의 프로필")
                .font(.pretendardBold(24))
                .foregroundStyle(Color.black01)

            Button("로그아웃", action: onLogout)
                .font(.pretendardSemiBold(16))
                .foregroundStyle(Color.green03)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray01.ignoresSafeArea())
    }
}

#Preview {
    ProfileView(
        profile: UserProfile(kakaoUserID: 1, nickname: "박정환"),
        onLogout: {}
    )
}

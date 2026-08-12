import SwiftUI

struct HomeView: View {
    let profile: UserProfile

    var body: some View {
        ZStack {
            Color.gray01
                .ignoresSafeArea()

            Text("\(profile.nickname)님의 홈")
                .font(.pretendardBold(24))
                .foregroundStyle(Color.black01)
        }
    }
}

#Preview {
    HomeView(profile: UserProfile(kakaoUserID: 1, nickname: "박정환"))
}

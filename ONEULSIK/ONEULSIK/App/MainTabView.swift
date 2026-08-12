import SwiftUI

struct MainTabView: View {
    let profile: UserProfile
    let onLogout: () -> Void

    @State private var selectedTab = MainTab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(profile: profile)
                .tag(MainTab.home)

            RecordView()
                .tag(MainTab.record)

            ProfileView(profile: profile, onLogout: onLogout)
                .tag(MainTab.profile)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MainTabBar(selectedTab: $selectedTab)
        }
    }
}

private enum MainTab: CaseIterable {
    case home
    case record
    case profile

    var title: String {
        switch self {
        case .home: "홈"
        case .record: "기록"
        case .profile: "내정보"
        }
    }

    var iconName: String {
        switch self {
        case .home: "tabHome"
        case .record: "tabRecord"
        case .profile: "tabProfile"
        }
    }

    var iconSize: CGSize {
        switch self {
        case .home, .record: CGSize(width: 20, height: 20)
        case .profile: CGSize(width: 17, height: 19)
        }
    }
}

private struct MainTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(tab.iconName)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: tab.iconSize.width, height: tab.iconSize.height)
                            .frame(width: 24, height: 24)

                        Text(tab.title)
                            .font(.pretendardSemiBold(12))
                    }
                    .foregroundStyle(selectedTab == tab ? Color.tabGreen : Color.gray02)
                    .frame(width: 81.25)
                    .padding(.top, 14)
                    .padding(.bottom, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])

                if tab != MainTab.allCases.last {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
            .fill(Color.white)
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay {
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
            .stroke(Color(red: 221 / 255, green: 223 / 255, blue: 230 / 255), lineWidth: 1)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    MainTabView(
        profile: UserProfile(kakaoUserID: 1, nickname: "박정환"),
        onLogout: {}
    )
}

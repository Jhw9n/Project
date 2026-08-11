//
//  ContentView.swift
//  ONEULSIK
//
//  Created by 박정환 on 8/5/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        Group {
            if let profile = authStore.currentProfile {
                VStack(spacing: 20) {
                    Text("\(profile.nickname)님, 반가워요")
                        .font(.pretendardBold(24))

                    Text("카카오 로그인과 로컬 프로필 저장이 완료되었습니다.")
                        .font(.pretendardRegular(15))
                        .foregroundStyle(Color("gray09"))

                    Button("로그아웃") {
                        Task {
                            await authStore.logout()
                        }
                    }
                    .font(.pretendardSemiBold(16))
                }
                .padding()
            } else {
                KakaoLoginView {
                    Task {
                        await authStore.login()
                    }
                }
            }
        }
        .task {
            await authStore.restoreSession()
        }
    }
}

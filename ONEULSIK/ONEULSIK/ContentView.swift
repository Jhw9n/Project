//
//  ContentView.swift
//  ONEULSIK
//
//  Created by 박정환 on 8/5/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(OnboardingStore.self) private var onboardingStore

    var body: some View {
        Group {
            if let profile = authStore.currentProfile {
                if profile.hasCompletedOnboarding {
                    VStack(spacing: 20) {
                        Text("\(profile.nickname)님, 반가워요")
                            .font(.pretendardBold(24))

                        Button("로그아웃") {
                            Task {
                                await authStore.logout()
                            }
                        }
                        .font(.pretendardSemiBold(16))
                    }
                    .padding()
                } else {
                    GenderOnboardingView(
                        profile: profile,
                        onboardingStore: onboardingStore
                    ) {
                        Task {
                            await authStore.logout()
                        }
                    } onNext: {
                    }
                }
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

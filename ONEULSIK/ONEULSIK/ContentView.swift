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
    @Environment(MealRecordStore.self) private var mealRecordStore

    var body: some View {
        Group {
            if let profile = authStore.currentProfile {
                if profile.hasCompletedOnboarding {
                    MainTabView(
                        profile: profile,
                        mealRecordStore: mealRecordStore
                    ) {
                        Task {
                            await authStore.logout()
                        }
                    }
                } else {
                    OnboardingFlowView(
                        profile: profile,
                        onboardingStore: onboardingStore
                    ) {
                        Task {
                            await authStore.logout()
                        }
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

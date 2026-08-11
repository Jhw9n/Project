//
//  ONEULSIKApp.swift
//  ONEULSIK
//
//  Created by 박정환 on 8/5/26.
//

import KakaoSDKAuth
import KakaoSDKCommon
import SwiftData
import SwiftUI

@main
struct ONEULSIKApp: App {
    private let modelContainer: ModelContainer
    @State private var authStore: AuthStore

    init() {
        do {
            let modelContainer = try ModelContainer(for: UserProfile.self)
            self.modelContainer = modelContainer
            _authStore = State(
                initialValue: AuthStore(modelContext: modelContainer.mainContext)
            )
        } catch {
            fatalError("SwiftData ModelContainer 생성 실패: \(error)")
        }

        if let appKey = AppConfiguration.kakaoNativeAppKey {
            KakaoSDK.initSDK(appKey: appKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}

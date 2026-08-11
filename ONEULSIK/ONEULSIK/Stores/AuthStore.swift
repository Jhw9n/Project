import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AuthStore {
    private(set) var currentProfile: UserProfile?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let modelContext: ModelContext
    private let authService: KakaoAuthService
    private var didRestoreSession = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.authService = KakaoAuthService()
    }

    init(modelContext: ModelContext, authService: KakaoAuthService) {
        self.modelContext = modelContext
        self.authService = authService
    }

    func restoreSession() async {
        guard !didRestoreSession else { return }
        didRestoreSession = true

        guard AppConfiguration.kakaoNativeAppKey != nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let kakaoUser = try await authService.restoreUser()
            currentProfile = try loadOrCreateProfile(for: kakaoUser)
        } catch {
            currentProfile = nil
        }
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let kakaoUser = try await authService.login()
            currentProfile = try loadOrCreateProfile(for: kakaoUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await authService.logout()
            currentProfile = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadOrCreateProfile(for kakaoUser: KakaoUser) throws -> UserProfile {
        let userID = kakaoUser.id
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { profile in
                profile.kakaoUserID == userID
            }
        )

        if let profile = try modelContext.fetch(descriptor).first {
            profile.nickname = kakaoUser.nickname
            try modelContext.save()
            return profile
        }

        let profile = UserProfile(
            kakaoUserID: kakaoUser.id,
            nickname: kakaoUser.nickname
        )
        modelContext.insert(profile)
        try modelContext.save()
        return profile
    }
}

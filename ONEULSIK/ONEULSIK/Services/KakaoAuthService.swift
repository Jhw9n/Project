import Foundation
import KakaoSDKUser

struct KakaoUser {
    let id: Int64
    let nickname: String
}

enum KakaoAuthError: LocalizedError {
    case missingNativeAppKey
    case missingToken
    case missingUserID

    var errorDescription: String? {
        switch self {
        case .missingNativeAppKey:
            return "Config.local.xcconfig에 카카오 네이티브 앱 키를 입력해 주세요."
        case .missingToken:
            return "카카오 로그인 토큰을 받지 못했습니다."
        case .missingUserID:
            return "카카오 사용자 정보를 확인하지 못했습니다."
        }
    }
}

@MainActor
final class KakaoAuthService {
    func login() async throws -> KakaoUser {
        guard AppConfiguration.kakaoNativeAppKey != nil else {
            throw KakaoAuthError.missingNativeAppKey
        }

        if UserApi.isKakaoTalkLoginAvailable() {
            try await loginWithKakaoTalk()
        } else {
            try await loginWithKakaoAccount()
        }

        return try await fetchCurrentUser()
    }

    func restoreUser() async throws -> KakaoUser {
        guard AppConfiguration.kakaoNativeAppKey != nil else {
            throw KakaoAuthError.missingNativeAppKey
        }

        return try await fetchCurrentUser()
    }

    func logout() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func loginWithKakaoTalk() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if token != nil {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: KakaoAuthError.missingToken)
                }
            }
        }
    }

    private func loginWithKakaoAccount() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if token != nil {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: KakaoAuthError.missingToken)
                }
            }
        }
    }

    private func fetchCurrentUser() async throws -> KakaoUser {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let userID = user?.id else {
                    continuation.resume(throwing: KakaoAuthError.missingUserID)
                    return
                }

                let nickname = user?.kakaoAccount?.profile?.nickname ?? "오늘식 사용자"
                continuation.resume(returning: KakaoUser(id: userID, nickname: nickname))
            }
        }
    }
}

import Foundation

enum AppConfiguration {
    static var kakaoNativeAppKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty,
              !trimmedValue.hasPrefix("$("),
              trimmedValue != "YOUR_NATIVE_APP_KEY" else {
            return nil
        }

        return trimmedValue
    }
}

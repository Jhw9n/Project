import Foundation
import FoundationModels

enum AIWeeklyReportError: LocalizedError, Equatable {
    case modelUnavailable
    case modelNotReady
    case generationRejected
    case emptyResponse
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Apple Intelligence를 사용할 수 없습니다."
        case .modelNotReady:
            "언어 모델을 준비하고 있습니다. 잠시 후 다시 시도해주세요."
        case .generationRejected:
            "요청한 피드백을 생성하지 못했습니다."
        case .emptyResponse, .generationFailed:
            "피드백을 생성하지 못했습니다."
        }
    }
}

@MainActor
struct AIWeeklyReportService {
    private struct CacheEntry: Codable {
        let signature: String
        let message: String
    }

    private let userDefaults: UserDefaults
    private let calendar: Calendar

    init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
    }

    func cachedReport(for input: AIWeeklyReportInput) -> String? {
        guard
            let data = userDefaults.data(forKey: cacheKey(for: input)),
            let entry = try? JSONDecoder().decode(CacheEntry.self, from: data),
            entry.signature == signature(for: input)
        else {
            return nil
        }

        return entry.message
    }

    func generateReport(for input: AIWeeklyReportInput) async throws -> String {
        if let cachedReport = cachedReport(for: input) {
            return cachedReport
        }

        guard #available(iOS 26.0, *) else {
            throw AIWeeklyReportError.modelUnavailable
        }
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw AIWeeklyReportError.modelUnavailable
        }

        let message: String
        do {
            message = try await requestReport(for: input)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch let error as LanguageModelSession.GenerationError {
            throw mappedError(error)
        } catch {
            throw AIWeeklyReportError.generationFailed
        }
        guard !message.isEmpty else {
            throw AIWeeklyReportError.emptyResponse
        }

        let entry = CacheEntry(
            signature: signature(for: input),
            message: message
        )
        if let data = try? JSONEncoder().encode(entry) {
            userDefaults.set(data, forKey: cacheKey(for: input))
        }

        return message
    }

    @available(iOS 26.0, *)
    private func requestReport(for input: AIWeeklyReportInput) async throws -> String {
        let session = LanguageModelSession(
            instructions: """
            당신은 식단 기록 앱의 친근한 영양 코치입니다.
            자연스러운 한국어 존댓말로만 작성하세요.
            말투는 부드럽게 '~했어요', '~해보세요' 형태를 사용하세요.
            앱이 계산한 영양 상태를 사실 그대로 사용하고 부족과 많음을 바꾸지 마세요.
            기록된 음식명이나 식사 시간을 추측하지 마세요.
            가장 눈에 띄는 영양 상태 한 가지와 실천하기 쉬운 제안 한 가지만 전달하세요.
            제안할 음식은 예시로 언급할 수 있지만 사용자가 먹었다고 단정하지 마세요.
            제공되지 않은 식이섬유, 당류, 나트륨, 비타민 등의 상태는 언급하지 마세요.
            영어, 외래어 혼용, 딱딱한 보고서체를 사용하지 마세요.
            """
        )
        let response = try await session.respond(
            to: prompt(for: input),
            options: GenerationOptions(
                temperature: 0.7,
                maximumResponseTokens: 80
            )
        )
        let feedback = response.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
        return "기록된 \(input.recordedDays.count)일 기준, \(firstSentences(feedback, limit: 2))"
    }

    private func prompt(for input: AIWeeklyReportInput) -> String {
        let recordedDayCount = Double(input.recordedDays.count)
        let total = input.recordedDays.reduce(NutritionValues.zero) {
            $0 + $1.nutrition
        }
        let recommendation = input.recommendation
        let averageCalories = total.calories / recordedDayCount
        let averageCarbohydrates = total.carbohydrateGrams / recordedDayCount
        let averageProtein = total.proteinGrams / recordedDayCount
        let averageFat = total.fatGrams / recordedDayCount

        return """
        약 40~50자의 자연스러운 한국어 한 문단으로 작성해주세요.
        완성된 짧은 문장을 최대 두 개만 사용해주세요.
        두 번째 문장의 행동 제안 뒤에는 이유나 효과를 덧붙이지 마세요.
        답변에 기록 일수는 다시 언급하지 마세요.
        숫자, 단위, 비율, 부족하거나 초과한 정확한 양은 쓰지 마세요.
        아래 상태 중 가장 눈에 띄는 한 가지만 알려주고 간단한 행동을 제안해주세요.

        기록된 날짜의 하루 평균 상태:
        열량: \(status(averageCalories, comparedWith: recommendation.calories))
        탄수화물: \(status(averageCarbohydrates, comparedWith: recommendation.carbohydrateGrams))
        단백질: \(status(averageProtein, comparedWith: recommendation.proteinGrams))
        지방: \(status(averageFat, comparedWith: recommendation.fatGrams))
        """
    }

    private func status(_ value: Double, comparedWith recommendation: Double) -> String {
        guard recommendation > 0 else { return "판단하지 않음" }
        let ratio = value / recommendation
        if ratio < 0.8 { return "부족함" }
        if ratio > 1.2 { return "많음" }
        return "적정함"
    }

    @available(iOS 26.0, *)
    private func mappedError(
        _ error: LanguageModelSession.GenerationError
    ) -> AIWeeklyReportError {
        switch error {
        case .unsupportedLanguageOrLocale:
            .generationFailed
        case .assetsUnavailable:
            .modelNotReady
        case .guardrailViolation, .refusal:
            .generationRejected
        default:
            .generationFailed
        }
    }

    private func cacheKey(for input: AIWeeklyReportInput) -> String {
        let week = Int(input.weekStart.timeIntervalSince1970)
        return "aiWeeklyReport.v13.\(input.kakaoUserID).\(week)"
    }

    private func signature(for input: AIWeeklyReportInput) -> String {
        let dayValues = input.recordedDays.map { day in
            let nutrition = day.nutrition
            return [
                Int(day.date.timeIntervalSince1970),
                Int(nutrition.calories.rounded()),
                Int(nutrition.carbohydrateGrams.rounded()),
                Int(nutrition.proteinGrams.rounded()),
                Int(nutrition.fatGrams.rounded())
            ]
            .map(String.init)
            .joined(separator: ":")
        }

        let recommendation = input.recommendation
        let recommendationValues = [
            recommendation.calories,
            recommendation.carbohydrateGrams,
            recommendation.proteinGrams,
            recommendation.fatGrams
        ]
        .map { String(Int($0.rounded())) }
        .joined(separator: ":")

        return dayValues.joined(separator: "|") + "#" + recommendationValues
    }

    private func firstSentences(_ value: String, limit: Int) -> String {
        var sentenceCount = 0
        var result = ""

        for character in value {
            result.append(character)
            if ".!?。！？".contains(character) {
                sentenceCount += 1
                if sentenceCount == limit { break }
            }
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

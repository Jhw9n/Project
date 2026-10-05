import Foundation
import FoundationModels

struct AIWeeklyDetailPattern: Codable, Equatable {
    let title: String
    let description: String
}

struct AIWeeklyDetailReport: Codable, Equatable {
    let summary: String
    let patterns: [AIWeeklyDetailPattern]
    let goalTitle: String
    let goalDescription: String
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedAIWeeklyDetailReport {
    @Guide(description: "이번 주 식단의 핵심을 부드러운 한국어 두 문장 이내로 요약")
    var summary: String

    @Guide(description: "날짜별 열량 흐름에서 발견한 패턴의 짧은 제목")
    var caloriePatternTitle: String

    @Guide(description: "열량 패턴의 근거를 쉬운 한국어 한 문장으로 설명")
    var caloriePatternDescription: String

    @Guide(description: "탄수화물, 단백질, 지방에서 발견한 패턴의 짧은 제목")
    var nutritionPatternTitle: String

    @Guide(description: "영양 패턴의 근거를 쉬운 한국어 한 문장으로 설명")
    var nutritionPatternDescription: String

    @Guide(description: "다음 주에 실천할 수 있는 구체적인 목표 한 가지")
    var goalTitle: String

    @Guide(description: "목표를 부담 없이 실천하도록 돕는 짧은 설명 한 문장")
    var goalDescription: String
}

@MainActor
struct AIWeeklyDetailReportService {
    private struct CacheEntry: Codable {
        let signature: String
        let report: AIWeeklyDetailReport
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func cachedReport(for input: AIWeeklyReportInput) -> AIWeeklyDetailReport? {
        guard
            let data = userDefaults.data(forKey: cacheKey(for: input)),
            let entry = try? JSONDecoder().decode(CacheEntry.self, from: data),
            entry.signature == signature(for: input)
        else {
            return nil
        }

        return entry.report
    }

    func generateReport(for input: AIWeeklyReportInput) async throws -> AIWeeklyDetailReport {
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

        let report: AIWeeklyDetailReport
        do {
            report = try await requestReport(for: input)
        } catch let error as LanguageModelSession.GenerationError {
            throw mappedError(error)
        } catch let error as AIWeeklyReportError {
            throw error
        } catch {
            throw AIWeeklyReportError.generationFailed
        }

        let entry = CacheEntry(
            signature: signature(for: input),
            report: report
        )
        if let data = try? JSONEncoder().encode(entry) {
            userDefaults.set(data, forKey: cacheKey(for: input))
        }

        return report
    }

    @available(iOS 26.0, *)
    private func requestReport(for input: AIWeeklyReportInput) async throws -> AIWeeklyDetailReport {
        let session = LanguageModelSession(
            instructions: """
            당신은 공공 영양 기준을 바탕으로 식단을 분석하는 친근한 영양 코치입니다.
            자연스러운 한국어 존댓말로만 작성하세요.
            제공된 영양 상태와 날짜별 흐름을 바꾸거나 추측하지 마세요.
            의료 진단, 질병, 치료 효과를 언급하지 마세요.
            제공되지 않은 음식명, 식사 시간, 영양소는 만들어내지 마세요.
            숫자와 단위를 반복하기보다 부족함, 적정함, 많음처럼 쉽게 설명하세요.
            패턴 두 개는 서로 다른 내용을 다루고, 다음 주 목표는 한 가지만 제안하세요.
            기록이 3일 미만이면 반복되는 경향이라고 단정하지 말고 기록이 적다는 점을 반영하세요.
            각 문구는 화면에서 두 줄 안에 읽히도록 짧고 완전한 문장으로 작성하세요.
            """
        )
        let response = try await session.respond(
            to: prompt(for: input),
            generating: GeneratedAIWeeklyDetailReport.self,
            options: GenerationOptions(
                temperature: 0.7,
                maximumResponseTokens: 260
            )
        )
        let generated = response.content
        let report = AIWeeklyDetailReport(
            summary: cleaned(generated.summary),
            patterns: [
                AIWeeklyDetailPattern(
                    title: cleaned(generated.caloriePatternTitle),
                    description: cleaned(generated.caloriePatternDescription)
                ),
                AIWeeklyDetailPattern(
                    title: cleaned(generated.nutritionPatternTitle),
                    description: cleaned(generated.nutritionPatternDescription)
                )
            ],
            goalTitle: cleaned(generated.goalTitle),
            goalDescription: cleaned(generated.goalDescription)
        )

        guard
            !report.summary.isEmpty,
            report.patterns.allSatisfy({ !$0.title.isEmpty && !$0.description.isEmpty }),
            !report.goalTitle.isEmpty,
            !report.goalDescription.isEmpty
        else {
            throw AIWeeklyReportError.emptyResponse
        }

        return report
    }

    private func prompt(for input: AIWeeklyReportInput) -> String {
        let recommendation = input.recommendation
        let recordedDayCount = Double(max(input.recordedDays.count, 1))
        let total = input.recordedDays.reduce(NutritionValues.zero) {
            $0 + $1.nutrition
        }
        let average = NutritionValues(
            calories: total.calories / recordedDayCount,
            carbohydrateGrams: total.carbohydrateGrams / recordedDayCount,
            proteinGrams: total.proteinGrams / recordedDayCount,
            fatGrams: total.fatGrams / recordedDayCount
        )
        let dailyStates = input.recordedDays.map { day in
            let nutrition = day.nutrition
            let weekday = day.date.formatted(
                .dateTime
                    .locale(Locale(identifier: "ko_KR"))
                    .weekday(.wide)
            )
            return """
            \(weekday): 열량 \(status(nutrition.calories, recommendation.calories)), \
            탄수화물 \(status(nutrition.carbohydrateGrams, recommendation.carbohydrateGrams)), \
            단백질 \(status(nutrition.proteinGrams, recommendation.proteinGrams)), \
            지방 \(status(nutrition.fatGrams, recommendation.fatGrams))
            """
        }
        .joined(separator: "\n")

        return """
        최근 7일 중 식단을 기록한 날은 \(input.recordedDays.count)일입니다.

        기록된 날의 하루 평균 상태:
        열량: \(status(average.calories, recommendation.calories))
        탄수화물: \(status(average.carbohydrateGrams, recommendation.carbohydrateGrams))
        단백질: \(status(average.proteinGrams, recommendation.proteinGrams))
        지방: \(status(average.fatGrams, recommendation.fatGrams))

        날짜별 상태:
        \(dailyStates)

        위 정보만 사용해 이번 주 요약, 서로 다른 패턴 두 개, 다음 주 목표 한 개를 작성해주세요.
        목표는 가장 우선순위가 높은 영양 상태 하나에만 집중해주세요.
        """
    }

    private func status(_ value: Double, _ recommendation: Double) -> String {
        guard recommendation > 0 else { return "판단하지 않음" }
        let ratio = value / recommendation
        if ratio < 0.8 { return "부족함" }
        if ratio > 1.2 { return "많음" }
        return "적정함"
    }

    private func cleaned(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
    }

    @available(iOS 26.0, *)
    private func mappedError(
        _ error: LanguageModelSession.GenerationError
    ) -> AIWeeklyReportError {
        switch error {
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
        return "aiWeeklyDetailReport.v1.\(input.kakaoUserID).\(week)"
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
}

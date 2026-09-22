enum AIWeeklyReportState: Equatable {
    case available(message: String)
    case loading
    case unavailable

    static let ready = AIWeeklyReportState.available(
        message: "최근 식단 기록을 바탕으로 이번 주 건강 피드백을 받아보세요."
    )

    static let noData = AIWeeklyReportState.available(
        message: "식단을 기록하면 기록된 날짜를 기준으로 건강 피드백을 받을 수 있어요."
    )

    static let generationFailed = AIWeeklyReportState.available(
        message: "피드백을 만들지 못했어요. 잠시 후 다시 시도해주세요."
    )

    static let mockAvailable = AIWeeklyReportState.available(
        message: "이번 주에는 단백질 섭취가 부족한 날이 많았어요. 다음 식사에는 달걀이나 두부를 더해보세요!"
    )
}

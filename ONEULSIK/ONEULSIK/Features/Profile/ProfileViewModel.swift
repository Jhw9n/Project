import Foundation
import Observation

struct WeeklyWeightPoint: Identifiable, Equatable {
    let weekStart: Date
    let label: String
    let weightTenthsKG: Int?
    let recordedWeightTenthsKG: Int?

    var id: Date { weekStart }
    var isRecorded: Bool { recordedWeightTenthsKG != nil }

    var weightKG: Double? {
        weightTenthsKG.map { Double($0) / 10 }
    }

    var formattedWeight: String? {
        recordedWeightTenthsKG.map(Self.formattedWeight)
    }

    private static func formattedWeight(_ weightTenthsKG: Int) -> String {
        if weightTenthsKG.isMultiple(of: 10) {
            return "\(weightTenthsKG / 10)"
        }

        return String(format: "%.1f", Double(weightTenthsKG) / 10)
    }
}

@MainActor
@Observable
final class ProfileViewModel {
    let profile: UserProfile

    private(set) var weeklyWeightPoints: [WeeklyWeightPoint] = []
    private(set) var feedbackMessage = WeightFeedbackProvider.message(
        currentWeightTenthsKG: nil,
        previousWeightTenthsKG: nil
    )

    private let weightRecordStore: WeightRecordStore
    private let calendar: Calendar

    init(
        profile: UserProfile,
        weightRecordStore: WeightRecordStore,
        calendar: Calendar = .current
    ) {
        self.profile = profile
        self.weightRecordStore = weightRecordStore
        self.calendar = calendar
        reload()
    }

    var genderText: String {
        switch profile.genderRawValue.flatMap(Gender.init(rawValue:)) {
        case .male: "남성"
        case .female: "여성"
        case nil: "미입력"
        }
    }

    var birthDateText: String {
        guard let birthDate = profile.birthDate else { return "미입력" }
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: birthDate
        )
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return "미입력"
        }

        return String(format: "%04d.%02d.%02d", year, month, day)
    }

    var heightText: String {
        profile.heightCM.map { "\($0)cm" } ?? "미입력"
    }

    var weightText: String {
        guard let weightTenthsKG = profile.weightTenthsKG else { return "미입력" }
        if weightTenthsKG.isMultiple(of: 10) {
            return "\(weightTenthsKG / 10)kg"
        }

        return String(format: "%.1fkg", Double(weightTenthsKG) / 10)
    }

    var activityText: String {
        profile.activityLevelRawValue
            .flatMap(ActivityLevel.init(rawValue:))?
            .title ?? "미입력"
    }

    func reload(now: Date = .now) {
        try? weightRecordStore.ensureInitialRecord(for: profile)
        let records = (try? weightRecordStore.records(for: profile.kakaoUserID)) ?? []
        weeklyWeightPoints = makeWeeklyPoints(records: records, now: now)

        let recordedPoints = weeklyWeightPoints.filter(\.isRecorded)
        let currentWeekWeight = weeklyWeightPoints.last?.recordedWeightTenthsKG
        let previousWeight = recordedPoints
            .dropLast(currentWeekWeight == nil ? 0 : 1)
            .last?
            .recordedWeightTenthsKG

        feedbackMessage = WeightFeedbackProvider.message(
            currentWeightTenthsKG: currentWeekWeight,
            previousWeightTenthsKG: previousWeight
        )
    }

    private func makeWeeklyPoints(
        records: [WeightRecord],
        now: Date
    ) -> [WeeklyWeightPoint] {
        guard let currentWeekStart = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        )?.start,
              let firstWeekStart = calendar.date(
                byAdding: .weekOfYear,
                value: -11,
                to: currentWeekStart
              ) else {
            return []
        }

        var carriedWeight = records
            .last { $0.recordedAt < firstWeekStart }?
            .weightTenthsKG

        return (0..<12).compactMap { offset in
            guard let weekStart = calendar.date(
                byAdding: .weekOfYear,
                value: offset,
                to: firstWeekStart
            ),
                  let weekEnd = calendar.date(
                    byAdding: .weekOfYear,
                    value: 1,
                    to: weekStart
                  ) else {
                return nil
            }

            let latestRecord = records.last {
                $0.recordedAt >= weekStart && $0.recordedAt < weekEnd
            }
            if let latestRecord {
                carriedWeight = latestRecord.weightTenthsKG
            }

            return WeeklyWeightPoint(
                weekStart: weekStart,
                label: weekLabel(for: weekStart),
                weightTenthsKG: carriedWeight,
                recordedWeightTenthsKG: latestRecord?.weightTenthsKG
            )
        }
    }

    private func weekLabel(for date: Date) -> String {
        let components = calendar.dateComponents([.month, .weekOfMonth], from: date)
        guard let month = components.month,
              let weekOfMonth = components.weekOfMonth else {
            return ""
        }

        return "\(month)월 \(weekOfMonth)주"
    }
}

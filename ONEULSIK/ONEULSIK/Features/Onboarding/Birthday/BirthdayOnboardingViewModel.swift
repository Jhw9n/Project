import Foundation
import Observation

@MainActor
@Observable
final class BirthdayOnboardingViewModel {
    var selectedDate: Date

    let dateRange: ClosedRange<Date>

    private let profile: UserProfile
    private let onboardingStore: OnboardingStore
    private let calendar: Calendar

    init(
        profile: UserProfile,
        onboardingStore: OnboardingStore,
        calendar: Calendar = .current,
        now: Date = .now
    ) {
        self.profile = profile
        self.onboardingStore = onboardingStore
        self.calendar = calendar

        let minimumDate = calendar.date(
            from: DateComponents(year: 1900, month: 1, day: 1)
        ) ?? .distantPast
        let maximumDate = calendar.startOfDay(for: now)
        let defaultDate = calendar.date(
            byAdding: .year,
            value: -20,
            to: maximumDate
        ) ?? maximumDate

        self.dateRange = minimumDate...maximumDate
        self.selectedDate = profile.birthDate ?? defaultDate
    }

    func saveSelection() throws {
        try onboardingStore.saveBirthDate(
            calendar.startOfDay(for: selectedDate),
            for: profile
        )
    }
}

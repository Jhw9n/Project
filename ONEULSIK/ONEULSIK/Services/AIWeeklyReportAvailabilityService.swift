import FoundationModels

struct AIWeeklyReportAvailabilityService {
    func currentState() -> AIWeeklyReportState {
        guard #available(iOS 26.0, *) else {
            return .unavailable
        }

        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return .unavailable }

        return .ready
    }
}

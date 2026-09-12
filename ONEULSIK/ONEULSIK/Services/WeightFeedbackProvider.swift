enum WeightFeedbackProvider {
    static func message(
        currentWeightTenthsKG: Int?,
        previousWeightTenthsKG: Int?
    ) -> String {
        guard let currentWeightTenthsKG else {
            return "이번 주 체중을 업데이트해 주세요!\n매주 기록하면 변화를 확인할 수 있어요."
        }

        guard let previousWeightTenthsKG else {
            return "첫 체중 기록을 완료했어요!\n매주 업데이트하며 변화를 확인해요."
        }

        if currentWeightTenthsKG < previousWeightTenthsKG {
            return "이전보다 체중이 줄었어요!\n현재 체중을 확인하고 계속 기록해요."
        }

        if currentWeightTenthsKG > previousWeightTenthsKG {
            return "이전보다 체중이 늘었어요.\n현재 체중을 확인하고 업데이트해요."
        }

        return "비슷한 체중을 유지하고 있어요!\n매주 기록하며 변화를 확인해요."
    }
}

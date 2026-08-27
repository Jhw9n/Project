import Foundation

enum HealthFeedbackProvider {
    static func message(
        consumed: NutritionValues,
        recommended: NutritionRecommendation
    ) -> String {
        guard consumed.calories > 0 else {
            return "오늘의 식사를 기록하고 건강 피드백을 확인해 보세요!"
        }

        let calorieRatio = consumed.calories / recommended.calories
        let carbohydrateRatio = consumed.carbohydrateGrams / recommended.carbohydrateGrams
        let proteinRatio = consumed.proteinGrams / recommended.proteinGrams
        let fatRatio = consumed.fatGrams / recommended.fatGrams

        if calorieRatio > 1.1 {
            return "오늘 권장 칼로리를 초과했어요. 다음 식사는 가볍게 조절해 보세요!"
        }

        if carbohydrateRatio > 1.15 {
            return "오늘은 탄수화물 비율이 높아요. 다음 식사는 단백질과 채소를 더해 보세요!"
        }

        if fatRatio > 1.15 {
            return "오늘은 지방 섭취가 많아요. 담백한 메뉴를 선택해 보세요!"
        }

        if proteinRatio < 0.65, calorieRatio >= 0.55 {
            return "단백질이 조금 부족해요. 달걀이나 두부 같은 식품을 추가해 보세요!"
        }

        if calorieRatio < 0.7 {
            return "현재 섭취량이 권장량보다 부족해요. 남은 식사도 잊지 말고 챙겨 보세요!"
        }

        if calorieRatio <= 1.1 {
            return "오늘은 권장 섭취량에 알맞게 잘 섭취하고 있어요!"
        }

        return "오늘의 식사 기록을 바탕으로 균형 있게 섭취하고 있어요!"
    }
}

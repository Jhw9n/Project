import SwiftData
import SwiftUI

struct HomeSummaryView: View {
    let viewModel: HomeViewModel
    let topInset: CGFloat
    let onNotificationTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, topInset)

            VStack(alignment: .leading, spacing: 0) {
                Text("\(viewModel.profile.nickname)님의 섭취 칼로리")
                    .font(.pretendardSemiBold(16))

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(viewModel.todayNutrition.calories, format: .number.precision(.fractionLength(0)))
                        .font(.pretendardSemiBold(48))

                    Text("kcal")
                        .font(.pretendardSemiBold(24))
                }
                .frame(height: 65)

                Text("권장 섭취량 : \(formatted(viewModel.recommendation.calories)) kcal")
                    .font(.pretendardBold(16))
                    .padding(.top, 8)

                HomeProgressBar(
                    progress: viewModel.calorieProgress,
                    foregroundColor: .green02,
                    backgroundColor: .white
                )
                .padding(.top, 8)

                HStack(spacing: 12) {
                    NutritionSummaryCard(
                        title: "탄수화물",
                        consumed: viewModel.todayNutrition.carbohydrateGrams,
                        recommended: viewModel.recommendation.carbohydrateGrams,
                        progress: viewModel.progress(
                            consumed: viewModel.todayNutrition.carbohydrateGrams,
                            recommended: viewModel.recommendation.carbohydrateGrams
                        )
                    )

                    NutritionSummaryCard(
                        title: "단백질",
                        consumed: viewModel.todayNutrition.proteinGrams,
                        recommended: viewModel.recommendation.proteinGrams,
                        progress: viewModel.progress(
                            consumed: viewModel.todayNutrition.proteinGrams,
                            recommended: viewModel.recommendation.proteinGrams
                        )
                    )

                    NutritionSummaryCard(
                        title: "지방",
                        consumed: viewModel.todayNutrition.fatGrams,
                        recommended: viewModel.recommendation.fatGrams,
                        progress: viewModel.progress(
                            consumed: viewModel.todayNutrition.fatGrams,
                            recommended: viewModel.recommendation.fatGrams
                        )
                    )
                }
                .padding(.top, 20)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .frame(height: 400, alignment: .top)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0
            )
            .fill(Color.green03)
        }
    }

    private var header: some View {
        HStack {
            Image("oneulsikLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 65.34, height: 20.06)

            Spacer()

            Button(action: onNotificationTap) {
                Image("homeAlarm")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("알림")
        }
        .frame(height: 56)
        .padding(.leading, 20)
        .padding(.trailing, 4)
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }
}

private struct NutritionSummaryCard: View {
    let title: String
    let consumed: Double
    let recommended: Double
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.pretendardSemiBold(14))

            HStack(spacing: 2) {
                Text(consumed, format: .number.precision(.fractionLength(0)))
                    .foregroundStyle(Color.black01)

                Text("/")
                    .foregroundStyle(Color.black01)

                Text("\(formatted(recommended))g")
                    .foregroundStyle(Color.gray03)
            }
            .font(.pretendardBold(14))
            .padding(.top, 6)

            Spacer(minLength: 5)

            HomeProgressBar(
                progress: progress,
                foregroundColor: .green03,
                backgroundColor: Color(red: 232 / 255, green: 233 / 255, blue: 236 / 255)
            )
        }
        .foregroundStyle(Color.black01)
        .padding(.horizontal, 13)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }
}

private struct HomeProgressBar: View {
    let progress: Double
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: 3)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 12)
        .accessibilityValue("\(Int(progress * 100))퍼센트")
    }
}

#Preview {
    HomeSummaryPreview()
}

private struct HomeSummaryPreview: View {
    private let container: ModelContainer
    private let viewModel: HomeViewModel

    init() {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: UserProfile.self,
            MealRecord.self,
            configurations: configuration
        )
        let context = container.mainContext
        let profile = UserProfile(
            kakaoUserID: 1,
            nickname: "박정환",
            genderRawValue: Gender.male.rawValue,
            birthDate: Calendar.current.date(
                from: DateComponents(year: 1998, month: 3, day: 15)
            ),
            heightCM: 178,
            weightTenthsKG: 780,
            activityLevelRawValue: ActivityLevel.active.rawValue,
            hasCompletedOnboarding: true
        )

        context.insert(profile)
        context.insert(
            MealRecord(
                kakaoUserID: profile.kakaoUserID,
                recordedAt: .now,
                calories: 4_600,
                carbohydrateGrams: 632,
                proteinGrams: 201,
                fatGrams: 141
            )
        )
        try? context.save()

        self.container = container
        viewModel = HomeViewModel(
            profile: profile,
            mealRecordStore: MealRecordStore(modelContext: context)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            NoBounceScrollView {
                HomeSummaryView(
                    viewModel: viewModel,
                    topInset: geometry.safeAreaInsets.top,
                    onNotificationTap: {}
                )
            }
            .background(Color.gray01)
            .ignoresSafeArea(edges: .top)
        }
        .modelContainer(container)
    }
}

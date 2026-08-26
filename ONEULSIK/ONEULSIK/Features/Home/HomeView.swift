import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var isShowingNotificationNotice = false

    init(profile: UserProfile, mealRecordStore: MealRecordStore) {
        _viewModel = State(
            initialValue: HomeViewModel(
                profile: profile,
                mealRecordStore: mealRecordStore
            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            NoBounceScrollView {
                LazyVStack(spacing: 0) {
                    HomeSummaryView(
                        viewModel: viewModel,
                        topInset: geometry.safeAreaInsets.top
                    ) {
                        isShowingNotificationNotice = true
                    }

                    HomeSection(title: "건강 피드백") {
                        HealthFeedbackCard(message: viewModel.feedbackMessage)
                    }
                    .padding(.top, 30)

                    HomeSection(title: "주간 그래프") {
                        WeeklyCalorieChart(viewModel: viewModel)
                    }
                    .padding(.top, 31)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.gray01)
            .ignoresSafeArea(edges: .top)
        }
        .onAppear {
            viewModel.reload()
        }
        .alert("알림", isPresented: $isShowingNotificationNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("알림 기능은 준비 중이에요.")
        }
    }
}

private struct HomeSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(title)
                .font(.pretendardSemiBold(16))
                .foregroundStyle(Color.black01)

            content
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeViewPreview()
}

private struct HomeViewPreview: View {
    private let container: ModelContainer
    private let profile: UserProfile
    private let mealRecordStore: MealRecordStore

    init() {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: UserProfile.self,
            MealRecord.self,
            configurations: configuration
        )
        let calendar = Calendar.current
        let context = container.mainContext
        let profile = UserProfile(
            kakaoUserID: 1,
            nickname: "박정환",
            genderRawValue: Gender.male.rawValue,
            birthDate: calendar.date(from: DateComponents(year: 1998, month: 3, day: 15)),
            heightCM: 178,
            weightTenthsKG: 780,
            activityLevelRawValue: ActivityLevel.active.rawValue,
            hasCompletedOnboarding: true,
            createdAt: calendar.date(byAdding: .day, value: -12, to: .now) ?? .now
        )
        context.insert(profile)

        let calorieSamples = [4_800, 3_900, 2_200, 3_100, 900, 3_900, 4_600]
        for (index, calories) in calorieSamples.enumerated() {
            let dayOffset = index - 6
            let date = calendar.date(byAdding: .day, value: dayOffset, to: .now) ?? .now
            let calorieValue = Double(calories)
            context.insert(
                MealRecord(
                    kakaoUserID: profile.kakaoUserID,
                    recordedAt: date,
                    calories: calorieValue,
                    carbohydrateGrams: calorieValue * 0.55 / 4,
                    proteinGrams: calorieValue * 0.175 / 4,
                    fatGrams: calorieValue * 0.275 / 9
                )
            )
        }
        try? context.save()

        self.container = container
        self.profile = profile
        mealRecordStore = MealRecordStore(modelContext: context)
    }

    var body: some View {
        HomeView(
            profile: profile,
            mealRecordStore: mealRecordStore
        )
        .modelContainer(container)
    }
}

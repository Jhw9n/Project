import Charts
import SwiftUI

struct WeeklyCalorieChart: View {
    let viewModel: HomeViewModel

    private let signupDate: Date

    private var indexedPoints: [(offset: Int, element: DailyCaloriePoint)] {
        Array(viewModel.dailyCaloriePoints.enumerated())
    }

    private var xAxisDomain: ClosedRange<Double> {
        -0.5...(Double(max(viewModel.dailyCaloriePoints.count, 1)) - 0.5)
    }

    private var initialScrollPosition: Double {
        Double(max(viewModel.dailyCaloriePoints.count - 7, 0)) - 0.5
    }

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        signupDate = Calendar.current.startOfDay(for: viewModel.profile.createdAt)
    }

    var body: some View {
        Chart {
            ForEach(indexedPoints, id: \.element.id) { index, point in
                BarMark(
                    x: .value("날짜", Double(index)),
                    y: .value("섭취 칼로리", point.calories),
                    width: .fixed(24)
                )
                .foregroundStyle(point.isBeforeSignup ? Color.gray02.opacity(0.35) : Color.green03)
            }

            RuleMark(y: .value("권장 섭취량", viewModel.recommendation.calories))
                .foregroundStyle(Color.tabGreen.opacity(0.8))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
        }
        .chartXScale(domain: xAxisDomain)
        .chartYScale(domain: 0...viewModel.yAxisMaximum)
        .chartYAxis {
            AxisMarks(
                position: .trailing,
                values: .stride(by: viewModel.yAxisStride)
            ) { value in
                AxisGridLine()
                    .foregroundStyle(Color.gray02.opacity(0.8))

                AxisValueLabel {
                    if let calories = value.as(Double.self) {
                        Text(calories, format: .number.precision(.fractionLength(0)))
                            .font(.pretendardSemiBold(10))
                            .foregroundStyle(Color.black01)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: indexedPoints.map { Double($0.offset) }) { value in
                AxisValueLabel {
                    if let index = value.as(Double.self).map(Int.init),
                       viewModel.dailyCaloriePoints.indices.contains(index) {
                        let date = viewModel.dailyCaloriePoints[index].date
                        Text(weekday(for: date))
                            .font(.pretendardSemiBold(11))
                            .foregroundStyle(date < signupDate ? Color.gray02 : Color.black01)
                            .offset(x: -10)
                    }
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 7)
        .chartScrollPosition(initialX: initialScrollPosition)
        .frame(height: 220)
        .padding(.horizontal, 14)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weekday(for date: Date) -> String {
        date.formatted(
            Date.FormatStyle()
                .weekday(.narrow)
                .locale(Locale(identifier: "ko_KR"))
        )
    }
}

import Charts
import SwiftUI

struct WeightChangeChart: View {
    let points: [WeeklyWeightPoint]

    @State private var selectedPointID: Date?

    private var indexedPoints: [(offset: Int, element: WeeklyWeightPoint)] {
        Array(points.enumerated())
    }

    private var xAxisDomain: ClosedRange<Double> {
        -0.5...(Double(max(points.count, 1)) - 0.5)
    }

    private var initialScrollPosition: Double {
        Double(max(points.count - 6, 0)) - 0.5
    }

    private var yAxisDomain: ClosedRange<Double> {
        let weights = points.compactMap(\.weightKG)
        guard let minimum = weights.min(), let maximum = weights.max() else {
            return 68...72
        }

        var lowerBound = floor((minimum - 1) * 2) / 2
        var upperBound = ceil((maximum + 1) * 2) / 2
        if upperBound - lowerBound < 4 {
            let midpoint = (minimum + maximum) / 2
            lowerBound = floor((midpoint - 2) * 2) / 2
            upperBound = ceil((midpoint + 2) * 2) / 2
        }

        return lowerBound...upperBound
    }

    var body: some View {
        Chart {
            ForEach(indexedPoints, id: \.element.id) { item in
                RuleMark(x: .value("주차", Double(item.offset)))
                    .foregroundStyle(Color.gray02.opacity(0.65))
                    .lineStyle(StrokeStyle(lineWidth: 1))

                if let weightKG = item.element.weightKG {
                    LineMark(
                        x: .value("주차", Double(item.offset)),
                        y: .value("몸무게", weightKG)
                    )
                    .foregroundStyle(Color.green03)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.linear)
                }

                if item.element.isRecorded,
                   let weightKG = item.element.weightKG {
                    PointMark(
                        x: .value("주차", Double(item.offset)),
                        y: .value("몸무게", weightKG)
                    )
                    .foregroundStyle(Color.green03)
                    .symbol {
                        weightPointSymbol(isSelected: selectedPointID == item.element.id)
                    }
                    .annotation(position: .top, spacing: 8) {
                        if selectedPointID == item.element.id,
                           let formattedWeight = item.element.formattedWeight {
                            weightBubble(formattedWeight)
                        }
                    }
                }
            }
        }
        .chartXScale(domain: xAxisDomain)
        .chartYScale(domain: yAxisDomain)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: indexedPoints.map { Double($0.offset) }) { value in
                AxisValueLabel(centered: false) {
                    if let index = value.as(Double.self).map(Int.init),
                       points.indices.contains(index) {
                        Text(points[index].label)
                            .font(.pretendardSemiBold(10))
                            .foregroundStyle(Color.black01)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .offset(x: index == points.indices.last ? -14 : -21)
                    }
                }
                AxisTick().foregroundStyle(.clear)
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 6)
        .chartScrollPosition(initialX: initialScrollPosition)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                selectPoint(
                                    at: value.location,
                                    proxy: proxy,
                                    geometry: geometry
                                )
                            }
                    )
            }
        }
        .frame(height: 158)
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            selectLatestRecordedPoint()
        }
        .onChange(of: points) {
            if !points.contains(where: { $0.id == selectedPointID && $0.isRecorded }) {
                selectLatestRecordedPoint()
            }
        }
    }

    private func selectPoint(
        at location: CGPoint,
        proxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotOrigin = geometry[plotFrame].origin
        let xPosition = location.x - plotOrigin.x
        guard let indexValue = proxy.value(atX: xPosition, as: Double.self) else { return }

        let index = Int(indexValue.rounded())
        guard points.indices.contains(index), points[index].isRecorded else { return }
        selectedPointID = points[index].id
    }

    private func selectLatestRecordedPoint() {
        selectedPointID = points.last(where: \.isRecorded)?.id
    }

    @ViewBuilder
    private func weightPointSymbol(isSelected: Bool) -> some View {
        if isSelected {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 18, height: 18)

                Circle()
                    .stroke(Color.green03, lineWidth: 2)
                    .frame(width: 18, height: 18)

                Circle()
                    .fill(Color.green03)
                    .frame(width: 6, height: 6)
            }
        } else {
            Circle()
                .fill(Color.white)
                .overlay {
                    Circle().stroke(Color.green03, lineWidth: 2)
                }
                .frame(width: 10, height: 10)
        }
    }

    private func weightBubble(_ weight: String) -> some View {
        VStack(spacing: -1) {
            Text(weight)
                .font(.pretendardSemiBold(14))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 7)
                .frame(height: 24)
                .background(Color.green03, in: RoundedRectangle(cornerRadius: 7))

            WeightBubblePointer()
                .fill(Color.green03)
                .frame(width: 8, height: 5)
        }
    }
}

private struct WeightBubblePointer: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}
